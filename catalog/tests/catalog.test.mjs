import {test,before,after} from 'node:test';
import assert from 'node:assert/strict';
import {DatabaseSync} from 'node:sqlite';
import {mkdtempSync,readFileSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import seed from '../seed.json' with {type:'json'};
import {createHandler} from '../worker.mjs';

// D1 interface over an actual persistent SQLite file; no mocked row responses.
class SQLiteD1 {
  constructor(file){this.db=new DatabaseSync(file);}
  prepare(sql){return new Statement(this,sql,[]);}
  async batch(statements){
    this.db.exec('BEGIN');
    try {
      const results=statements.map(s=>s.execute());
      this.db.exec('COMMIT');return results;
    }catch(e){this.db.exec('ROLLBACK');throw e;}
  }
}
class Statement {
  constructor(owner,sql,values){Object.assign(this,{owner,sql,values});}
  bind(...values){return new Statement(this.owner,this.sql,values);}
  execute(){
    const stmt=this.owner.db.prepare(this.sql);
    return /^\s*SELECT/i.test(this.sql)
      ? {results:stmt.all(...this.values),success:true}
      : {results:[],success:true,meta:stmt.run(...this.values)};
  }
  async all(){return this.execute();}
  async first(){return this.execute().results[0]??null;}
  async run(){return this.execute();}
}

const folder=mkdtempSync(join(tmpdir(),'fatepair-catalog-'));
const file=join(folder,'catalog.sqlite');
const schema=readFileSync(new URL('../drizzle/0000_catalog.sql',import.meta.url),'utf8');
const token='local-test-seed-credential-'.repeat(3);
const handler=createHandler({now:()=>new Date('2026-11-12T12:00:00Z'),allowSeeding:true});
let env;
const call=(path,options={})=>handler(new Request('https://catalog.test'+path,options),env);
const seedChunk=offset=>call('/api/admin/catalog/seed?offset='+offset,{method:'POST',headers:{Authorization:'Bearer '+token}});

before(async()=>{
  env={DB:new SQLiteD1(file),CATALOG_SEED_TOKEN:token};env.DB.db.exec(schema);
  assert.equal((await call('/api/people')).status,503);
  assert.equal((await call('/api/admin/catalog/seed',{method:'POST'})).status,401);
  assert.equal((await seedChunk(0)).status,200);
  assert.equal((await call('/api/people')).status,503);
  for(let offset=50;offset<1000;offset+=50)assert.equal((await seedChunk(offset)).status,200);
});
after(()=>{env.DB.db.close();rmSync(folder,{recursive:true,force:true});});

test('1,000 unique synthetic adults span 40 countries, six continents and three gender identities',()=>{
  const people=seed.people.map(x=>x.profile);
  assert.equal(people.length,1000);assert.equal(new Set(people.map(x=>x.id)).size,1000);
  assert.equal(new Set(people.map(x=>x.name)).size,1000);
  assert.equal(new Set(people.map(x=>x.countryCode)).size,40);
  assert.equal(new Set(people.map(x=>x.continent)).size,6);
  assert.deepEqual(Object.fromEntries(['Women','Men','Non-binary'].map(g=>[g,people.filter(x=>x.gender===g).length])),{'Women':400,'Men':400,'Non-binary':200});
  assert.equal(people.filter(x=>!x.birth.timeKnown).length,100);
  assert.ok(people.every(x=>x.synthetic&&x.image===''&&x.chart.pillars.length===(x.birth.timeKnown?4:3)));
  assert.ok(new Set(people.flatMap(x=>x.languages)).size>=20);
});
test('SQL statistics agree with every stored row and report source truthfully',async()=>{
  const response=await call('/api/people/stats');assert.equal(response.status,200);
  const value=await response.json();assert.equal(value.storage,'cloudflare-d1');
  assert.equal(value.total,1000);assert.equal(value.unknownBirthTime,100);
  assert.equal(value.countries.length,40);assert.ok(value.countries.every(x=>x.count===25));
  assert.equal(value.continents.length,6);assert.equal(value.ageBands.reduce((n,x)=>n+x.count,0),1000);
  assert.equal(value.youngest,18);assert.equal(value.oldest,75);
});
test('cursor pages traverse all 1,000 records once, with a stable total and revision',async()=>{
  const ids=[];let cursor=null,pages=0;
  do {
    const response=await call('/api/people?limit=73'+(cursor?'&after='+cursor:''));
    assert.equal(response.status,200);const page=await response.json();
    assert.equal(page.total,1000);assert.equal(page.revision,seed.revision);
    ids.push(...page.people.map(p=>p.id));cursor=page.nextCursor;pages++;
  }while(cursor);
  assert.equal(pages,14);assert.equal(ids.length,1000);assert.equal(new Set(ids).size,1000);
  assert.deepEqual(ids,[...ids].sort());
});
test('country, gender and age predicates are combined by the database',async()=>{
  const value=await (await call('/api/people?country=JP&gender=Non-binary&min_age=18&max_age=80')).json();
  assert.equal(value.total,5);assert.ok(value.people.every(p=>p.countryCode==='JP'&&p.gender==='Non-binary'));
  const older=await (await call('/api/people?min_age=65&max_age=75')).json();
  assert.ok(older.total>80);
  assert.ok(older.people.every(p=>{
    const d=p.birth.date;const age=2026-Number(d.slice(0,4))-(d.slice(5)>'11-12');return age>=65&&age<=75;
  }));
});
test('search treats wildcard and SQL syntax literally',async()=>{
  const maya=await (await call('/api/people?q=Maya')).json();assert.ok(maya.people.some(p=>p.id==='maya'));
  for(const q of ['%','_',"x%' OR 1=1 --"]){
    const r=await call('/api/people?q='+encodeURIComponent(q));assert.equal(r.status,200);assert.equal((await r.json()).total,0);
  }
});
test('invalid query bounds, identities and unsupported writes are rejected',async()=>{
  for(const query of ['limit=0','limit=201','limit=abc','min_age=17','min_age=60&max_age=30',"country=US'",'gender=invalid',"after=x'",'q='+'x'.repeat(81)])
    assert.equal((await call('/api/people?'+query)).status,400,query);
  assert.equal((await call('/api/people/missing-profile')).status,404);
  assert.equal((await call('/api/people',{method:'POST'})).status,405);
  assert.equal((await call('/api/admin/catalog/seed')).status,405);
});
test('repeating seed batches preserves count, record hashes and completion timestamp',async()=>{
  const before=await env.DB.prepare('SELECT id,record_hash FROM catalog_people ORDER BY id').all();
  const metadata=await env.DB.prepare('SELECT * FROM catalog_seed_runs').first();
  for(const offset of [0,50,950,0])assert.equal((await seedChunk(offset)).status,200);
  assert.deepEqual(await env.DB.prepare('SELECT id,record_hash FROM catalog_people ORDER BY id').all(),before);
  assert.deepEqual(await env.DB.prepare('SELECT * FROM catalog_seed_runs').first(),metadata);
});
test('closing and reopening the SQLite file preserves all profiles without seeding',async()=>{
  env.DB.db.close();env.DB=new SQLiteD1(file);
  const stats=await (await call('/api/people/stats')).json();assert.equal(stats.total,1000);
  const response=await call('/api/people/sofia');assert.equal(response.status,200);
  assert.equal((await response.json()).person.id,'sofia');
});
test('removing the server token closes seed writes and keeps read access',async()=>{
  delete env.CATALOG_SEED_TOKEN;
  assert.equal((await seedChunk(0)).status,401);
  assert.equal((await call('/api/people')).status,200);
  env.CATALOG_SEED_TOKEN=token;
});
test('normal deployment rejects seeding even when an old token binding exists',async()=>{
  const readOnly=createHandler();
  const response=await readOnly(new Request('https://catalog.test/api/admin/catalog/seed',
      {method:'POST',headers:{Authorization:'Bearer '+token}}),env);
  assert.equal(response.status,401);
});
test('public responses expose neither credentials nor SQL internals',async()=>{
  const response=await call('/api/people');const body=await response.text();
  assert.equal(response.headers.get('Access-Control-Allow-Origin'),'*');
  assert.ok(!body.includes(token));assert.ok(!body.includes('record_hash'));
  assert.equal((await call('/api/people',{method:'OPTIONS'})).status,204);
});
