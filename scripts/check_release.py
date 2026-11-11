"""Check package integrity, and refuse an unjustified production label.

This is a release guard, not a certification or a substitute for runtime QA.
"""
import argparse
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]


def check(channel):
    failures = []
    manifest = json.loads((ROOT / 'web/manifest.json').read_text())
    for icon in manifest['icons']:
        if not (ROOT / 'web' / icon['src']).is_file():
            failures.append(f"Missing Web icon: {icon['src']}")
    ios = ROOT / 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    for icon in json.loads((ios / 'Contents.json').read_text())['images']:
        if not (ios / icon['filename']).is_file():
            failures.append(f"Missing iOS icon: {icon['filename']}")
    gradle = (ROOT / 'android/app/build.gradle').read_text()
    if 'signingConfig = signingConfigs.debug' in gradle:
        failures.append('Android release uses the debug signing identity.')
    # Only application inputs are scanned; no environment, credentials, logs or
    # user files are read. Error output reports paths, never matching values.
    key_pattern = re.compile(r'\bsk-[A-Za-z0-9]{24,}\b')
    for directory in ('lib', 'server', 'web', 'scripts'):
        for path in (ROOT / directory).rglob('*'):
            if path.suffix not in ('.dart', '.py', '.mjs', '.js', '.html', '.arb'):
                continue
            if any(part in ('.venv', '__pycache__') for part in path.parts):
                continue
            if key_pattern.search(path.read_text()):
                failures.append(f'Possible embedded provider credential: {path.relative_to(ROOT)}')
    launch = json.loads((ROOT / 'release/launch.json').read_text())
    if channel == 'production':
        if launch['channel'] != 'production':
            failures.append('The app is currently classified as a preview.')
        failures.extend(f"{item['id']}: {item['reason']}" for item in launch['blocking'])
    return failures


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--channel', choices=['preview', 'production'], default='preview')
    args = parser.parse_args()
    errors = check(args.channel)
    for error in errors:
        print(f'BLOCKED: {error}')
    if not errors:
        print(f'{args.channel} package checks passed; this does not establish production readiness.')
    sys.exit(bool(errors))
