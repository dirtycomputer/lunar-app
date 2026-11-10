# Lunar

An English-language Flutter app for meaningful connections inspired by BaZi and the Five Elements. Built with Material 3, a soft botanical palette, Manrope typography, and responsive mobile / desktop layouts.

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

Open http://127.0.0.1:5199 after building. Web renderer resources, fonts, and profile photos are bundled locally.

## Chart Studio

Professional four-pillar table, solar-time options, fortune-cycle drilldown, symbolic stars and palaces, two-chart comparison, almanac/date filtering, Five Movements/Six Qi, a small sourced classical library, and custom model explanations in plain English or professional language.

The default DeepSeek proxy discovers live model IDs. Model settings accepts compatible custom/local endpoints. This is a working local implementation, not full feature parity with Wen Zhen. See the [open-source audit and complete scope matrix](docs/open-source-audit.md) for rules, sources and unimplemented auxiliary tools.

## Working features

- Responsive Discover page with ranked profile cards and Five Elements overview.
- Live cultural harmony scoring, not hard-coded percentages.
- Filter by gender, age, country, minimum harmony, and discovery categories.
- Save / unsave connections, inspect match breakdowns, and hide profiles.
- Search discovery by name, city/country, occupation, or interests.
- Connections hub with separate Saved, Invitations, and Messages sections.
- Local-only invitations, withdrawal, conversation previews, and persistent message drafts with an icebreaker. No messages are delivered.
- Validated adult birth profile, date picker, optional birth time, 16 global birthplaces, and custom birthplace with IANA zone and longitude.
- Historical time-zone and daylight-saving handling.
- Four Pillars, day master, visible element distribution, and English guide.
- Local persistence and explicit local-data reset.
- Custom illustration and Material 3 UI for phones, tablets, and desktop browsers.

## Scope

This version is a working local prototype. Six fictional adults with stock photos make the recommendation experience immediately explorable. There is no live community, authentication server, messaging transport, payments, or account verification. Profile details, saves, invitations, and conversation drafts remain in local SharedPreferences; this storage is not encrypted. Chart calculations run locally. Clicking Generate sends calculated evidence to the configured model provider; names, exact birth dates and places are omitted. Client keys are memory-only and the default DeepSeek key is held by the local server. See [proxy setup](server/README.md).

A real launch requires backend authentication and profiles, mutual consent and messaging, moderation/reporting, verification and age assurance, secure handling of birth data, server-side recommendation processing, retention/deletion controls, and production privacy documentation.

## Yuan MVP integration

This repository is the canonical project for the combined app. The integration starts from `a49179f` and keeps Lunar’s brand, Manrope/Material 3 design, `lunar` 1.7.8 engine, local mean-solar-time convention, Chart Studio, model adapter, existing localization, platform configuration, and seeded community. The earlier Yuan prototype contributes the invitation/message-preview flow and discovery search; its separate calendar/scoring implementation is not copied over.

Invitations and local message drafts use the versioned `social.v1` preference. Writes are serialized and published to the UI only after successful storage. Hiding/reporting a profile removes it from the Connections hub; its local drafts remain in the data export until a confirmed local-data reset removes them. Reset also clears invitations and drafts while preserving the chosen language and unrelated preferences.

New social strings are translated into English and Simplified Chinese; other existing locales currently use generated English fallbacks for these new strings. The compact phone tab is **Connect**, with Saved, Invitations, and Messages inside.

The hosted preview is a static Web build. Offline charts, comparisons, discovery, and local social features work without credentials. AI generation needs a separately configured model endpoint; no provider key is bundled or provisioned by this integration. See `server/README.md` for running the preserved proxy locally.

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

The local Web app was exercised with Playwright on desktop (1440 × 1000) and mobile (390 × 844), including birth-profile editing, live re-ranking, saved connections, profile details, local profile restoration, and the confirmed local-data reset. Browser console: zero errors and zero warnings. Preview images are in `output/playwright/`.

## Structure

- `lib/models/profile.dart`: birth data, global birthplace presets, fictional profiles.
- `lib/services/bazi.dart`: chart calculation and explainable ranking.
- `lib/services/app_state.dart`: persistence and reactive app state.
- `lib/services/social.dart`: serialized, local-only invitation and message-draft storage.
- `lib/ui/social_pages.dart`: Connections hub and conversation preview.
- `lib/ui/design.dart`: theme, reusable surfaces, brand illustration, element ring.
- `lib/ui/app_shell.dart`: responsive navigation, discovery, filtering and saves.
- `lib/ui/profile_editor.dart`: validated birth data editor.
- `lib/ui/profile_detail.dart`: profile and match breakdown.
- `lib/ui/secondary_pages.dart`: energy page, BaZi guide, privacy controls.

## Validation

Automated checks cover calculation fixtures, solar-term boundaries, selected time/day conventions, historical DST, unknown hour, cross-chart relations, Five Movements/Six Qi, lunar leap months, model transport/error handling, privacy/reset, and desktop/mobile flows. All 50 tests pass in the integrated version. Web release and iOS simulator builds succeed. Real DeepSeek plain/professional requests returned HTTP 200. See [verification record](docs/verification.md); full test output is in `output/test-results.txt`. Browser screenshots are in `output/playwright/`.

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

The people pictured are not represented as actual Lunar members. The flower mark and orbit illustration are drawn in Flutter and have no external image dependency.
