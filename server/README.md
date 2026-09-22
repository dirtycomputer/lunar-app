# Local preview and DeepSeek adapter

Requires Node 20+ (native fetch / AbortSignal.timeout) and a Flutter Web build in `build/web`.

The running session uses the key supplied by the user in process memory. It is not saved in a file, compiled into Flutter, sent to the browser, or logged. Restarting that process requires supplying the key again.

For a new session, use a secret environment variable supplied outside source control:

```sh
node server/proxy.mjs
```

Set `DEEPSEEK_API_KEY` through your secret manager/shell environment before starting. Alternatively, `--key-stdin` reads a single line. The script below prompts without echo and pipes it without putting it in process arguments or shell history:

```sh
./scripts/preview.sh
```

Open http://127.0.0.1:5199. The same process serves the app and API, avoiding CORS. Without a key, offline chart tools still work and the model status reports not_configured.

Routes:
- `GET /api/model/info`: safe provider status, available model IDs, default choice.
- `POST /api/model/chat/completions`: fixed DeepSeek destination; requires `X-Lunar-Client: studio`. `model: auto` resolves to the discovered Flash model when available.

This is a local development adapter, not a production authentication boundary. It binds loopback only, validates Host/Origin and the custom request header, limits body size and concurrent requests, times out upstream calls and redacts upstream errors. Other local programs may call it. Production needs authenticated users, authorization, quotas, rate limiting, TLS, secret management, telemetry redaction and retention controls. No model key should be embedded in a released mobile/Web client.

Native clients: set `--dart-define=LUNAR_MODEL_BASE_URL=https://your-authenticated-backend/api/model` when building, or use Model settings. The default loopback address is for local development and does not refer to the developer machine from a physical phone/Android emulator. An HTTPS provider or a separately configured development network proxy is needed there. Android INTERNET permission is included; no broad cleartext/ATS exception is added.

Calculated evidence is sent only on Generate; connection testing sends a small test packet without chart data. Evidence omits names, exact birth dates and birthplace. It still contains personal chart information. Local settings/charts use unencrypted SharedPreferences; client keys are memory-only. Provider retention is governed by the provider. Local reset does not revoke the server key or erase provider data.
