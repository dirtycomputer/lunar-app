CREATE TABLE share_links (
  id TEXT PRIMARY KEY NOT NULL,
  owner_hash TEXT NOT NULL,
  kind TEXT NOT NULL CHECK(kind IN ('portrait','pair')),
  portrait_json TEXT NOT NULL CHECK(json_valid(portrait_json)),
  guest_hash TEXT,
  guest_json TEXT CHECK(guest_json IS NULL OR json_valid(guest_json)),
  created_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL,
  opened_at INTEGER
);
--> statement-breakpoint
CREATE INDEX share_expiry ON share_links(expires_at);
--> statement-breakpoint
CREATE TABLE share_limits (
  bucket TEXT PRIMARY KEY NOT NULL,
  n INTEGER NOT NULL,
  expires_at INTEGER NOT NULL
);
--> statement-breakpoint
CREATE INDEX share_limit_expiry ON share_limits(expires_at);
--> statement-breakpoint
CREATE TABLE share_metrics (
  day TEXT NOT NULL,
  event TEXT NOT NULL,
  kind TEXT NOT NULL,
  n INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(day,event,kind)
);
