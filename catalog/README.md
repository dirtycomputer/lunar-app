# Persistent synthetic people catalog

Cloudflare D1 holds 1,000 synthetic adult profiles. This is a real hosted SQL database, separate from user accounts and device-local social drafts. No real people are registered or impersonated. Profiles have explicit `synthetic: true`, stable IDs, independent birthplaces, IANA zones, languages, interests and lunar-python chart snapshots using the existing mean-solar / midnight convention.

`scripts/generate_catalog.py` creates the reproducible server-only seed. SQL migrations under `drizzle/` contain schema only. Publishing binds D1 (`"d1": "DB"` in the Site manifest). A deliberately enabled bootstrap build (`python3 scripts/build_catalog.py --enable-seeding`) and server-only `CATALOG_SEED_TOKEN` allow bounded batches of 50 with parameterized SQL and conflict-safe IDs. Normal builds compile the write gate closed, even if a provider retains an old secret binding. Remove the temporary environment key and publish a normal build after importing. Repeating a bootstrap seed batch cannot duplicate rows or erase existing records.

Public APIs query D1, with no bundled or in-memory profile fallback:

- `GET /api/people?limit=200&after=<cursor>`: stable keyset pages, total, revision and source metadata. Filters: `gender`, ISO `country`, `min_age`, `max_age`, literal `q`.
- `GET /api/people/<id>`: one persisted record.
- `GET /api/people/stats`: SQL counts by country, gender, continent and age band.

Only synthetic catalog fields are public. There are no public user-write, SQL-console, authentication or messaging endpoints. Seeding requires a server environment token and POST; requests do not accept arbitrary records. Read endpoints allow cross-origin native/Web clients. Existing real-community release gates remain open.

`python3 scripts/verify_catalog_live.py` traverses the actual hosted API, compares every persisted profile with its expected fingerprint, writes `output/catalog-live-report.json`, and exports `build/catalog/fatepair-catalog.sqlite3`. The export is opened again with SQLite integrity/count checks. The normal public release exposes this copy at `/downloads/fatepair-catalog.sqlite3`.

Historical timezone databases can disagree before 1970. Catalog records therefore carry the Python-resolved UTC instant and offset alongside the original local inputs. Flutter validates their consistency and reuses that instant for detailed comparisons; the analysis service still independently resolves the original birth inputs, ignoring client-resolved metadata. All 1,000 chart snapshots are checked across both implementations.

Run `node --test catalog/tests/*.test.mjs` against an actual file-backed SQLite adapter; the tests close/reopen the file, seed twice, query filters and traverse every page. `python3 scripts/build_catalog.py` produces one Worker module. The Site packages it at `dist/server/index.js`, Flutter under `dist/client`, and the append-only Drizzle migration journal.
