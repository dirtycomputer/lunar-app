# Release review — 2026-11-12

This update uses a repeatable use → feedback → fix → regression loop. The shipped channel remains **preview**. Passing tests or deploying the website does not establish readiness for a real dating community.

## UI design pass — 2026-11-12

Applied the [official frontend-design guidance](https://github.com/anthropics/skills/blob/main/skills/frontend-design/SKILL.md), with the palette, typography, layout sketch and critique recorded before implementation in [ui-design.md](ui-design.md). The UI retains the two primary routes, secondary Agent, sample-community notices and optional garden.

| Observed feedback | Change | Verification |
| --- | --- | --- |
| First-use illustrations were small inside uniform white cards; ornamental route numbers implied an order. | Larger original elemental artwork, distinct cobalt/sky entrances, shared branding and no route numbers or hover lift. | First-use captures at desktop, phone, Chinese, landscape and 200% text. |
| Reading lines spanned the desktop; on phone the full explanation pushed questions and pillars far below the opening screen. | Reading/pillars share a row on wide screens; the first paragraph is shown immediately, with complete details available inline. The question action remains outside the disclosure, and its full evidence packet is unchanged. | Expand/collapse assertions, existing contextual-question preservation and keyboard tests, desktop and phone renders. |
| At 320px / 200% text, decorative entrance art split “reading” inside a word. | Hide that decorative illustration at larger text sizes so labels have the full card width; all routes remain scrollable. | Revised large-text render plus the full core navigation walkthrough. |
| Names, reasons and harmony were visually similar, and saving used a small target. | Independent reusable matching tile with larger portraits/identity, clear reason, harmony badge and 48px save target. | Search, filter-aware random matching, saving, profile and local interaction regression tests; portraits are explicitly pre-cached before renderer captures. |
| Garden task chrome competed with its landscape. | One green active task, descriptive task icons, quieter framing and no redundant chapter eyebrow or hard card shadows. | All five garden walkthroughs, including legacy rewards, complete the full five-link puzzle and all three discoveries. |

Final checks: clean Flutter analysis, all **94 tests**, and **10 renderer walkthroughs / 75 captures**. The Web release and preview package check are recorded in verification.md. Selected current screenshots use `output/flutter-render/ui-*.png`. English and Chinese use bundled fonts; new Chinese copy is covered by the existing subset. No dependency, backend, model, quota or access change is part of this pass. Native checks run on the PR; browser acceptance remains unverified because the supported managed browser tool is unavailable. Existing production release blockers remain open.

## Element Garden redesign — 2026-11-11

The previous three task cards and single-answer quiz did not give the game a distinct place, a sustained interaction or a satisfying return visit. The redesign keeps the core tasks directly available and builds one optional garden chapter around them.

- **Explore:** an original vector world has a grove, hearth, meadow, mineral habitat and pond. Each guardian opens its field notes. Collected seals wake guardians and add flowers; the three discoveries light the lanterns. The companion responds to a tap with a short finite motion.
- **Play:** reconstruct five supporting links from the current day element. Each correct tap/drop reveals the relation and fact, saves the next position and collects a seal. A wrong choice offers a hint without losing progress. Closing and reopening resumes the same practice seed, including after a birth-profile edit; it is explicitly labelled as a saved cycle.
- **Collect and revisit:** all five field-note entries remain readable before collection. Completing the circle awards the existing one-time reward; migrated rewards remain intact, and replay cannot mint more. Existing players see the new seal goal instead of a finished chapter that hides the new content; their old spark balance is preserved. Clearing local data removes the cycle and seals through the existing deletion barrier.
- **Feedback loop:** the first phone rendering put the fifth answer below the fold and left the primary footer action awkwardly centred. A compact five-spirit inventory and a right-aligned fixed action resolve this. Larger text retains spacious choices and scrolling. A full 320px/160% walkthrough also exposed prior first-use and profile-detail overflows; flexible branding, adaptive decorative artwork and wrapping profile rows fix those paths.
- **Verification:** clean analysis, 94 Flutter tests and five renderer walkthroughs (40 captures) cover desktop, phone, larger text/reduced motion, Chinese and legacy progress. Tests exercise dragging, collection-before-reading, all five seeds, duplicate/wrong inputs, failed saves/retry, resume, migration, replay and deletion. The final Web release builds. Native CI is available through the PR checks; browser interaction remains unverified because the supported managed browser tool is absent.

This is an educational game within the existing preview. It introduces no network image dependency, new paid model call, timed penalty, energy meter, streak pressure, gate on charts/matching or effect on compatibility scores. The production community/operations gates below remain open.

## Loop 1: saved data and deletion

| Feedback from code and interaction review | Change | Verification |
| --- | --- | --- |
| Rapid save/hide operations read the same old selection and could overwrite each other. | All personal stores share one serialized write coordinator; state is published after persistence succeeds. | Concurrent different selections, toggle parity, and restoration after restart. |
| Clearing multiple keys could stop halfway and restore old records on the next launch. A queued draft or studio write could also race with deletion. | Persist deletion intent first, invalidate queued writes, hide old personal state, attempt every key, and retain the marker until cleanup finishes. Startup and an in-app retry finish interrupted deletion. | Failure injection, cross-store reset barrier, blocked writes during deletion, hidden old profile/drafts/progress, retry and unrelated-setting preservation. |
| Wrong-typed preferences could crash startup; a platform read failure left no recovery action. | Typed reads and an explicit startup retry. | Wrong-type and malformed-record cases; the retry reaches the first-use chooser without exposing platform error details. |
| Export omitted comparison charts and language. | A versioned device export covers persisted app records; model keys remain memory-only. | Export contents and credential exclusion. |

## Loop 2: questions and responsiveness

| Feedback | Change | Verification |
| --- | --- | --- |
| A failed connection looked like a normal reference answer, with no direct retry. | Keep the question, show the failure separately from the reference source, and retry with the exact original evidence and conversation. | Identical first/retry request packets; no duplicate question; successful replacement of the reference answer. |
| A stopped request could finish after a new request. | Each request owns its client and generation; stale responses are ignored. | Cancel → retry → delayed old response. |
| Unrelated UI changes recomputed both natal and transit reports. | Cache reports by complete birth/convention inputs and minute; each view gets its own page context. | Reuse, independent context, and time/convention invalidation. |
| Reduced-motion preference was ignored by chat scrolling. | Jump directly when motion is reduced. | Widget coverage alongside the existing accessibility flows. |

## Loop 3: narrow screens and larger text

Using the actual bundled fonts, a 320 × 740 phone at 200% text revealed overflow in chart actions, the reading header and random-match/filter controls. A landscape phone exposed a settings dialog that could not scroll. Flexible wrapping and scrollable settings resolve these paths; regression flows traverse chart → matching → Agent → settings → privacy at 320 × 740 / 200%, 844 × 390 / 120%, and 1440 × 1000 / 100%. The default desktop layout remains checked alongside the edge cases. A further failure/retry check with the keyboard open at 200% text exposed an oversized Agent header and a retry action pushed out of reach. Wrapping header actions, keeping errors inside the scrollable conversation, and limiting the compact composer resolve this case. First-use cards also grow with larger text instead of clipping the route title.

## Loop 4: publication and truthful scope

- Removed Android release's fallback to debug signing. Release credentials are read from an ignored `key.properties`; absent credentials produce an unsigned artifact. Android OS backup is disabled for local birth data.
- Replaced future-tense legal placeholders with descriptions of the actual preview behavior. Reporting no longer claims that a moderation team received a local record. Copy/export and local-deletion actions describe their actual effects. These notices are **not** completed production operator policies.
- Added repeatable CI for Flutter analysis/tests/Web, the Python service, an Android debug build, and an unsigned iOS simulator build. Native compilation and signed store acceptance are different checks.
- A package check validates icons and source credential exclusion. `--channel production` intentionally refuses the current preview and enumerates open release gates; it is not a certification based on checkboxes.

## Loop 5: dependency advisories

An OSV query for the exact Python and Pub package versions identified public Starlette advisories in the previous 0.49.3 runtime (including request/path handling and form limits). The framework pair is now FastAPI 0.162.4 / Starlette 1.10.0, and all Python runtime/transitive dependencies are pinned together. The 20 service tests pass on that environment. A fresh query covers 65 checked-in Python/Pub versions with no matching advisories; the checked scope and timestamp are preserved in `output/dependency-audit.json`. This does not certify native, infrastructure or application security.

`python3 scripts/audit_dependencies.py` repeats the query, fails on incomplete/network responses or findings, and runs in CI. The initial CI run also passed Android debug and unsigned iOS simulator compilation; artifacts are now uploaded on subsequent runs so those builds can be inspected.

## Remaining release blockers

The exact current gates are in [`release/launch.json`](../release/launch.json). Real accounts, durable community records, mutual messaging, effective moderation, durable AI authorization/quotas and spend limits remain unimplemented. Precise birth data needs the corresponding production protection, retention and deletion design. The user confirmed the operator identity and contact details are not yet determined; they have not been invented.

Provisioning is blocked by Vercel's `403 forbidden` for `GET /v1/integrations/configurations` in the existing team (`team_oHtL5Trw5vuzwHSE6QBoQLw2`). No Vercel CLI executable/credential fallback is configured in this executor. The current API also has no retrievable custom firewall configuration (`404 Seawall Config not found`). No firewall or access policy was changed, and CORS/per-instance limits are not represented as account authorization or a global quota.

The managed executor reports running/connected with current observations and enforced network policy. Environment ID: `ccarenv_b64_Y2NhcmVudl83MzJlMTAxZDcyMmM4MTkxYjE0ZTg5NGJhMWI4ODFmZQ`. Remote desktop is enabled with state unknown, but no `cua_repl.js`/supported browser-control tool is exposed. Browser QA is therefore unverified this turn. Flutter-rendered captures and widget-driven interaction tests are used and identified explicitly. This Linux executor also lacks Android SDK and Xcode; native CI and store/device checks must not be confused with local validation.

See [`verification.md`](verification.md) for final command outcomes and artifacts.
