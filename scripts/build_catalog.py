"""Bundle the dependency-free D1 Worker; Flutter remains the client."""
from pathlib import Path
import argparse
import json

ROOT=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--enable-seeding',action='store_true',help='Temporary bootstrap only; normal builds reject writes.')
args=parser.parse_args()
source=(ROOT/'catalog/worker.mjs').read_text()
seed=json.loads((ROOT/'catalog/seed.json').read_text())
assert len(seed['people'])==seed['expectedCount']==1000
source=source.replace("import seed from './seed.json' with { type: 'json' };",
                      'const seed='+json.dumps(seed,ensure_ascii=False,separators=(',',':'))+';')
if args.enable_seeding:
    source=source.replace('export default {fetch:createHandler()};',
                          'export default {fetch:createHandler({allowSeeding:true})};')
target=ROOT/'build/catalog/index.js'
target.parent.mkdir(parents=True,exist_ok=True)
target.write_text(source)
print(f'D1 Worker built: {target.stat().st_size} bytes; seed data stays server-side.')
