CREATE TABLE "type" (
  "id"    TEXT,
  "value" TEXT,
  PRIMARY KEY ("id")
);
CREATE INDEX IF NOT EXISTS "idx_type_value"
ON "type" ("value");
/* INSERT DEFAULT DATA HERE */
