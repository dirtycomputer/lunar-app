"""Query OSV for the exact checked-in Python and Pub package versions.

Only public package names/versions are sent. Network or incomplete responses
fail the audit rather than being reported as a clean dependency scan.
"""
from datetime import datetime, timezone
import json
from pathlib import Path
import re
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[1]


def queries():
    result = []
    for line in (ROOT / 'server/requirements.txt').read_text().splitlines():
        if not line.strip() or line.startswith('#'):
            continue
        match = re.fullmatch(r'([A-Za-z0-9_.-]+)==([^\s;]+)', line)
        if not match:
            raise ValueError('Every Python runtime dependency must be pinned.')
        name = re.sub(r'[-_.]+', '-', match[1]).lower()
        result.append({'package': {'name': name, 'ecosystem': 'PyPI'}, 'version': match[2]})
    lock = (ROOT / 'pubspec.lock').read_text()
    for name, block in re.findall(
            r'^  ([a-z_0-9]+):\n(.*?)(?=^  [a-z_0-9]+:|^sdks:|\Z)', lock, re.M | re.S):
        if 'source: hosted' not in block:
            continue
        version = re.search(r'^    version: "([^"]+)"', block, re.M)
        if not version:
            raise ValueError('A hosted Pub version is missing.')
        result.append({'package': {'name': name, 'ecosystem': 'Pub'}, 'version': version[1]})
    return result


def audit():
    packages = queries()
    request = Request('https://api.osv.dev/v1/querybatch', method='POST',
                      data=json.dumps({'queries': packages}).encode(),
                      headers={'Content-Type': 'application/json', 'User-Agent': 'FatePair-dependency-review'})
    with urlopen(request, timeout=30) as response:
        results = json.load(response)['results']
    if len(results) != len(packages) or any('error' in item for item in results):
        raise ValueError('OSV returned an incomplete dependency audit.')
    findings = [dict(package=package['package'], version=package['version'],
                     advisories=[item['id'] for item in result['vulns']])
                for package, result in zip(packages, results) if result.get('vulns')]
    return {'source': 'https://osv.dev', 'checkedAt': datetime.now(timezone.utc).isoformat(),
            'packagesChecked': len(packages), 'findings': findings,
            'scope': 'Pinned Python runtime and hosted Pub packages; not a complete security assessment.'}


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    report = audit()
    encoded = json.dumps(report, indent=2)
    print(encoded)
    if args.output:
        args.output.write_text(encoded + '\n')
    raise SystemExit(bool(report['findings']))
