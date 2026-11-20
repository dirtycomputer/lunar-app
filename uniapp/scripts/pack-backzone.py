"""Regenerate pre-1970 corrections from a full IANA TZif distribution with backzone."""
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess
import sys
from zoneinfo import ZoneInfo, _common

app = Path(__file__).resolve().parents[1]
tzdir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path('/usr/share/zoneinfo')
node = """
const mt=require('moment-timezone');
const begin=Date.UTC(1899,11,29), end=Date.UTC(1970,0,4), zones={};
for(const name of mt.tz.names()){
 const z=mt.tz.zone(name), data=[-Math.round(z.utcOffset(begin)*60)];
 z.untils.forEach((ms,i)=>{
  if(ms>begin&&ms<end){
   const offset=-Math.round(z.offsets[i+1]*60);
   if(offset!==data.at(-1))data.push(ms/1000,offset);
  }
 });
 zones[name]=data;
}
process.stdout.write(JSON.stringify({version:mt.tz.dataVersion,zones}));
"""
packed = json.loads(subprocess.check_output(['node','-e',node],cwd=app))
version = (tzdir/'tzdata.zi').read_text().splitlines()[0].split()[-1]
if version != packed['version']:
    raise SystemExit('Use a full zoneinfo directory matching moment-timezone '+packed['version'])
begin = datetime(1899,12,29,tzinfo=timezone.utc)
end = datetime(1970,1,4,tzinfo=timezone.utc)
exceptions, patterns = {}, {}
for name, existing in packed['zones'].items():
    path = tzdir/name
    if not path.is_file(): continue
    with path.open('rb') as f:
        zone = ZoneInfo.from_file(f)
        f.seek(0)
        types, times, offsets, *_ = _common.load_data(f)
    out = [int(begin.astimezone(zone).utcoffset().total_seconds())]
    for t,i in zip(times,types):
        if begin.timestamp()<t<end.timestamp() and offsets[i]!=out[-1]:
            out.extend((t,offsets[i]))
    if existing != out:
        exceptions[name]=patterns.setdefault(tuple(out),len(patterns))
data=json.dumps([exceptions,list(patterns)],separators=(',',':'))
dest=app/'src/lib/backzone.js'
dest.write_text('// Generated from IANA '+version+' by scripts/pack-backzone.py\nexport default '+data+'\n')
print(len(exceptions),'pre-1970 timezone exceptions')
