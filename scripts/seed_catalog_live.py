"""One-time, bounded D1 seed. Credential stays on hidden stdin, never in argv."""
import argparse
import getpass
import json
import subprocess

if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--origin',default='https://yuan-bazi-connections.dirtycomputer.chatgpt.site')
    args=parser.parse_args()
    token=getpass.getpass('Seed credential (hidden input): ')
    if len(token)!=64 or any(c not in '0123456789abcdef' for c in token):
        raise SystemExit('Invalid credential format.')
    for offset in range(0,1000,50):
        result=subprocess.run(['curl','--fail-with-body','--silent','--show-error',
            '--config','-','--request','POST',
            args.origin.rstrip('/')+'/api/admin/catalog/seed?offset='+str(offset)],
            input='header = "Authorization: Bearer '+token+'"\n',
            capture_output=True,text=True)
        if result.returncode:
            raise SystemExit('Seed request failed: '+result.stderr+result.stdout)
        row=json.loads(result.stdout)
        print(f"Stored {row['stored']} / 1000",flush=True)
    if not row['complete']:raise SystemExit('Catalog incomplete.')
    print('D1 seed completed. Remove CATALOG_SEED_TOKEN and redeploy to close writes.')
