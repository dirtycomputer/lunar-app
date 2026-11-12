# FatePair

An English-language Flutter app for BaZi charts, recent outlook, matching, and chart-grounded Agent questions. Built with Material 3, cobalt and jade accents, original elemental companions, bundled Manrope typography, and responsive mobile / desktop layouts.

## Run

Developed and checked with Flutter 3.27.1 / Dart 3.6.0.

```sh
flutter pub get
flutter run -d chrome
```

To run on an iOS simulator or Android device, select a configured device from `flutter devices` and run `flutter run -d <device-id>`. Platform projects are included. Native signing and store submission are not configured for production.

```sh
flutter analyze
flutter test
flutter build web --release --web-renderer canvaskit --no-web-resources-cdn --pwa-strategy=none
./scripts/preview.sh
```

Open http://127.0.0.1:5199 after building. Web renderer resources and fonts are bundled locally. The people catalog loads from the hosted D1 API, including on iOS and Android; it has no local profile-list fallback.

## Chart Studio

Professional four-pillar table, solar-time options, fortune-cycle drilldown, symbolic stars and palaces, two-chart comparison, almanac/date filtering, Five Movements/Six Qi, a small sourced classical library, and custom model explanations in plain English or professional language.

The default chart service selects `deepseek-flash` (DeepSeek-V4.1-Flash-1017) with maximum reasoning. Model settings also accepts compatible custom/local endpoints. This is a working local implementation, not full feature parity with Wen Zhen. See the [open-source audit and complete scope matrix](docs/open-source-audit.md) for rules, sources and unimplemented auxiliary tools.

## Product requirements

[`product.md`](product.md) is the product baseline. Substantial changes to user flows must update that document in natural language. Repository contributors follow [`AGENTS.md`](AGENTS.md).

[`docs/ui-design.md`](docs/ui-design.md) records the visual direction and review against the brief, applying the official frontend-design guidance. Reproduce the core UI and garden renderer walkthroughs with `flutter test --update-goldens test/render/capture_ui.dart test/render/capture_garden.dart`; these use bundled fonts and are not browser acceptance tests.

## Release quality

The current public release is a **preview**, with an explicit production gate in [`release/launch.json`](release/launch.json). [`docs/release-review.md`](docs/release-review.md) records the use → feedback → fix → regression loops and the remaining infrastructure/operational blockers. `python3 scripts/check_release.py --channel preview` checks package integrity; the `production` channel intentionally fails until the open gates have evidence.

A shared device-storage coordinator orders writes across profiles, drafts, consents, progress and Chart Studio. A durable deletion marker prevents interrupted deletion or queued writes restoring old personal data. Startup and deletion have retry paths. Questions also support retry with the original context and without duplicate turns. Chart reports are cached while page context changes. Data exports include comparison charts and language, excluding model keys.

Pinned Python and Pub dependencies are queried against OSV through `scripts/audit_dependencies.py`; network/incomplete responses and findings fail the audit. The timestamped result is `output/dependency-audit.json`.

GitHub Actions runs Flutter/Python checks, a Web release, an Android debug build and an unsigned iOS simulator build, with downloadable native test artifacts. These compilation checks do not replace store signing, current store requirements, browser acceptance or physical-device release testing. Android releases use a local ignored `key.properties`, with no debug-signing fallback; see `android/key.properties.example`.

## Working features

- A persistent Cloudflare D1 catalog with 1,000 explicitly synthetic adults across 40 countries, six continents and ages 18–75. Public SQL-backed list/detail/statistics APIs support paging and filters. Catalog records use initials and independently verified lunar-python chart snapshots, including historical birth instants. See [catalog operations](catalog/README.md).

- Optional Element Garden: an original five-habitat map, a tap/drag supporting-cycle puzzle, waking guardians, a five-seal collection and readable field notes. Each of five links saves immediately; old rewards migrate and replay never duplicates sparks. All three discoveries remain freely selectable and clear with local data.

- First-use chooser with two primary cards, My reading and Match, plus a secondary Ask Agent action. The chosen starting task is remembered.
- Two core tasks, My chart and Match, with Agent as a supporting destination.
- Focused Match page with a vertical people list, one computed recommendation reason per person, filter-aware random matching, and search/filters.
- My chart opens with a reading conclusion and expandable details. Reading and Four Pillars sit side by side on desktop and stack on phones; recent outlook switches between day, month, and year transits. Detailed chart tables are collapsed by default. Day master terminology can be explained in place.
- Contextual questions open beside the current reading on desktop or in a phone bottom sheet, preserving the reading position. Agent also accepts general questions before birth setup and chart-specific questions with follow-ups using computed chart evidence and complete conversation history. Without a configured provider it shows labelled chart-reference answers.
- Advanced Chart Studio tools are available from My chart → Tools; model settings, language, privacy, and guide remain in Settings.
- Live cultural harmony scoring, not hard-coded percentages.
- Filter by gender, age, country, and minimum harmony.
- Save / unsave connections, inspect match breakdowns, and hide profiles.
- Search discovery by name, city/country, occupation, or interests.
- Secondary Saved, Invitations, and Messages tabs within Match.
- Local-only invitations, withdrawal, conversation previews, and persistent message drafts with an icebreaker. No messages are delivered.
- Validated adult birth profile, date picker, optional birth time, 16 global birthplaces, and custom birthplace with IANA zone and longitude.
- Historical time-zone and daylight-saving handling.
- Four Pillars, day master, visible element distribution, and English guide.
- Local persistence and explicit local-data reset.
- Custom illustration and Material 3 UI for phones, tablets, and desktop browsers.

## Scope

This version is a preview with 1,000 synthetic profiles in a real hosted D1 database, device-local social interactions, and no live community or messaging transport. Your own birth profile and local drafts use unencrypted SharedPreferences. Public catalog data is separate from those private device records; clearing local data does not remove the shared synthetic catalog. Agent history stays in memory for the session and resets when birth details change or local data is cleared. Exploration progress is local, exported and cleared with local data; the question context includes learning progress as app context. Sparks do not alter chart calculations or recommendation scores.

The new analysis service verifies birth charts with lunar-python before sending verified evidence and the user's complete session context to DeepSeek-V4.1-Flash-1017 (official API name `deepseek-flash`, 1M context, maximum reasoning). Context includes name, birth inputs, chart convention, current reading, and all earlier turns; typed text is not automatically redacted. Service keys are server-only. See [chart service setup, deployment protection, and limits](server/README.md). The public App uses the Production chart service; Preview backend deployments retain their access protection.

A real launch requires backend authentication and profiles, mutual consent and messaging, moderation/reporting, verification and age assurance, secure handling of birth data, server-side recommendation processing, retention/deletion controls, and production privacy documentation.

## Yuan MVP integration

This repository is the canonical project for the combined app. The integration starts from `a49179f` and keeps the repository’s Manrope/Material 3 design, `lunar` 1.7.8 engine, local mean-solar-time convention, Chart Studio, model adapter, existing localization, platform configuration, and seeded community. The earlier Yuan prototype contributes the invitation/message-preview flow and discovery search; its separate calendar/scoring implementation is not copied over.

The original Discover hero, duplicate energy overview, wisdom panel, and heading subtitles have been removed from the main flows.

Invitations and local message drafts use the versioned `social.v1` preference. Writes are serialized and published to the UI only after successful storage. Hiding/reporting a profile removes it from the Connections hub; its local drafts remain in the data export until a confirmed local-data reset removes them. Reset also clears invitations and drafts while preserving the chosen language and unrelated preferences.

New task-flow and social strings are translated into English and Simplified Chinese; other existing locales currently use generated English fallbacks for these new strings. Saved, Invitations, and Messages are secondary tabs inside **Match**.

The hosted Flutter app calls the public Production chart service. Offline charts, comparisons, matching and local social features work without credentials. The service credential is provisioned only on the backend, never in Flutter. See `server/README.md` for the chart-first local preview and deployment setup.

## Chart convention

Uses the `lunar` calendar package and the IANA database from `timezone`:

1. Resolve the entered wall-clock time in the birthplace time zone.
2. Reject times skipped by a daylight-saving clock change. For repeated clock-change times, prefer the earlier occurrence.
3. Evaluate year/month solar-term boundaries at the corresponding UTC+8 instant, matching the calendar package's solar-term convention.
4. Calculate day/hour using local **mean** solar time: UTC + longitude × 4 minutes per degree. Chart Studio additionally allows civil time or apparent solar time using a NOAA equation-of-time approximation.
5. Default to sect 2: the day pillar changes at midnight; Chart Studio also supports sect 1 (23:00). Late Rat-hour handling follows the package.
6. If birth time is unknown, use local noon for date evaluation, omit the hour pillar, and label the result approximate. Solar-term boundary dates may remain uncertain.

This is one explicitly chosen convention. Other schools use different solar-time and day-boundary rules. Visible element distribution does not model hidden stems, seasonal strength, useful gods, or a complete traditional chart reading.

## Harmony score

A deterministic, explainable **cultural heuristic**, not a scientific prediction of personality, attraction, or relationship success:

- **45% element balance:** normalized Shannon entropy of the two charts' averaged visible element distributions.
- **35% day master connection:** generating-cycle neighbors score 96, same element 82, controlling-cycle pairs 60.
- **20% day branch resonance:** six-combination pairs score 98, shared trine group 88, opposition 50, other pairs 72.

Recommendations sort by total score descending, with a stable profile-ID tiebreaker. Unknown birth times change the available elements and therefore make the resulting score approximate.

## Browser verification

The earlier model-integration flows were exercised with Playwright in Chromium at 1440 × 1000 and 390 × 844: two primary entry cards, birth setup, reading-first chart, contextual glossary, outlook, inline questions and a follow-up, vertical recommendations, sample labelling, filtered random matching, and remembered entry. There were no page errors or failed resource requests. Earlier browser screenshots are `output/playwright/fatepair-*.png`. The exploration update uses Flutter-rendered desktop/phone captures in `output/flutter-render/`, alongside the widget flow tests; browser interaction could not be repeated because the supported browser-control tool was unavailable. See `docs/verification.md`.

## Structure

- `lib/models/profile.dart`: birth data, global birthplace presets and validated catalog records. Historical synthetic births retain the server-resolved instant; the analysis server independently recalculates inputs.
- `lib/services/people_repository.dart`: bounded D1 API pagination and complete-snapshot validation; six-person fixtures are test-only.
- `lib/services/bazi.dart`: chart calculation and explainable ranking.
- `lib/services/app_state.dart`: reactive app state and validated profile updates.
- `lib/services/device_storage.dart`: shared write ordering, crash-safe deletion intent and typed reads.
- `lib/services/data_export.dart`: portable device data export without session credentials.
- `lib/services/social.dart`: serialized, local-only invitation and message-draft storage.
- `lib/ui/social_pages.dart`: local conversation preview.
- `lib/ui/design.dart`: theme, reusable surfaces, brand illustration, element ring.
- `lib/ui/app_shell.dart`: intent-based navigation, the focused people list, filtering, random matching, and saves.
- `lib/ui/intent_pages.dart`: first-use chooser, Four Pillars, reading, and recent outlook.
- `lib/ui/agent_page.dart`: conversation and question composer.
- `lib/ui/journey.dart`: the compact Garden entry badge.
- `lib/ui/element_garden.dart` and `lib/ui/garden_guide.dart`: garden map, free task routing and field notes.
- `lib/ui/garden_workshop.dart`: tap/drag cycle gameplay, hints, per-link feedback and completion.
- `lib/ui/garden_art.dart` and `lib/ui/element_art.dart`: original vector habitats and waking element guardians.
- `test/render/capture_garden.dart`: repeatable renderer walkthroughs for desktop, phone, larger text and Chinese. Run with `flutter test --update-goldens test/render/capture_garden.dart`; captures go to `output/garden/`. These are Flutter-renderer captures, not browser screenshots.
- `lib/services/journey.dart`: serialized one-time awards, v1/v2 progress migration, per-link resume and seal collection.
- `lib/services/chart_assistant.dart`: computed context, reference answers, full-history snapshots, model routing, and cancellation.
- `server/chart_engine.py` and `server/api/index.py`: authoritative lunar-python calculation and chart-first DeepSeek analysis.
- `lib/ui/profile_editor.dart`: validated birth data editor.
- `lib/ui/profile_detail.dart`: profile and match breakdown.
- `lib/ui/secondary_pages.dart`: optional BaZi guide and privacy controls.

## Validation

Automated checks cover calculation fixtures, solar-term boundaries, selected time/day conventions, historical DST, unknown hour, cross-chart relations, Five Movements/Six Qi, lunar leap months, model transport/error handling, privacy/reset, and desktop/mobile flows. The exploration update passed 69 Flutter tests; the release-hardening checks add failure/retry, concurrent persistence, interrupted deletion, startup recovery and accessibility regressions. The Python service now also rejects malformed/boolean calendar inputs. Current command results are recorded in the verification record. Desktop and phone Chromium checks cover the main paths. Native builds and live provider calls were not repeated in this Linux environment; the earlier project validation is recorded separately. See [verification record](docs/verification.md); full test output is in `output/test-results.txt`. Browser screenshots are in `output/playwright/`.

## References and assets

- Material 3: https://docs.flutter.dev/ui/design/material
- Noto Sans SC: https://github.com/google/fonts/tree/main/ofl/notosanssc (OFL; subset and license bundled).
- Calendar library: https://pub.dev/packages/lunar (MIT)
- Time-zone library: https://pub.dev/packages/timezone
- Manrope: https://github.com/google/fonts/tree/main/ofl/manrope (SIL Open Font License; included in `assets/fonts/OFL.txt`).
- Profile photographs from Unsplash, used only for illustrative fictional profiles:
  - Maya: https://images.unsplash.com/photo-1534528741775-53994a69daeb
  - Leo: https://images.unsplash.com/photo-1506794778202-cad84cf45f1d
  - Sofia: https://images.unsplash.com/photo-1524504388940-b1c1722653e1
  - Noah: https://images.unsplash.com/photo-1500648767791-00dcc994a43e
  - Aisha: https://images.unsplash.com/photo-1524250502761-1ac6f2e30d43
  - Ethan: https://images.unsplash.com/photo-1535713875002-d1d0cf377fde

The people pictured are not represented as actual FatePair members. The flower mark and orbit illustration are drawn in Flutter and have no external image dependency.
