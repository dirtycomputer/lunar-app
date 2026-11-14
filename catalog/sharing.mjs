// Bearer links contain only an explicitly shared elemental summary. Owner and
// participant credentials never appear in URLs, public GETs, metrics or logs.
const DAY = 86400, tokenPattern = /^[A-Za-z0-9_-]{32}$/;
const elements = ['Wood', 'Fire', 'Earth', 'Metal', 'Water'];
const qualities = ['growth', 'warmth', 'steadiness', 'clarity', 'curiosity'];
const questions = [
  'What is something new you would like us to try together?',
  'What makes you feel appreciated, and how do you like to show it?',
  'What small ritual would help us make time for each other?',
  'Which boundary helps you feel comfortable being yourself?',
  'When you need space to think, how can I support you?'
];
const jsonShare = (body, status = 200) => new Response(status===204?null:JSON.stringify(body), {
  status, headers: {'Content-Type': 'application/json; charset=utf-8',
    'Cache-Control':'no-store', 'Referrer-Policy':'no-referrer',
    'X-Content-Type-Options':'nosniff', 'X-Robots-Tag':'noindex, nofollow',
    'Access-Control-Allow-Origin':'*',
    'Access-Control-Allow-Methods':'GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers':'Authorization, Content-Type'}
});
class ShareError extends Error {
  constructor(code,status=400){super(code);this.code=code;this.status=status;}
}
const hash = async text => Array.from(new Uint8Array(await crypto.subtle.digest(
  'SHA-256', new TextEncoder().encode(text))), b=>b.toString(16).padStart(2,'0')).join('');
const assert = (ok,code='invalid_input') => {if(!ok)throw new ShareError(code);};
function credential(request) {
  const value=(request.headers.get('Authorization')||'').replace(/^Bearer /,'');
  if(!tokenPattern.test(value))throw new ShareError('unauthorized',401);
  return value;
}
async function body(request) {
  if(!(request.headers.get('Content-Type')||'').startsWith('application/json'))
    throw new ShareError('json_required',415);
  const reader=request.body?.getReader(); if(!reader)throw new ShareError('invalid_input');
  let size=0,parts=[];
  while(true){const {done,value}=await reader.read();if(done)break;
    size+=value.length;if(size>4096){await reader.cancel();throw new ShareError('too_large',413);}parts.push(value);}
  try {const bytes=new Uint8Array(size);let i=0;for(const p of parts){bytes.set(p,i);i+=p.length;}
    const value=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));
    assert(value&&typeof value==='object'&&!Array.isArray(value));return value;
  }catch(e){if(e instanceof ShareError)throw e;throw new ShareError('invalid_input');}
}
function keys(value,allowed) {assert(Object.keys(value).every(k=>allowed.includes(k)));}
function portrait(value,pair) {
  assert(value&&typeof value==='object'&&!Array.isArray(value));
  keys(value,['name','element','traits','counts']);
  assert(typeof value.name==='string'&&value.name===value.name.trim()&&
    [...value.name].length>=1&&[...value.name].length<=30&&
    !/[\p{Cc}\p{Cf}<>]/u.test(value.name));
  assert(Number.isInteger(value.element)&&value.element>=0&&value.element<5);
  assert(Array.isArray(value.traits)&&value.traits.length<=2&&
    value.traits.every(x=>Number.isInteger(x)&&x>=0&&x<3)&&
    new Set(value.traits).size===value.traits.length);
  if(pair) {
    assert(Array.isArray(value.counts)&&value.counts.length===5&&
      value.counts.every(x=>Number.isInteger(x)&&x>=0&&x<=8)&&
      [6,8].includes(value.counts.reduce((a,b)=>a+b,0))&&value.counts[value.element]>0);
  }else assert(value.counts==null);
  return {name:value.name,element:value.element,traits:[...value.traits].sort(),
    ...(pair?{counts:value.counts}:{})};
}
export function pairReading(host,guest) {
  const a=host.counts.map(n=>n/host.counts.reduce((x,y)=>x+y,0));
  const b=guest.counts.map(n=>n/guest.counts.reduce((x,y)=>x+y,0));
  const shared=a.map((v,i)=>Math.min(v,b[i]));
  const common=shared.indexOf(Math.max(...shared));
  const delta=a.map((v,i)=>Math.abs(v-b[i]));
  const difference=delta.indexOf(Math.max(...delta));
  const same=delta.every(x=>x<0.001);
  return {host,guest,
    commonTitle:Math.max(...shared)>0?`Room for ${qualities[common]}`:'A wider palette',
    commonText:Math.max(...shared)>0?
      `Both summaries include ${elements[common]}. In the Five Elements tradition it represents ${qualities[common]}. Explore whether that feels familiar to you both.`:
      'Your summaries emphasize different elements. Start by finding one interest you already share.',
    differenceTitle:same?'Similar elements, different people':`Two ways to bring ${qualities[difference]}`,
    differenceText:same?'Your element proportions are alike. Your experiences and preferences can still be very different. Ask each other what these words miss.':
      `${a[difference]>b[difference]?host.name:guest.name} has more ${elements[difference]} in this summary. That is a difference in the chart, not a stronger or better personality. Compare how you each approach ${qualities[difference]}.`,
    prompt:questions[same?common:difference],
    unknownTime:host.counts.reduce((a,b)=>a+b,0)===6||guest.counts.reduce((a,b)=>a+b,0)===6,
    method:'Element conversation v1. Equal counts of the visible stems and branch main elements; missing birth hours are omitted. Symbolic reflection, not a relationship prediction.'};
}
function metric(db,day,event,kind,condition='1',values=[]) {
  return db.prepare(`INSERT INTO share_metrics(day,event,kind,n) SELECT ?,?,?,1 WHERE ${condition}
    ON CONFLICT(day,event,kind) DO UPDATE SET n=n+1`).bind(day,event,kind,...values);
}
async function limits(db,request,now,action,max) {
  const day=new Date(now*1000).toISOString().slice(0,10);
  const ip=request.headers.get('CF-Connecting-IP')||'unavailable';
  const bucket=await hash(day+'|'+ip)+'|'+action;
  const global=day+'|global-'+action;
  const results=await db.batch([
    db.prepare('INSERT INTO share_limits(bucket,n,expires_at) VALUES(?,1,?) ON CONFLICT(bucket) DO UPDATE SET n=n+1').bind(bucket,now+2*DAY),
    db.prepare('INSERT INTO share_limits(bucket,n,expires_at) VALUES(?,1,?) ON CONFLICT(bucket) DO UPDATE SET n=n+1').bind(global,now+2*DAY),
    db.prepare('SELECT bucket,n FROM share_limits WHERE bucket IN (?,?)').bind(bucket,global)
  ]);
  if(results[2].results.some(r=>r.n>(r.bucket===bucket?max:10000)))throw new ShareError('rate_limited',429);
}
export async function handleSharing(request,env,{now=()=>new Date()}={}) {
  const path=new URL(request.url).pathname;
  if(!(path==='/api/shares'||path.startsWith('/api/shares/')))return null;
  if(request.method==='OPTIONS')return jsonShare(null,204);
  try {
    if(!env.DB)throw new ShareError('unavailable',503);
    const db=env.DB,ts=Math.floor(now().getTime()/1000),day=new Date(ts*1000).toISOString().slice(0,10);
    await db.batch([
      db.prepare('DELETE FROM share_links WHERE id IN (SELECT id FROM share_links WHERE expires_at<=? LIMIT 500)').bind(ts),
      db.prepare('DELETE FROM share_limits WHERE bucket IN (SELECT bucket FROM share_limits WHERE expires_at<=? LIMIT 500)').bind(ts),
      db.prepare('DELETE FROM share_metrics WHERE day<?').bind(new Date((ts-90*DAY)*1000).toISOString().slice(0,10))
    ]);
    const parts=path.split('/').filter(Boolean),id=parts[2],action=parts[3];
    if(parts.length>4|| (id&&!tokenPattern.test(id)))throw new ShareError('not_found',404);
    if(!id&&request.method==='POST') {
      const ownerHash=await hash(credential(request));
      const value=await body(request);keys(value,['id','kind','portrait','consent','parentId']);
      assert(value.consent===true&&tokenPattern.test(value.id)&&['portrait','pair'].includes(value.kind));
      const profile=portrait(value.portrait,value.kind==='pair');
      const data=JSON.stringify(profile);
      const existing=await db.prepare('SELECT * FROM share_links WHERE id=?').bind(value.id).first();
      if(existing){
        if(existing.owner_hash!==ownerHash||existing.kind!==value.kind||existing.portrait_json!==data)
          throw new ShareError('conflict',409);
        return jsonShare({id:value.id,expiresAt:existing.expires_at},200);
      }
      await limits(db,request,ts,'create',20);
      // Attribution is an aggregate event only; no referral graph is retained.
      let onward=false;
      if(value.parentId!=null){
        assert(tokenPattern.test(value.parentId));
        onward=!!await db.prepare('SELECT id FROM share_links WHERE id=? AND expires_at>?').bind(value.parentId,ts).first();
      }
      await db.batch([
        db.prepare('INSERT INTO share_links(id,owner_hash,kind,portrait_json,created_at,expires_at) VALUES(?,?,?,?,?,?) ON CONFLICT(id) DO NOTHING')
          .bind(value.id,ownerHash,value.kind,data,ts,ts+7*DAY),
        metric(db,day,'created',value.kind,'changes() = 1'),
        ...(onward?[metric(db,day,'onward_created',value.kind,'changes() = 1')]:[])
      ]);
      const saved=await db.prepare('SELECT owner_hash,portrait_json,expires_at FROM share_links WHERE id=?').bind(value.id).first();
      if(saved.owner_hash!==ownerHash||saved.portrait_json!==data)throw new ShareError('conflict',409);
      return jsonShare({id:value.id,expiresAt:saved.expires_at},201);
    }
    if(!id)throw new ShareError('method_not_allowed',405);
    const row=await db.prepare('SELECT * FROM share_links WHERE id=? AND expires_at>?').bind(id,ts).first();
    if(!row){if(request.method==='DELETE'&&!action){credential(request);return jsonShare({deleted:true});}
      throw new ShareError('expired_or_missing',410);}
    if(request.method==='GET'&&!action) {
      let authorized=false;
      if(request.headers.has('Authorization')) {
        const h=await hash(credential(request));authorized=h===row.owner_hash||h===row.guest_hash;
        if(!authorized)throw new ShareError('unauthorized',401);
      }
      const host=JSON.parse(row.portrait_json);
      return jsonShare({id,kind:row.kind,portrait:host,expiresAt:row.expires_at,
        status:row.guest_hash?'complete':'open',
        ...(authorized&&row.guest_json?{result:pairReading(host,JSON.parse(row.guest_json))}:{})});
    }
    if(request.method==='POST'&&action==='open') {
      await limits(db,request,ts,'open',200);
      await db.batch([
        db.prepare('UPDATE share_links SET opened_at=? WHERE id=? AND opened_at IS NULL').bind(ts,id),
        metric(db,day,'opened',row.kind,'changes() = 1')
      ]);return jsonShare({recorded:true});
    }
    if(request.method==='POST'&&action==='join') {
      const guestHash=await hash(credential(request));
      if(row.kind!=='pair'||guestHash===row.owner_hash)throw new ShareError('conflict',409);
      const value=await body(request);keys(value,['portrait','consent']);assert(value.consent===true);
      const guest=portrait(value.portrait,true),guestJson=JSON.stringify(guest);
      if(row.guest_hash&&(row.guest_hash!==guestHash||row.guest_json!==guestJson))throw new ShareError('already_joined',409);
      if(!row.guest_hash) {
        await limits(db,request,ts,'join',60);
        await db.batch([
          db.prepare('UPDATE share_links SET guest_hash=?,guest_json=? WHERE id=? AND guest_hash IS NULL AND expires_at>?')
            .bind(guestHash,guestJson,id,ts),
          metric(db,day,'completed','pair','changes() = 1')
        ]);
      }
      const saved=await db.prepare('SELECT * FROM share_links WHERE id=? AND expires_at>?').bind(id,ts).first();
      if(!saved)throw new ShareError('expired_or_missing',410);
      if(saved.guest_hash!==guestHash)throw new ShareError('already_joined',409);
      return jsonShare({id,kind:'pair',portrait:JSON.parse(saved.portrait_json),status:'complete',expiresAt:saved.expires_at,
        result:pairReading(JSON.parse(saved.portrait_json),JSON.parse(saved.guest_json))});
    }
    if(request.method==='DELETE'&&!action) {
      const h=await hash(credential(request));
      if(h!==row.owner_hash&&h!==row.guest_hash)throw new ShareError('unauthorized',401);
      await db.prepare('DELETE FROM share_links WHERE id=? AND (owner_hash=? OR guest_hash=?)').bind(id,h,h).run();
      return jsonShare({deleted:true});
    }
    throw new ShareError('method_not_allowed',405);
  } catch(e) {
    return e instanceof ShareError?jsonShare({code:e.code},e.status):jsonShare({code:'unavailable'},503);
  }
}
