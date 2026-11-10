# Verification record

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
