# Verification record

## Friend sharing — 2026-11-14

- Clean Flutter analysis; **118 Flutter tests** pass, including URL routing, reduced chart snapshots, consent, failed save/no request, ambiguous network retry after restart, acknowledgement failure, corrupt-entry recovery, concurrent create/reset, offline withdrawal, credential-free export, expiry and large-text layouts.
- **20 file-backed SQLite/API tests** pass (11 catalog, 9 sharing), including cross-device result retrieval, missing/invalid credentials, single-participant races, idempotency, strict input/body bounds, shared rate limits, both withdrawal roles and expiry after reopening the real database file.
- **23 Python chart-service tests** pass. The existing full-context DeepSeek / lunar-python service remains unchanged.
- Three friend-sharing renderer walkthroughs at 1440×1000, 390×844 and 320×740 / 200% complete invitation → profile with unknown hour → explicit summary consent → shared result → onward invitation. **15 captures**; selected evidence in `output/flutter-render/sharing-*.png`. These use API fixtures only for deterministic rendering; production has no fallback data.
- Release Web build succeeds with local renderer assets; preview package checks pass. CI native compilation and live publication are recorded below when completed. Browser and actual OS share-sheet acceptance remain unverified.


## Persistent D1 catalog — 2026-11-12

- Live Cloudflare D1: `DB` binding, `catalog_people` and `catalog_seed_runs` confirmed independently through the Sites database viewer. Live API traversal verifies all 1,000 persisted profiles and dataset revision. SQL aggregates cover 40 countries, six continents, ages 18–75 and 400/400/200 gender counts; unknown birth times: 100.
- Repeated live verification after deployment preserves the same dataset digest: `6ef5b47b9549f8b69f19f551b2020d5a02d468c460b0d08ca1bc5e5133a4c62c`. Full profile data stays in the ignored renderer input; the small report is committed. SQLite export: 1,462,272 bytes, integrity `ok`, 1,000 rows after reopening.
- **102 Flutter tests**, including all 1,000 Python-vs-Dart chart snapshots, bounded pagination, invalid/change/duplicate responses, failed load/retry, saved IDs/drafts and concurrent profile edits. The dataset is excluded from the Flutter bundle; default AppState uses the live API.
- **23 Python tests** independently verify all seed instants/pillars and reject trusting altered client-resolved metadata. **11 Node tests** run the Worker against an actual file-backed SQLite database: paging, predicates, wildcard/injection handling, idempotence, reopen, readiness, token removal and the default closed write gate.
- Four renderer walkthroughs use the fetched D1 records at desktop, phone, 320px/200% text and Chinese phone sizes. All 16 captures pass, including country/non-binary filtering, filtered random matching, accessible profile closing and loading more. Selected screenshots: `output/flutter-render/catalog-*.png`. They are Flutter renderer evidence, not browser acceptance.
- Web/Worker builds and preview package checks are recorded in current output logs. Browser control, local Xcode/Android SDK and signed store/device acceptance remain unavailable or separate from CI compilation. No real-member release gates are removed.

## Frontend design UI update — 2026-11-12

- Followed the official frontend-design skill: deliberate cobalt/cloud/jade palette, bundled Manrope/Noto typography, two-route layout sketch and pre-implementation critique in [ui-design.md](ui-design.md).
- `flutter analyze` is clean; all **94 Flutter tests** pass. Reading now reveals its conclusion first; expand/collapse coverage checks the full remaining explanation is accessible. Existing full-context questions, keyboard layouts, saved progress, matching, reset and retry checks remain active.
- `flutter test --update-goldens test/render/capture_ui.dart test/render/capture_garden.dart` passes **10 walkthroughs**, producing **75 actual Flutter renderer captures**. Core pages cover 1440×1000 desktop, 390×844 phone, 320×740 / 200% text, Chinese phone and 844×390 / 120% landscape. The complete garden also covers legacy progress. Portraits and all font weights are loaded before capture.
- Observed word splitting at large text and excessive mobile reading length were fixed and re-rendered. Selected evidence: `output/flutter-render/ui-*.png`; logs: `output/ui-render-results.txt`, `output/test-results.txt`, `output/ui-web-build.txt`.
- Web release uses the existing public Production API and local CanvasKit/fonts. `python3 scripts/check_release.py --channel preview` passes. Backend/dependency configuration is unchanged; final native/Python checks are visible in the PR's Quality workflow.
- Browser QA is not performed: the current managed executor has no `cua_repl.js`/supported browser-control tool. Per the Sites workflow no alternate server/browser path is started. Native compilation is checked by CI, not by this Linux executor. Real-community production gates remain in place.

## Element Garden redesign — 2026-11-11

- `flutter analyze`: no issues. All **94 Flutter tests** pass. The full supporting cycle is exercised for every starting element, with atomic step/seal/reward persistence, migration, resume, replay, failure recovery and clearing. Widget coverage verifies tap and drag, unlocked field notes, the phone inventory above Continue, and the narrow larger-text route through the sample profile.
- Five additional renderer walkthroughs pass: desktop 1440 × 1000, phone 390 × 844, narrow 320 × 740 with 160% text and reduced motion, Chinese on phone, and a restored legacy completion record on desktop. All three discoveries complete in each run. **40 captures** show map, field notes, puzzle, hints, a restored link, completion, collection and final bloom. Selected evidence: `output/flutter-render/garden-*.png`.
- Reproduce with `flutter test --update-goldens test/render/capture_garden.dart`. It loads bundled text/icon fonts, drives actual widget interactions, and writes to `output/garden/`. These are Flutter-renderer captures, not browser screenshots.
- The final Web release builds with local CanvasKit and the existing Production model origin. No server/model, compatibility algorithm, dependencies or external access settings change. Native compile results are recorded in the PR's existing Quality workflow.
- The managed environment is running/connected with current observations, but still exposes no supported `cua_repl.js`/browser-control tool (`ccarenv_b64_Y2NhcmVudl83MzJlMTAxZDcyMmM4MTkxYjE0ZTg5NGJhMWI4ODFmZQ`). The Sites workflow requires skipping browser QA in that condition. Native physical-device and browser acceptance remain unverified. Existing real-community/operating-info blockers are not removed.


## Release-hardening loops — 2026-11-11

- Five documented use/review → feedback → repair → regression loops are recorded in `docs/release-review.md`. Updated `product.md` describes recovery, truthful preview behavior, and the conditions for a real community launch in natural language.
- `flutter analyze`: no issues. All **84 Flutter tests** pass. New coverage includes cross-store concurrent writes/deletion, failure injection and restart, portable exports, startup recovery, exact-context retry, cancellation/stale responses, and accessibility with a simulated keyboard.
- A timestamped OSV audit covers **65 pinned Python/Pub packages**, with no matching advisories after upgrading FastAPI/Starlette. Runtime/transitive Python versions are pinned; the repeatable audit is included in CI.
- All **20 Python service tests** pass, including the shared global-calendar fixtures and rejection of malformed/boolean calendar inputs. Model/version, maximum reasoning and the full-history pipeline are retained.
- Five additional Flutter renderer runs pass: the whole Journey at 1440 × 1000 and 390 × 844, plus chart → Match → Agent → settings → privacy at 320 × 740 / 200% text, 844 × 390 / 120%, and 1440 × 1000 / 100%. These produce 27 captures; selected evidence is in `output/flutter-render/release-*.png`. Bundled Manrope, Chinese and icon fonts are loaded.
- The final Web release builds with local CanvasKit and the existing public Production API origin. `scripts/check_release.py --channel preview` passes; `--channel production` intentionally fails and lists the open gates in `release/launch.json`.
- GitHub CI run `42961686811` passed Flutter analysis/tests/Web, Python tests, Android debug compilation and an unsigned iOS simulator build for the unchanged Flutter source. The service dependency update is checked again on the final commit, and native test artifacts are uploaded. Current CI outcomes are visible in [Quality](https://github.com/dirtycomputer/lunar-app/actions/workflows/quality.yml). Store signing/acceptance and physical-device validation remain separate release gates.
- Browser interaction is not re-tested: managed environment `ccarenv_b64_Y2NhcmVudl83MzJlMTAxZDcyMmM4MTkxYjE0ZTg5NGJhMWI4ODFmZQ` is running/connected but exposes no supported browser-control tool. Local Android SDK and Xcode are unavailable. No preview-server/browser workaround was used.
- The database integration request returned Vercel `403 forbidden`; real accounts/community/messaging, durable model quotas and operational moderation remain unconnected. The user confirmed that operator/contact details are **not yet determined**. This update does not claim production readiness.


## Light exploration update — 2026-11-11

- An optional three-discovery Journey: learn the supporting relationship for the current chart element, read an outlook, and explore a profile. Anonymous practice is labelled as a sample. Every task can be selected directly; charts and people remain accessible through their original entry points.
- Correct answers reveal the element pair with instant feedback; hints and unlimited retries are available. Each discovery awards 20 sparks once. Replays, concurrent completion, restart/restoration, damaged records, failed storage, local reset, and unchanged chart/matching results are covered.
- All 69 Flutter tests pass and analysis is clean. Two additional rendering runs complete the whole journey on desktop (1440 × 1000) and phone (390 × 844), generating 18 screenshots. Larger text and reduced motion are covered by widget tests. Web release builds with the existing Production API origin.
- Screenshot captures use the Flutter test renderer, not a browser. The current managed environment `ccarenv_b64_Y2NhcmVudl83MzJlMTAxZDcyMmM4MTkxYjE0ZTg5NGJhMWI4ODFmZQ` reports a remote desktop enabled with state unknown, but does not offer `cua_repl.js` or another supported browser-control tool. Browser interaction was not re-tested in this update. The existing backend is unchanged.
- Visual evidence is in `output/flutter-render/`; automated output is in `output/test-results.txt` and `output/exploration-render-results.txt`.

## Chart-first DeepSeek integration — 2026-11-10

- All 60 Flutter tests and 18 Python service tests pass. Twenty shared birth fixtures match on Four Pillars, Ten Gods, hidden stems, clock instants, and known-hour fortune start.
- Live local HTTP requests: two DeepSeek responses return HTTP 200, with `deepseek-flash`, `reasoning_effort: max`, enabled thinking, and `lunar-python 1.4.9` chart verification. Follow-up includes the complete prior conversation. Provider usage confirms reasoning tokens. Only final answers are returned.
- Model alias/version, 1M context and supported max effort are verified against current official DeepSeek documentation and the live `/models` API.
- No six-turn truncation; per-question snapshots preserve the original page context. Oversized context is rejected explicitly. Birth-input sharing disclosures were updated.
- Chromium app flow with the live local Python service: birth setup → chart → contextual Agent → model answer → follow-up passes, with `verifiedChartCount: 1`, `contextMessages: 4`, max reasoning, zero page errors and no failed resources.
- Production API access is explicitly authorized and enabled; Preview backend deployments retain SSO protection. Unauthenticated Production info and two chart-analysis requests return HTTP 200, with one verified chart, max reasoning, and 2 → 4 context messages. The Flutter release is configured with the same Production API origin.

## FatePair focused-flow update — 2026-11-10

- Two primary first-use cards and a secondary Ask Agent action; remembered entry route and return-to-start control. Root `product.md` records the natural-language product baseline; `AGENTS.md` requires synchronized updates for substantial product changes.
- My chart and Match are the core destinations; Agent is a supporting destination. No Discover hero, energy sidebar, wisdom panel, or explanatory heading subtitles in the primary flows.
- Matching exposes a vertical people list, one reason grounded in score components for each recommendation, and a filter-aware random action. Saved profiles, invitations, and messages are secondary tabs. Fictional-profile labelling appears before the list.
- My chart exposes reading conclusions before Four Pillars, with optional recent outlook and collapsed detailed tables. Day master terminology opens a contextual explanation. Asking from a reading keeps the chart in place, using a desktop side dialog or a phone bottom sheet. Advanced tools remain available without occupying primary navigation.
- Agent requests include the question, recent conversation turns, and computed chart evidence. Reference answers are explicitly labelled; unconfigured static hosting does not pretend to have a live model.
- `flutter analyze`: no issues. `flutter test --reporter expanded`: 59 tests pass. Web release uses local CanvasKit, fonts, and a static unconfigured model-status response for hosting without a proxy.
- New checks cover intent persistence/reset, eligible random draws without consecutive repeats, transit relationships, professional model context, stale-response cancellation, three-destination phone navigation, first-chart form validation, each main user path, preservation of the chart during contextual questions, and phone question entry with keyboard insets.

- Chromium desktop (1440 × 1000) and phone (390 × 844): first-use choices, birth setup, conclusion-first reading, term explanation, recent outlook, inline questions and follow-up, vertical recommendations, sample notice, filtered random selection, and remembered entry pass. No page errors or failed resource requests. Screenshots: `output/playwright/fatepair-*.png`; summary: `output/fatepair-browser-check.txt`.
- This update retains the iOS/Android projects; native builds and live provider calls were not repeated.

## Repository integration — 2026-11-10

The combined app is based on `dirtycomputer/lunar-app` at `a49179f`, using its existing Flutter 3.27.1 / Dart 3.6.0 toolchain and locked dependencies.

- `flutter analyze`: no issues.
- `flutter test --reporter expanded`: all 50 tests pass (42 existing + 8 social/search regression tests).
- Web release build: local CanvasKit, bundled fonts, and no registered service worker.
- New regressions cover separate saved/invited state, restoration, Unicode and length validation, concurrent draft saves, damaged-record recovery, privacy reset, discovery search, hidden conversations, desktop invite/message flows, and a narrow phone composer with keyboard insets.
- The existing Chart Studio, calendar conventions, model-transport tests, multilingual settings, legal center, and moderation tests remain in the full suite.
- Chromium at 1440 × 1100 and 390 × 844: search, saving, invitation creation, local message composition, refresh/restoration, the Connections hub, and Chart Studio pass. No page errors or failed resource requests.
- Bundled the missing circled-information symbol so profile/chart links no longer request an external font.
- The local model proxy reports `configured: false` / `status: not_configured` without credentials; this integration does not repeat the historical live-provider calls below.
- Native builds were not rerun: this Linux environment does not have Xcode or an Android SDK. The existing platform projects are preserved.

## Earlier project validation

Validated with Flutter 3.27.1 / Dart 3.6.0; Node local proxy on port 5199.

- `flutter analyze`: no issues.
- `flutter test --reporter expanded`: all 37 tests pass. Full run: `output/test-results.txt`.
- Flutter Web release with local CanvasKit and no service worker: builds successfully.
- `flutter build ios --simulator --no-codesign`: builds successfully; `output/ios-build.txt`.
- `node --check server/proxy.mjs` and `bash -n scripts/preview.sh`: pass.
- Source and Web-bundle scan: no provider-key patterns in source, docs, tests, scripts or generated JavaScript.
- Android release build is not validated; its INTERNET permission is included.

## Behavior checked

The tests cover the known 2005-12-23 08:37 UTC+8-meridian fixture (乙酉/戊子/辛巳/壬辰), hidden stems and Ten Gods, growth stages, palace data, seasonal boundaries at Li Chun, physical solar terms remaining independent of longitude correction, midnight/23:00 day conventions, DST gaps and folds, equation-of-time extrema, unknown-hour omission, all twelve month ranges in four representative years, fortune direction/start, cross-chart triples with repeated branches, symbolic-star bases, 2026 Five Movements/Six Qi, lunar leap months, almanac hour coverage, endpoint validation, model request styles, error redaction, local-key exclusion, persistence/reset, mobile studio navigation and date-editor calendar switching.

Browser verification used desktop 1440 × 1000 and phone 390 × 844:

- Opened the detailed natal chart and inspected Chinese/English rendering.
- Opened a recommended profile and selected “Compare our full charts”; the studio imported both demo subjects.
- DeepSeek `/models` reported ready with `deepseek-flash` and `deepseek-v4-pro`.
- Browser connection test returned HTTP 200.
- Generated the two-demo-chart plain-English comparison through the UI; POST returned HTTP 200, `deepseek-flash`, and `finish_reason: stop`; the panel visibly changed to Custom model interpretation.
- Generated a professional natal-chart interpretation from the final element-labeled evidence packet; POST returned HTTP 200 and the panel displayed Custom model interpretation with Professional selected.
- Fresh browser console: 0 errors and 0 warnings.
- Confirmed the model key is absent from client settings/evidence; only the proxy holds the supplied key. Unit tests verify names, exact birth dates and places are omitted from evidence.
- Tested the five-item phone navigation and fixed its previously wrapping Connections label to Saved.
- Bundled the CanvasKit default-family fallback so a fresh browser session loads fonts locally without a Google Fonts request.
- Removed automatic service-worker registration from the preview bootstrap to avoid startup timeout/stale preview behavior.

Screenshots: `output/playwright/studio-desktop.png`, `studio-mobile.png`, `deepseek-comparison.png`, `studio-mobile-reading.png`. Earlier captures may show the navigation label before its final shortening.

These checks validate the implemented conventions, not every historical date or equivalence to Wen Zhen’s proprietary implementation. The model response was checked for delivery and display, not certified for interpretive accuracy. Remaining feature scope is in `docs/open-source-audit.md`.
