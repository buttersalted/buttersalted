CREATE TABLE IF NOT EXISTS "name" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id" <> '' AND "value" <> ''),
  FOREIGN KEY ("value") REFERENCES "type" ("id")
  ON DELETE NO ACTION ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS "idx_name_value"
ON "name" ("value");

/* INSERT DEFAULT DATA HERE */
