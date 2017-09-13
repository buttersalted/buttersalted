CREATE TABLE IF NOT EXISTS "type" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'' AND "value"<>'')
);
CREATE INDEX IF NOT EXISTS "idx_type_value"
ON "type" ("value");

/* INSERT DEFAULT DATA HERE */
