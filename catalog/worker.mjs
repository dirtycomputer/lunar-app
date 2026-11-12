import seed from './seed.json' with { type: 'json' };

const columns = 'id,name,gender,country_code,country,continent,birth_date,location,search_text,time_known,seed_version,record_hash,data_json';
const cors = {'Access-Control-Allow-Origin':'*','Access-Control-Allow-Methods':'GET, OPTIONS'};
const json = (body,status=200,extra={}) => new Response(JSON.stringify(body), {
  status,headers:{'Content-Type':'application/json; charset=utf-8',
    'Cache-Control':status===200?'public, max-age=60':'no-store',
    'X-Content-Type-Options':'nosniff',...cors,...extra}});
class InputError extends Error {}
function integer(value,fallback,min,max) {
  if(value===null)return fallback;
  if(!/^\d+$/.test(value)||Number(value)<min||Number(value)>max)throw new InputError('Invalid numeric filter.');
  return Number(value);
}
const validId = value => /^[a-zA-Z0-9_-]{1,48}$/.test(value);
const ageExpression = "CAST(strftime('%Y', ?) AS INTEGER) - CAST(substr(birth_date,1,4) AS INTEGER) - (strftime('%m-%d', ?) < substr(birth_date,6,5))";

async function authorized(request,token) {
  if(!token || token.length<32)return false;
  const supplied=request.headers.get('Authorization')||'';
  if(!supplied.startsWith('Bearer ')||supplied.length>200)return false;
  const digest=async value=>new Uint8Array(await crypto.subtle.digest('SHA-256',new TextEncoder().encode(value)));
  const [a,b]=await Promise.all([digest(supplied.slice(7)),digest(token)]);
  return a.reduce((different,value,i)=>different|(value^b[i]),0)===0;
}

export function createHandler({now=()=>new Date(),allowSeeding=false}={}) {
  return async function fetch(request,env) {
    const url=new URL(request.url),path=url.pathname;
    const admin=path==='/api/admin/catalog/seed';
    const api=path==='/api/people'||path.startsWith('/api/people/');
    if(!admin&&!api) {
      return env.ASSETS ? env.ASSETS.fetch(request) : new Response('Not found',{status:404});
    }
    if(request.method==='OPTIONS'&&!admin)return new Response(null,{status:204,headers:cors});
    if(request.method!==(admin?'POST':'GET'))return json({error:'Method not allowed.'},405,{'Allow':admin?'POST':'GET, OPTIONS'});
    try {
      if(!env.DB)return json({error:'Catalog database unavailable.'},503);
      if(admin) {
        if(!allowSeeding || !await authorized(request,env.CATALOG_SEED_TOKEN))return json({error:'Unauthorized.'},401);
        const offset=integer(url.searchParams.get('offset'),0,0,950);
        if(offset%50!==0)throw new InputError('Seed offset must be a multiple of 50.');
        const chunk=seed.people.slice(offset,offset+50),statements=[];
        // Three rows per statement stay below D1's bound-parameter limit.
        for(let i=0;i<chunk.length;i+=3) {
          const values=chunk.slice(i,i+3).map(({profile:p,hash})=>[
            p.id,p.name,p.gender,p.countryCode,p.country,p.continent,p.birth.date,p.location,
            [p.name,p.location,p.occupation,...p.interests,...p.languages].join(' ').toLowerCase(),
            p.birth.timeKnown?1:0,seed.revision,hash,JSON.stringify(p)]);
          statements.push(env.DB.prepare(`INSERT INTO catalog_people (${columns}) VALUES ${values.map(()=>'(?,?,?,?,?,?,?,?,?,?,?,?,?)').join(',')} ON CONFLICT(id) DO NOTHING`).bind(...values.flat()));
        }
        await env.DB.batch(statements);
        const count=await env.DB.prepare('SELECT COUNT(*) AS n FROM catalog_people WHERE seed_version=?').bind(seed.revision).first();
        if(count.n===seed.expectedCount) {
          await env.DB.prepare('INSERT INTO catalog_seed_runs(revision,expected_count) VALUES(?,?) ON CONFLICT(revision) DO NOTHING').bind(seed.revision,seed.expectedCount).run();
        }
        return json({revision:seed.revision,stored:count.n,complete:count.n===seed.expectedCount,nextOffset:offset+50<seed.expectedCount?offset+50:null},200,{'Cache-Control':'no-store'});
      }
      const ready=await env.DB.prepare('SELECT revision,expected_count,completed_at FROM catalog_seed_runs WHERE revision=?').bind(seed.revision).first();
      if(!ready)return json({error:'Catalog is not ready. Try again shortly.',code:'catalog_not_ready'},503,{'Retry-After':'5'});
      const today=now().toISOString().slice(0,10);
      if(path==='/api/people/stats') {
        const queries=[
          env.DB.prepare(`SELECT COUNT(*) AS total, SUM(time_known=0) AS unknownBirthTime, MIN(${ageExpression}) AS youngest,MAX(${ageExpression}) AS oldest FROM catalog_people WHERE seed_version=?`).bind(today,today,today,today,seed.revision),
          env.DB.prepare('SELECT gender AS value,COUNT(*) AS count FROM catalog_people WHERE seed_version=? GROUP BY gender ORDER BY gender').bind(seed.revision),
          env.DB.prepare('SELECT country_code AS code,country AS value,COUNT(*) AS count FROM catalog_people WHERE seed_version=? GROUP BY country_code,country ORDER BY country').bind(seed.revision),
          env.DB.prepare('SELECT continent AS value,COUNT(*) AS count FROM catalog_people WHERE seed_version=? GROUP BY continent ORDER BY continent').bind(seed.revision),
          env.DB.prepare(`SELECT CASE WHEN age<25 THEN '18–24' WHEN age<35 THEN '25–34' WHEN age<45 THEN '35–44' WHEN age<55 THEN '45–54' WHEN age<65 THEN '55–64' ELSE '65+' END AS value,COUNT(*) AS count FROM (SELECT ${ageExpression} AS age FROM catalog_people WHERE seed_version=?) GROUP BY value ORDER BY value`).bind(today,today,seed.revision),
        ];
        const results=await env.DB.batch(queries);
        return json({storage:'cloudflare-d1',synthetic:true,revision:ready.revision,seededAt:ready.completed_at,
          ...results[0].results[0],genders:results[1].results,countries:results[2].results,
          continents:results[3].results,ageBands:results[4].results});
      }
      if(path.startsWith('/api/people/')) {
        const id=decodeURIComponent(path.slice('/api/people/'.length));
        if(!validId(id))throw new InputError('Invalid profile ID.');
        const row=await env.DB.prepare('SELECT data_json FROM catalog_people WHERE id=? AND seed_version=?').bind(id,seed.revision).first();
        return row?json({revision:ready.revision,person:JSON.parse(row.data_json)}):json({error:'Profile not found.'},404);
      }
      const params=url.searchParams;
      const limit=integer(params.get('limit'),200,1,200);
      const min=integer(params.get('min_age'),18,18,80),max=integer(params.get('max_age'),80,18,80);
      if(min>max)throw new InputError('Minimum age exceeds maximum age.');
      const clauses=['seed_version=?',`${ageExpression} BETWEEN ? AND ?`];
      const bindings=[seed.revision,today,today,min,max];
      const gender=params.get('gender'),country=params.get('country'),q=params.get('q');
      if(gender!==null) {
        if(!['Women','Men','Non-binary'].includes(gender))throw new InputError('Invalid gender filter.');
        clauses.push('gender=?');bindings.push(gender);
      }
      if(country!==null) {
        if(!/^[A-Z]{2}$/.test(country))throw new InputError('Use a two-letter country code.');
        clauses.push('country_code=?');bindings.push(country);
      }
      if(q!==null) {
        if(q.length>80)throw new InputError('Search is too long.');
        clauses.push("search_text LIKE ? ESCAPE '\\'");
        bindings.push('%'+q.toLowerCase().replace(/[\\%_]/g,'\\$&')+'%');
      }
      const where=clauses.join(' AND '),after=params.get('after');
      if(after!==null&&!validId(after))throw new InputError('Invalid cursor.');
      const query=`SELECT id,data_json FROM catalog_people WHERE ${where}${after!==null?' AND id>?':''} ORDER BY id LIMIT ?`;
      const [count,page]=await env.DB.batch([
        env.DB.prepare(`SELECT COUNT(*) AS total FROM catalog_people WHERE ${where}`).bind(...bindings),
        env.DB.prepare(query).bind(...bindings,...(after!==null?[after]:[]),limit+1)
      ]);
      const rows=page.results.slice(0,limit);
      return json({revision:ready.revision,synthetic:true,storage:'cloudflare-d1',total:count.results[0].total,
        people:rows.map(r=>JSON.parse(r.data_json)),nextCursor:page.results.length>limit?rows.at(-1).id:null});
    } catch(error) {
      if(error instanceof InputError||error instanceof URIError)return json({error:error.message},400);
      return json({error:'Catalog unavailable. Try again.',code:'catalog_unavailable'},503);
    }
  };
}

export default {fetch:createHandler()};
