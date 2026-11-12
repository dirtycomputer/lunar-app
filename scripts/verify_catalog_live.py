"""Read every live D1 page, verify the dataset, and export a real SQLite copy."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import sqlite3
import subprocess
from urllib.parse import urlencode

ROOT=Path(__file__).resolve().parents[1]


def read(url):
    result=subprocess.run(['curl','--fail','--silent','--show-error','--retry','1',url],
                          capture_output=True,text=True,check=True)
    return json.loads(result.stdout)


if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--origin',default='https://yuan-bazi-connections.dirtycomputer.chatgpt.site')
    args=parser.parse_args();origin=args.origin.rstrip('/')
    expected=json.loads((ROOT/'catalog/seed.json').read_text())
    people=[];cursor=None
    for _ in range(10):
        query={'limit':'200'}
        if cursor:query['after']=cursor
        page=read(origin+'/api/people?'+urlencode(query))
        assert page['storage']=='cloudflare-d1' and page['synthetic'] is True
        assert page['revision']==expected['revision'] and page['total']==1000
        people.extend(page['people']);cursor=page['nextCursor']
        if cursor is None:break
    assert cursor is None and len(people)==len({p['id'] for p in people})==1000
    assert people==[x['profile'] for x in expected['people']]
    stats=read(origin+'/api/people/stats')
    assert stats['total']==1000 and stats['unknownBirthTime']==100
    assert len(stats['countries'])==40 and len(stats['continents'])==6
    assert {x['value']:x['count'] for x in stats['genders']}=={'Women':400,'Men':400,'Non-binary':200}
    assert all(x['count']==25 for x in stats['countries'])
    assert read(origin+'/api/people/catalog-0928')['person']==next(p for p in people if p['id']=='catalog-0928')
    output=ROOT/'output';output.mkdir(exist_ok=True)
    (output/'catalog-live.json').write_text(json.dumps({'revision':expected['revision'],'people':people},ensure_ascii=False))
    target=ROOT/'build/catalog/fatepair-catalog.sqlite3';target.parent.mkdir(parents=True,exist_ok=True)
    if target.exists():target.unlink()
    connection=sqlite3.connect(target)
    connection.executescript((ROOT/'catalog/drizzle/0000_catalog.sql').read_text())
    values=[]
    for p in people:
        encoded=json.dumps(p,ensure_ascii=False,sort_keys=True,separators=(',',':'))
        values.append((p['id'],p['name'],p['gender'],p['countryCode'],p['country'],p['continent'],
          p['birth']['date'],p['location'],
          ' '.join([p['name'],p['location'],p['occupation'],*p['interests'],*p['languages']]).lower(),
          int(p['birth']['timeKnown']),expected['revision'],hashlib.sha256(encoded.encode()).hexdigest(),encoded))
    connection.executemany('INSERT INTO catalog_people(id,name,gender,country_code,country,continent,birth_date,location,search_text,time_known,seed_version,record_hash,data_json) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)',values)
    connection.execute('INSERT INTO catalog_seed_runs(revision,expected_count,completed_at) VALUES(?,?,?)',
                       (expected['revision'],1000,stats['seededAt']))
    connection.commit();connection.close()
    # Open a new connection to check that this is a durable SQLite database.
    with sqlite3.connect(target) as reopened:
        assert reopened.execute('PRAGMA integrity_check').fetchone()[0]=='ok'
        assert reopened.execute('SELECT COUNT(*) FROM catalog_people').fetchone()[0]==1000
    digest=hashlib.sha256(json.dumps(people,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode()).hexdigest()
    report={'origin':origin,'storage':'cloudflare-d1','revision':expected['revision'],
            'profiles':1000,'countries':40,'continents':6,'genders':dict(Counter(p['gender'] for p in people)),
            'ageRange':[stats['youngest'],stats['oldest']],'unknownBirthTime':100,
            'profileDigest':digest,'seededAt':stats['seededAt'],'sqliteBytes':target.stat().st_size}
    (output/'catalog-live-report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,ensure_ascii=False))
