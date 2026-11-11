# Release review — 2026-11-11

This update uses a repeatable use → feedback → fix → regression loop. The shipped channel remains **preview**. Passing tests or deploying the website does not establish readiness for a real dating community.

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
