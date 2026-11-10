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
// All live analysis goes through the Python chart-first service.
const service = process.env.FATEPAIR_MODEL_SERVICE || 'http://127.0.0.1:5301';
const serviceUrl = new URL(service);
if (!['127.0.0.1', 'localhost'].includes(serviceUrl.hostname) || serviceUrl.protocol !== 'http:') {
  throw new Error('The local chart service must use loopback HTTP.');
}
let python;
if (key && !process.env.FATEPAIR_MODEL_SERVICE) {
  const { spawn } = await import('node:child_process');
  const pythonCommand = process.env.FATEPAIR_PYTHON || 'python3';
  python = spawn(pythonCommand.includes('/') ? path.resolve(pythonCommand) : pythonCommand,
    ['-m', 'uvicorn', 'api.index:app', '--host', '127.0.0.1', '--port', '5301', '--no-access-log'],
    { cwd: path.dirname(fileURLToPath(import.meta.url)),
      env: { ...process.env, DEEPSEEK_API_KEY: key }, stdio: ['ignore', 'inherit', 'inherit'] });
  python.on('error', () => console.error('Python service could not start. Install server/requirements.txt and set FATEPAIR_PYTHON.'));
  python.on('exit', code => {
    if (code) { console.error('The chart service failed to start or stopped. Check its dependencies and port 5301.'); process.exit(1); }
  });
  for (const name of ['SIGINT', 'SIGTERM']) {
    process.on(name, () => { python.kill('SIGTERM'); process.exit(0); });
  }
  process.on('exit', () => python.kill('SIGTERM'));
}
const contentTypes = { '.html':'text/html; charset=utf-8', '.js':'application/javascript', '.json':'application/json', '.wasm':'application/wasm', '.png':'image/png', '.jpg':'image/jpeg', '.svg':'image/svg+xml', '.ttf':'font/ttf', '.otf':'font/otf' };
const server = http.createServer(async (req, res) => {
  const host = req.headers.host;
  if (![`127.0.0.1:${port}`, `localhost:${port}`].includes(host)) { res.writeHead(403); res.end(); return; }
  const url = new URL(req.url, `http://${host}`);
  const reply = (status, data) => { res.writeHead(status, {'Content-Type':'application/json','Cache-Control':'no-store'}); res.end(JSON.stringify(data)); };
  if (url.pathname.startsWith('/api/model')) {
    if (req.headers.origin && ![`http://127.0.0.1:${port}`, `http://localhost:${port}`].includes(req.headers.origin)) {
      reply(403, { error: { code: 'origin_not_allowed' } }); return;
    }
    const info = req.method === 'GET' && url.pathname === '/api/model/info';
    const chat = req.method === 'POST' && url.pathname === '/api/model/chat/completions';
    if (!info && !chat) { reply(404, { error: { code: 'not_found' } }); return; }
    if (!key && !process.env.FATEPAIR_MODEL_SERVICE) {
      reply(info ? 200 : 503, info
        ? { provider: 'DeepSeek', configured: false, status: 'not_configured', models: [], defaultModel: null }
        : { error: { code: 'model_not_configured' } }); return;
    }
    if (chat && req.headers['x-lunar-client'] !== 'studio') {
      reply(403, { error: { code: 'missing_client_header' } }); return;
    }
    let bytes = 0, chunks = [];
    try {
      for await (const chunk of req) {
        bytes += chunk.length;
        if (bytes > 4000000) { reply(413, { error: { code: 'context_too_large' } }); return; }
        chunks.push(chunk);
      }
      const abort = new AbortController();
      res.once('close', () => { if (!res.writableEnded) abort.abort(); });
      const upstream = await fetch(new URL(url.pathname, serviceUrl), {
        method: req.method,
        headers: { 'Content-Type': 'application/json', 'X-Lunar-Client': 'studio',
          ...(req.headers.origin ? { Origin: req.headers.origin } : {}) },
        ...(chat ? { body: Buffer.concat(chunks) } : {}),
        signal: AbortSignal.any([abort.signal, AbortSignal.timeout(285000)])
      });
      const data = await upstream.json();
      reply(upstream.status, data);
    } catch {
      if (!res.destroyed) reply(503, { error: { code: 'chart_service_unavailable' } });
    }
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
console.log('Live analysis uses lunar-python before DeepSeek; provider credentials are never sent to the browser.');
