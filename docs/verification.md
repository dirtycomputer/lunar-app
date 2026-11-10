# Verification record

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
