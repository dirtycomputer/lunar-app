import http from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import readline from 'node:readline';

const port = Number(process.env.PORT || 5199);
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../build/web');
let key = process.env.DEEPSEEK_API_KEY || '';
if (process.argv.includes('--key-stdin')) {
  process.stdout.write('Waiting for provider key on stdin (not logged or stored)…\n');
  const input = readline.createInterface({ input: process.stdin, terminal: false });
  key = await new Promise(resolve => input.once('line', line => { input.close(); resolve(line.trim()); }));
}
const provider = 'https://api.deepseek.com';
let models = [], providerStatus = key ? 'checking' : 'not_configured';
async function discover() {
  if (!key) return;
  try {
    const response = await fetch(`${provider}/models`, { headers: { Authorization: `Bearer ${key}` }, signal: AbortSignal.timeout(15000) });
    if (!response.ok) { providerStatus = `http_${response.status}`; return; }
    const json = await response.json();
    models = (json.data || []).map(m => m.id).filter(m => typeof m === 'string');
    providerStatus = models.length ? 'ready' : 'no_models';
  } catch { providerStatus = 'unreachable'; }
}
const modelChoice = () => models.find(m => m === 'deepseek-flash') || models.find(m => /flash/.test(m)) || models.find(m => m === 'deepseek-chat') || models[0];
const contentTypes = { '.html':'text/html; charset=utf-8', '.js':'application/javascript', '.json':'application/json', '.wasm':'application/wasm', '.png':'image/png', '.jpg':'image/jpeg', '.svg':'image/svg+xml', '.ttf':'font/ttf', '.otf':'font/otf' };
let active = 0;
const server = http.createServer(async (req, res) => {
  const host = req.headers.host;
  if (![`127.0.0.1:${port}`, `localhost:${port}`].includes(host)) { res.writeHead(403); res.end(); return; }
  const url = new URL(req.url, `http://${host}`);
  const reply = (status, data) => { res.writeHead(status, {'Content-Type':'application/json','Cache-Control':'no-store'}); res.end(JSON.stringify(data)); };
  if (url.pathname.startsWith('/api/model')) {
    if (req.headers.origin && ![`http://127.0.0.1:${port}`,`http://localhost:${port}`].includes(req.headers.origin)) {
      reply(403,{error:'Origin not allowed'}); return;
    }
    if (req.method === 'GET' && url.pathname === '/api/model/info') {
      reply(200,{provider:'DeepSeek',configured:!!key,status:providerStatus,models,defaultModel:modelChoice()||null});return;
    }
    if (req.method !== 'POST' || url.pathname !== '/api/model/chat/completions') { reply(404,{error:'Unknown endpoint'});return; }
    if (req.headers['x-lunar-client'] !== 'studio') { reply(403,{error:'Missing client header'}); return; }
    if (!key) {reply(503,{error:'Model key is not configured on the local server'});return;}
    if (active >= 2) {reply(429,{error:'Two requests are already in progress'});return;}
    let bytes=0, chunks=[];
    try {
      for await (const chunk of req) {bytes+=chunk.length;if(bytes>200000) {reply(413,{error:'Request too large'});return;}chunks.push(chunk);}
      const input=JSON.parse(Buffer.concat(chunks).toString('utf8'));
      const model=input.model==='auto'?modelChoice():input.model;
      if(!model||typeof model!=='string'||(models.length&&!models.includes(model))) {reply(400,{error:'Select an available provider model'});return;}
      if(!Array.isArray(input.messages)||input.messages.length>12||input.messages.some(m=>!['system','user','assistant'].includes(m.role)||typeof m.content!=='string')) {reply(400,{error:'Invalid messages'});return;}
      const abort = new AbortController();
      const timeout = setTimeout(()=>abort.abort(),60000);
      res.once('close',()=>{ if(!res.writableEnded)abort.abort(); });
      active++;
      try {
        const upstream=await fetch(`${provider}/chat/completions`, {method:'POST',headers:{'Content-Type':'application/json',Authorization:`Bearer ${key}`},
          body:JSON.stringify({model,messages:input.messages,stream:false,max_tokens:2000,thinking:{type:'disabled'}}),signal:abort.signal});
        if(!upstream.ok) {reply(upstream.status,{error:`Provider returned HTTP ${upstream.status}`});return;}
        const result=await upstream.json();
        // Only expose the intended answer and usage, not provider internals.
        reply(200,{model:result.model,choices:(result.choices||[]).map(c=>({message:{role:'assistant',content:c.message?.content||''},finish_reason:c.finish_reason})),usage:result.usage});
      } catch {if(!res.destroyed)reply(502,{error:'Provider request failed or timed out'});}
      finally {clearTimeout(timeout);active--;}
    } catch {reply(400,{error:'Invalid JSON request'});}
    return;
  }
  if(!['GET','HEAD'].includes(req.method)){res.writeHead(405);res.end();return;}
  try {
    let location=path.resolve(root, `.${decodeURIComponent(url.pathname)}`);
    if(location!==root&&!location.startsWith(`${root}${path.sep}`)){res.writeHead(403);res.end();return;}
    if((await stat(location)).isDirectory())location=path.join(location,'index.html');
    const data=await readFile(location);
    res.writeHead(200,{'Content-Type':contentTypes[path.extname(location)]||'application/octet-stream','Cache-Control':'no-cache'});
    res.end(req.method==='HEAD'?undefined:data);
  } catch {res.writeHead(404);res.end('Not found');}
});
server.listen(port,'127.0.0.1',()=>console.log(`Lunar preview + model proxy: http://127.0.0.1:${port}`));
await discover();
console.log(`DeepSeek status: ${providerStatus}; available models: ${models.join(', ') || 'none'}`);
