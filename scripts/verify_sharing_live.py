"""Two-device sharing smoke against real D1. No credentials in output or argv."""
import argparse
import json
from pathlib import Path
import secrets
import subprocess

ROOT=Path(__file__).resolve().parents[1]
def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--origin',default='https://yuan-bazi-connections.dirtycomputer.chatgpt.site')
    args=parser.parse_args()
    origin=args.origin.rstrip('/')
    def call(path,method='GET',credential=None,data=None):
        # Native Sites accepts browser, Dart and curl clients; its edge rejects
        # urllib's default Python user agent. Credentials stay on hidden stdin.
        config=['url = '+json.dumps(origin+path),'request = '+json.dumps(method),
                'header = "Content-Type: application/json"']
        if credential:config.append('header = '+json.dumps('Authorization: Bearer '+credential))
        if data is not None:config.append('data = '+json.dumps(json.dumps(data)))
        response=subprocess.run(['curl','--silent','--show-error','--include','--max-time','25','--config','-'],
                                input='\n'.join(config)+'\n',capture_output=True,text=True,check=True)
        remaining=response.stdout
        while remaining.startswith('HTTP/'):
            block,_,remaining=remaining.partition('\n\n')
            lines=block.splitlines();status=int(lines[0].split()[1])
            headers=dict(line.split(': ',1) for line in lines[1:] if ': ' in line)
        try:value=json.loads(remaining)
        except json.JSONDecodeError:value=remaining.encode()
        return status,headers,value
    links=[]
    host={'name':'QA Alex','element':0,'traits':[0,1],'counts':[2,1,1,1,1]}
    guest={'name':'QA Sam','element':3,'traits':[0,1],'counts':[1,3,1,1,0]}
    try:
        pair,owner,participant=[secrets.token_urlsafe(24) for _ in range(3)]
        links.append((pair,owner))
        payload={'id':pair,'kind':'pair','portrait':host,'consent':True}
        status,_,_=call('/api/shares','POST',owner,payload);assert status==201,('create',status)
        assert call('/api/shares','POST',owner,payload)[0]==200
        status,headers,public=call('/api/shares/'+pair);assert status==200 and 'result' not in public
        assert headers.get('Cache-Control',headers.get('cache-control'))=='no-store'
        status,_,html=call('/s/'+pair);assert status==200 and b'flutter_bootstrap.js' in html
        assert call('/api/shares/'+pair+'/open','POST',data={})[0]==200
        status,_,accepted=call('/api/shares/'+pair+'/join','POST',participant,{'portrait':guest,'consent':True})
        assert status==200 and accepted['result']['guest']==guest
        mine=call('/api/shares/'+pair,credential=owner)[2]
        theirs=call('/api/shares/'+pair,credential=participant)[2]
        assert mine['result']==theirs['result'] and 'score' not in mine['result']
        assert 'result' not in call('/api/shares/'+pair)[2]
        assert call('/api/shares/'+pair,credential=secrets.token_urlsafe(24))[0]==401
        assert call('/api/shares/'+pair+'/join','POST',secrets.token_urlsafe(24),{'portrait':guest,'consent':True})[0]==409
        card,card_owner=[secrets.token_urlsafe(24) for _ in range(2)]
        links.append((card,card_owner))
        status,_,_=call('/api/shares','POST',card_owner,{'id':card,'kind':'portrait','portrait':{'name':'QA Sam','element':3,'traits':[0]},'consent':True,'parentId':pair})
        assert status==201
        assert 'counts' not in call('/api/shares/'+card)[2]['portrait']
        assert call('/api/shares/'+pair,'DELETE',participant)[0]==200
        assert call('/api/shares/'+pair)[0]==410
        assert call('/api/shares/'+card,'DELETE',card_owner)[0]==200
        assert call('/api/shares/'+card)[0]==410
        assert call('/api/people/stats')[2]['total']==1000
        report={'origin':origin,'storage':'cloudflare-d1','creation':True,'idempotentRetry':True,
          'deepLinkHtml':True,'twoDeviceResult':True,'privateResult':True,'singleParticipant':True,
          'onwardPortrait':True,'participantWithdrawal':True,'ownerWithdrawal':True,
          'catalogPreserved':1000,'testRecordsRemoved':True,'browserInteraction':False}
        (ROOT/'output/sharing-live-report.json').write_text(json.dumps(report,indent=2)+'\n')
        print(json.dumps(report))
    finally:
        for link,credential in links:
            status,_,_=call('/api/shares/'+link,'DELETE',credential)
            if status!=200:raise RuntimeError('QA sharing cleanup needs retry (credential retained only in this process).')
if __name__=='__main__': main()
