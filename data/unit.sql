CREATE TABLE IF NOT EXISTS "unit" (
  "id"    TEXT NOT NULL,
  "value" REAL NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'')
);

CREATE OR REPLACE FUNCTION "unit_insertone" (JSON)
RETURNS VOID AS $$
  INSERT INTO "unit" VALUES($1->>'id', $1->'value'::REAL);
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_deleteone" (JSON)
RETURNS VOID AS $$
  DELETE FROM "unit" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_upsertone" (JSON)
RETURNS VOID AS $$
  INSERT INTO "unit" VALUES($1->>'id', $1->'value'::REAL)
  ON CONFLICT ("id") DO UPDATE SET "value"=$1->'value'::REAL;
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_selectone" (JSON)
RETURNS "unit" AS $$
  SELECT * FROM "unit" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;
