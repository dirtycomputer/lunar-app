# Chart-first DeepSeek service

The default analysis pipeline is:

1. Receive the complete conversation, birth inputs, selected clock convention, current reading, and question.
2. Calculate the chart with **lunar-python 1.4.9**. Use the physical UTC+8 instant for solar-term year/month boundaries, and the selected civil / mean solar / apparent solar clock for day/hour. Reject DST gaps, choose the earlier repeated instant, and omit the unknown hour.
3. Compare the submitted Four Pillars against the server calculation. A mismatch stops generation.
4. Send the verified chart, current periods, fortune-cycle information where birth time is known, and full user context to DeepSeek.
5. Return the final answer. Internal reasoning and service keys are not returned.

## Model

The official API model name is **`deepseek-flash`**, which serves **DeepSeek-V4.1-Flash-1017**, with a **1M-token context window**. Requests set `thinking: {type: "enabled"}` and `reasoning_effort: "max"`. The final-answer budget is 32,768 tokens including provider reasoning. A request has up to 260 seconds upstream and a 285-second client timeout.

References checked on 2026-11-10:

- https://api-docs.deepseek.com/quick_start/pricing
- https://api-docs.deepseek.com/guides/thinking_mode

History is never reduced to the last few turns. Earlier questions include snapshots of their original reading context. Transport is limited to 4,000,000 UTF-8 bytes per incoming request, below the Vercel Function body limit; very large conversations or provider context-limit errors are reported explicitly. This transport limit is separate from the model's 1M-token capability. No history is silently discarded.

## Local setup

```sh
python3 -m venv server/.venv
server/.venv/bin/pip install -r server/requirements.txt
FATEPAIR_PYTHON=./server/.venv/bin/python ./scripts/preview.sh
```

`preview.sh` prompts for the key without echo and passes it on stdin. The Node preview serves `build/web` and starts the Python service on loopback port 5301 when a key is supplied. All completions use the Python service; the preview has no separate direct-provider path that skips verification. With no key, offline charts still work and the preview reports `not_configured`.

Alternatively, provide `DEEPSEEK_API_KEY` through your secret manager and run the Python service directly:

```sh
cd server
uvicorn api.index:app --host 127.0.0.1 --port 5301 --no-access-log
```

The key stays in the server process. Do not put it in Flutter defines, frontend files, command arguments, source control, or logs. `.env.example` lists names only.

## Deployment

The Vercel project `fatepair-api` uses this `server` directory as its root, `api/index.py` as the Python entrypoint, and a 300-second function duration. `DEEPSEEK_API_KEY` is a sensitive Production runtime variable. A repository Actions secret is separate: GitHub does not automatically copy it into Vercel runtime configuration.

Public Production API access is authorized for `fatepair-api`; Preview deployments retain Vercel SSO protection. The Production origin is `https://fatepair-api-buaa42wxys-projects.vercel.app`. No authentication credential is embedded in Flutter.

Once the endpoint is available to intended users, build **all platforms**, including Web, with the returned API origin:

```sh
flutter build web --release --dart-define=LUNAR_MODEL_BASE_URL=https://YOUR_API_ORIGIN/api/model
```

iOS and Android use the same define. The default proxy setting is migrated to that configured endpoint; explicitly customized model endpoints are preserved.

## Data and access

Personal analysis sends names, birth date/time/place/timezone, chart conventions, current reading, and full prior conversation. Users are informed in the birth editor and Privacy page. The service does not persist request data or log request bodies. Provider retention is governed by DeepSeek. Local reset does not erase provider records or revoke a service credential.

Only the configured DeepSeek model and destination are used; client input cannot disable thinking or select a different model. The service validates browser origins, headers, body size, and chart inputs, limits concurrent generations to two per instance and bursts to six per minute per IP per instance. CORS is not authentication, and in-process limits are not a global or account-level quota. A public production launch still needs durable user authorization and quotas, consistent with the app's prototype scope.

## Runtime maintenance

FastAPI 0.162.4 and Starlette 1.10.0 replace the older Starlette runtime with public advisories. `requirements.txt` pins the complete tested Python runtime dependency set. After updates, run the service tests and `python3 scripts/audit_dependencies.py` from the repository root. The latter sends only public package/version metadata to OSV and does not prove application or infrastructure security.

## Checks

```sh
python -m unittest discover -s server/tests -v
dart run scripts/export_chart_fixtures.dart > server/tests/fixtures/charts.json
```

The shared fixtures compare the Python implementation against the Flutter engine across global birthplaces, solar-term boundaries, clock conventions, late Rat hour, DST, and unknown hour. Tests also cover full-history preservation, verification before generation, max reasoning, CORS, redacted errors, oversized context, and incomplete generation.
