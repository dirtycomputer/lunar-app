# Friend sharing

The reading page offers an element portrait and a one-friend comparison. These are real D1 records and bearer links; the synthetic people catalog's local invitations remain separate. Links open the Flutter Web recipient flow without installing an app. Flutter's system sharing integration also supports native iOS/Android senders. Verified universal-link association with store-signed native apps is not configured.

A user previews and approves a nickname, selected fixed reflections, day element and, for comparisons, five integer element counts. The client calculates its chart before making this reduced snapshot. No birth inputs, time zone, location, full pillars or chat context are accepted by the sharing schema. The comparison is deterministic symbolic reflection, not an LLM report or a success-probability score. Full existing chart/Agent analysis remains separate.

## Storage and access

Append-only migration `catalog/drizzle/0001_sharing.sql` creates `share_links`, `share_limits` and `share_metrics` alongside the existing catalog. Publication keeps the same `DB` binding and migration history. The catalog export and seeding gate remain unchanged.

- Public link ID: 24 cryptographically random bytes, base64url without padding (32 characters).
- Separate 24-byte owner and participant capabilities, retained in device preferences; the database stores SHA-256 hashes. Capabilities never enter URLs, exports, aggregate metrics or public responses.
- One participant per pair link. An atomic conditional update arbitrates concurrent joins; the same request/credential can retry without changing the summary.
- Device handles persist **before** network mutations. Ambiguous responses remain recoverable from My shared links. Deletion blocks new writes, waits for in-flight writes, withdraws remote records, then applies the existing durable local deletion marker. A failed withdrawal preserves access for retry.
- Expiry: exactly seven days from creation. API queries exclude expired rows immediately; subsequent sharing requests purge bounded batches of expired rows. The visible result also closes at expiry. Either participant can delete the whole link/result.
- Link holders can see the initiating portrait and whether an invitation is already joined; completed participant data requires an owner or guest capability. Forwarding an invitation lets its first recipient join. There is no verified human identity or account recovery in this preview.
- Clearing browser storage outside the app or uninstalling loses access; the shared record still expires. Copied images cannot be recalled. HTTP responses use no-store/no-referrer/noindex. All queries bind values; body size is capped at 4 KiB and unknown properties are rejected.

## Routes

| Route | Behavior |
| --- | --- |
| `POST /api/shares` | Consented, idempotent creation with owner bearer header |
| `GET /api/shares/:id` | Public portrait; bearer-authorized result for participants |
| `POST /api/shares/:id/join` | Consented one-person acceptance; participant bearer header |
| `POST /api/shares/:id/open` | First app-rendered open per link, independent of crawler GETs |
| `DELETE /api/shares/:id` | Owner/participant withdrawal; repeat deletion succeeds |
| `/s/:id` | Static Flutter entry with deep-link routing and private caching headers |

Per daily network bucket: 20 creates, 60 joins, 200 open events; 10,000/day per action globally. These are D1 counters, shared across Worker instances. Daily IP hashes are retained for at most two days after the last action; no raw IP is written to application tables. They are abuse counters, not account identity. Rate-limited visitors keep their saved request for retry.

## Measurement and verification

`share_metrics` holds day, event, kind, and count only. Events: created, first opened per link, comparison completed, onward link created from an existing parent. No referral graph is stored. Retention is 90 days. These are link events, **not unique people, retention, conversion-rate estimates or proof of organic growth**. Initial production smoke tests also produce a small known number of events. Native Sites database inspection can inspect aggregate rows; no public analytics or administrative write route is exposed.

Run `node --test catalog/tests/*.test.mjs`, `flutter test`, and the explicit renderer walkthrough `flutter test --update-goldens test/render/capture_sharing.dart`. `scripts/verify_sharing_live.py` exercises two independent capabilities against deployed D1 and removes its records in a finally block. Renderer fixtures are confined to tests; production sharing always uses the API. Native share sheets, browser interaction, physical-device delivery and signed-app deep links still require acceptance testing on their actual platforms.
