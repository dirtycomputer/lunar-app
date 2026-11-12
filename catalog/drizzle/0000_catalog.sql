CREATE TABLE catalog_people (
  id TEXT PRIMARY KEY NOT NULL,
  name TEXT NOT NULL,
  gender TEXT NOT NULL CHECK (gender IN ('Women', 'Men', 'Non-binary')),
  country_code TEXT NOT NULL,
  country TEXT NOT NULL,
  continent TEXT NOT NULL,
  birth_date TEXT NOT NULL,
  location TEXT NOT NULL,
  search_text TEXT NOT NULL,
  time_known INTEGER NOT NULL CHECK (time_known IN (0, 1)),
  seed_version TEXT NOT NULL,
  record_hash TEXT NOT NULL,
  data_json TEXT NOT NULL CHECK (json_valid(data_json)),
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
--> statement-breakpoint
CREATE INDEX catalog_country_gender ON catalog_people(country_code, gender);
--> statement-breakpoint
CREATE INDEX catalog_birth_date ON catalog_people(birth_date);
--> statement-breakpoint
CREATE TABLE catalog_seed_runs (
  revision TEXT PRIMARY KEY NOT NULL,
  expected_count INTEGER NOT NULL,
  completed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
