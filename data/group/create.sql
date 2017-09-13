CREATE TABLE IF NOT EXISTS "group" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'')
);

CREATE TABLE IF NOT EXISTS "group_part" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  FOREIGN KEY "id" REFERENCES "group" ("id")
  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY "value" REFERENCES "group" ("id")
  ON DELETE NO ACTION ON UPDATE CASCADE
)
CREATE INDEX IF NOT EXISTS "idx_group_part_id"
ON "group_part" ("id");
CREATE INDEX IF NOT EXISTS "idx_group_part_value"
ON "group_part" ("value");

CREATE TABLE IF NOT EXISTS "group_child" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  FOREIGN KEY "id" REFERENCES "group" ("id")
  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY "value" REFERENCES "group" ("id")
  ON DELETE NO ACTION ON UPDATE CASCADE
)
CREATE INDEX IF NOT EXISTS "idx_group_child_id"
ON "group_child" ("id");
CREATE INDEX IF NOT EXISTS "idx_group_child_value"
ON "group_child" ("value");

CREATE TABLE IF NOT EXISTS "group_heir" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  FOREIGN KEY "id" REFERENCES "group" ("id")
  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY "value" REFERENCES "group" ("value")
  ON DELETE NO ACTION ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS "idx_group_heir_id"
ON "group_heir" ("id");
CREATE INDEX IF NOT EXISTS "idx_group_heir_value"
ON "group_heir" ("value");

/* INSERT DEFAULT DATA HERE */
