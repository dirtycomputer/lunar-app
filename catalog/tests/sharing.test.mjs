import {test,before,after} from 'node:test';
import assert from 'node:assert/strict';
import {DatabaseSync} from 'node:sqlite';
import {mkdtempSync,readFileSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {createHandler} from '../worker.mjs';
import {pairReading} from '../sharing.mjs';

class SQLiteD1 {
  constructor(file){this.db=new DatabaseSync(file);}
  prepare(sql){return new Statement(this,sql,[]);}
  async batch(statements){this.db.exec('BEGIN');try{const r=statements.map(s=>s.execute());this.db.exec('COMMIT');return r;}
    catch(e){this.db.exec('ROLLBACK');throw e;}}
}
class Statement {
  constructor(db,sql,values){Object.assign(this,{db,sql,values});}
  bind(...values){return new Statement(this.db,this.sql,values);}
  execute(){const s=this.db.db.prepare(this.sql);return /^\s*SELECT/i.test(this.sql)?{results:s.all(...this.values)}:{results:[],meta:s.run(...this.values)};}
  async first(){return this.execute().results[0]??null;}
  async run(){return this.execute();}
}
const folder=mkdtempSync(join(tmpdir(),'fatepair-sharing-')),file=join(folder,'sharing.sqlite');
let db,now=new Date('2026-11-14T12:00:00Z');
const handler=createHandler({now:()=>now});
const token=n=>n.toString(36).padStart(32,'x');
const host={name:'Alex',element:0,traits:[0,1],counts:[2,1,1,1,1]};
const friend={name:'Sam',element:4,traits:[1,2],counts:[1,0,1,2,4]};
const call=(path,{method='GET',secret,data,ip='198.51.100.10',headers={}}={})=>handler(new Request('https://fatepair.test'+path,
  {method,headers:{'Content-Type':'application/json','CF-Connecting-IP':ip,...(secret?{Authorization:'Bearer '+secret}:{}),...headers},
    ...(data!==undefined?{body:typeof data==='string'?data:JSON.stringify(data)}:{})}),{DB:db});
const create=(n,extra={})=>call('/api/shares',{method:'POST',secret:token(n+10000),data:{id:token(n),kind:'pair',portrait:host,consent:true,...extra}});
const joinLink=(n,who=20000,portrait=friend)=>call('/api/shares/'+token(n)+'/join',{method:'POST',secret:token(who),data:{portrait,consent:true}});
before(()=>{db=new SQLiteD1(file);db.db.exec(readFileSync(new URL('../drizzle/0001_sharing.sql',import.meta.url),'utf8'));});
after(()=>{db.db.close();rmSync(folder,{recursive:true,force:true});});

test('real file-backed database: two devices complete a comparison without disclosing birth inputs or credentials',async()=>{
  assert.equal((await create(1)).status,201);
  const publicBefore=await call('/api/shares/'+token(1));
  const p=await publicBefore.json();assert.equal(p.portrait.name,'Alex');assert.equal(p.status,'open');
  assert.equal(publicBefore.headers.get('cache-control'),'no-store');
  assert.equal((await joinLink(1)).status,200);
  const publicAfter=await (await call('/api/shares/'+token(1))).json();assert.equal(publicAfter.result,undefined);
  const owner=await (await call('/api/shares/'+token(1),{secret:token(10001)})).json();
  const guest=await (await call('/api/shares/'+token(1),{secret:token(20000)})).json();
  assert.deepEqual(owner.result,guest.result);assert.equal(guest.result.guest.name,'Sam');assert.equal(guest.result.unknownTime,true);
  assert.ok(guest.result.prompt.endsWith('?'));assert.equal(guest.result.score,undefined);
  for(const value of [owner,guest,publicAfter])for(const forbidden of ['owner_hash','guest_hash','secret','birth','location','zone','conversation'])
    assert.ok(!Object.keys(value).includes(forbidden));
  const raw=db.db.prepare('SELECT * FROM share_links WHERE id=?').get(token(1));
  assert.ok(!JSON.stringify(raw).includes(token(10001)));assert.equal(raw.owner_hash.length,64);
});
test('creation, acceptance and open events are idempotent and aggregate metrics contain no person IDs',async()=>{
  await create(2);await create(2);
  await call('/api/shares/'+token(2)+'/open',{method:'POST'});
  await call('/api/shares/'+token(2)+'/open',{method:'POST'});
  await joinLink(2,20001);await joinLink(2,20001);
  const metrics=db.db.prepare('SELECT * FROM share_metrics').all();
  assert.equal(metrics.find(x=>x.event==='created').n,2);
  assert.equal(metrics.find(x=>x.event==='completed').n,2);
  assert.equal(metrics.find(x=>x.event==='opened').n,1);
  assert.ok(metrics.every(x=>Object.keys(x).join(',')==='day,event,kind,n'));
  assert.equal((await create(3,{parentId:token(2)})).status,201);
  assert.equal(db.db.prepare("SELECT n FROM share_metrics WHERE event='onward_created'").get().n,1);
});
test('only the first participant can join, retries cannot replace a participant summary',async()=>{
  await create(4);
  const responses=await Promise.all([joinLink(4,21001),joinLink(4,21002)]);
  assert.deepEqual(responses.map(x=>x.status).sort(),[200,409]);
  const winner=responses[0].status===200?21001:21002;
  assert.equal((await joinLink(4,winner,{...friend,name:'Replacement'})).status,409);
  assert.equal((await call('/api/shares/'+token(4),{secret:token(77777)})).status,401);
  assert.equal((await joinLink(4,10004)).status,409);
});
test('owner or participant can withdraw; a public link cannot delete or read private results',async()=>{
  for(const [id,who] of [[5,10005],[6,22000]]) {
    await create(id);await joinLink(id,22000);
    assert.equal((await call('/api/shares/'+token(id),{method:'DELETE',secret:token(90000)})).status,401);
    assert.equal((await call('/api/shares/'+token(id),{method:'DELETE',secret:token(who)})).status,200);
    assert.equal((await call('/api/shares/'+token(id))).status,410);
    assert.equal((await call('/api/shares/'+token(id),{method:'DELETE',secret:token(who)})).status,200);
    assert.equal(db.db.prepare('SELECT * FROM share_links WHERE id=?').get(token(id)),undefined);
  }
});
test('portrait sharing excludes distribution and cannot be joined',async()=>{
  const portrait={name:'A friend',element:1,traits:[]};
  assert.equal((await create(7,{kind:'portrait',portrait})).status,201);
  assert.equal((await joinLink(7)).status,409);
  const p=await (await call('/api/shares/'+token(7))).json();assert.equal(p.portrait.counts,undefined);
  assert.equal((await create(8,{kind:'portrait'})).status,400);
});
test('strict schema rejects raw birth data, scripts, impossible summaries and missing consent',async()=>{
  for(const extra of [
    {consent:false},{birth:'1997-06-18'},{portrait:{...host,birth:'1997-06-18'}},
    {portrait:{...host,name:'<script>alert(1)</script>'}}, {portrait:{...host,name:'A\u202eB'}},
    {portrait:{...host,element:5}}, {portrait:{...host,counts:[1,1,1,1,1]}},
    {portrait:{...host,traits:[0,0]}},{portrait:{...host,traits:[0,1,2]}}
  ])assert.equal((await create(9,extra)).status,400,JSON.stringify(extra));
  assert.equal((await call('/api/shares',{method:'POST',secret:token(9),data:'x'.repeat(5000)})).status,413);
  assert.equal((await call('/api/shares',{method:'POST',secret:token(9),data:'{}',headers:{'Content-Type':'text/plain'}})).status,415);
  assert.equal((await call('/api/shares/../../../foo')).status,404);
  assert.equal((await call('/api/shares',{method:'OPTIONS'})).status,204);
});
test('limits are shared across handler instances and reject excess creation without another record',async()=>{
  for(let i=0;i<20;i++)assert.equal((await call('/api/shares',{method:'POST',secret:token(50000+i),ip:'198.51.100.99',
    data:{id:token(100+i),kind:'pair',portrait:host,consent:true}})).status,201);
  const denied=await call('/api/shares',{method:'POST',secret:token(50020),ip:'198.51.100.99',
    data:{id:token(120),kind:'pair',portrait:host,consent:true}});
  assert.equal(denied.status,429);assert.equal(db.db.prepare('SELECT id FROM share_links WHERE id=?').get(token(120)),undefined);
});
test('reopening the database retains shared results; expiry hides and purges them',async()=>{
  db.db.close();db=new SQLiteD1(file);
  assert.ok((await (await call('/api/shares/'+token(1),{secret:token(10001)})).json()).result);
  now=new Date('2026-11-21T12:00:00Z');
  assert.equal((await call('/api/shares/'+token(1),{secret:token(10001)})).status,410);
  assert.equal(db.db.prepare('SELECT COUNT(*) AS n FROM share_links').get().n,0);
});
test('all element combinations produce nonfatalistic discussion prompts, including identical distributions',()=>{
  for(let i=0;i<5;i++)for(let j=0;j<5;j++) {
    const a={...host,element:i,counts:[0,0,0,0,0]},b={...friend,element:j,counts:[0,0,0,0,0]};a.counts[i]=8;b.counts[j]=8;
    const r=pairReading(a,b);assert.ok(r.prompt.length>20);assert.equal(r.score,undefined);
    assert.ok(!JSON.stringify(r).includes('undefined'));
  }
  assert.equal(pairReading(host,host).differenceTitle,'Similar elements, different people');
});

test('invitation HTML fetches the asset root internally without an index.html redirect',async()=>{
  const response=await createHandler()(new Request('https://fatepair.test/s/'+token(42)),{
    ASSETS:{fetch:async request=>{
      assert.equal(new URL(request.url).pathname,'/');
      return new Response('<html>flutter_bootstrap.js</html>',{headers:{'Content-Type':'text/html'}});
    }}
  });
  assert.equal(response.status,200);assert.equal(response.headers.get('Location'),null);
  assert.equal(response.headers.get('Cache-Control'),'no-store');
  assert.equal(response.headers.get('Referrer-Policy'),'no-referrer');
  assert.ok((await response.text()).includes('flutter_bootstrap.js'));
});
