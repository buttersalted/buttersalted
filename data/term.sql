-- 1. create table to store alternate terms for "type"
CREATE TABLE IF NOT EXISTS "term" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'' AND "value"<>''),
  FOREIGN KEY ("value") REFERENCES "type" ("id")
  ON DELETE NO ACTION ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS "term_value_idx"
ON "term" ("value");


CREATE OR REPLACE FUNCTION "term_insertone" (JSON)
RETURNS VOID AS $$
  INSERT INTO "term" VALUES ($1->>'id', $1->>'value');
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "term_deleteone" (JSON)
RETURNS VOID AS $$
  DELETE FROM "term" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "term_upsertone" (JSON)
RETURNS VOID AS $$
  INSERT INTO "term" VALUES ($1->>'id', $1->>'value')
  ON CONFLICT ("id") DO UPDATE SET "value"=$1->>'value';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "term_selectone" (JSON)
RETURNS "term" AS $$
  SELECT * FROM "term" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;
