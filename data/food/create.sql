CREATE TABLE IF NOT EXISTS "food" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'' AND "value"<>''),
  FOREIGN KEY ("value") REFERENCES "type" ("id")
  ON DELETE NO ACTION ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS "idx_food_value"
ON "food" ("value");

/* INSERT DEFAULT DATA HERE */
