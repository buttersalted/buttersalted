-- 1. create table to store unit conversion factors
CREATE TABLE IF NOT EXISTS "unit" (
  "id"     TEXT NOT NULL,
  "factor" REAL NOT NULL DEFAULT 1,
  "offset" REAL NOT NULL DEFAULT 0,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'')
);


CREATE OR REPLACE FUNCTION "unit_get" (TEXT)
RETURNS "unit" AS $$
  SELECT * FROM "unit" WHERE "id"=$1 UNION ALL
  SELECT * FROM "unit" WHERE "id"=lower($1) LIMIT 1;
$$ LANGUAGE SQL STABLE;


CREATE OR REPLACE FUNCTION "unit_convert" (REAL, TEXT, TEXT)
RETURNS REAL AS $$
  SELECT ($1*f."factor"+f."offset"-t."offset")/t."factor"
  FROM unit_get($2) f, unit_get($3) t;
$$ LANGUAGE SQL STABLE;


CREATE OR REPLACE FUNCTION "unit_value" (TEXT)
RETURNS REAL AS $$
  SELECT "value" FROM "unit" WHERE "id"=$1;
$$ LANGUAGE SQL STABLE;


CREATE OR REPLACE FUNCTION "unit_lvalue" (TEXT)
RETURNS REAL AS $$
  SELECT coalesce(unit_value($1), unit_value(lower($1)));
$$ LANGUAGE SQL STABLE;


CREATE OR REPLACE FUNCTION "unit_tobase" (TEXT, TEXT)
RETURNS REAL AS $$
  -- 1. number * unit factor * column factor
  SELECT (real_get($1)::REAL)*
  coalesce(unit_lvalue(btrim(replace($1, real_get($1), ''))), 1)*
  coalesce(unit_lvalue($2), 1);
$$ LANGUAGE SQL STABLE;


CREATE OR REPLACE FUNCTION "unit_convert" (TEXT, TEXT)
RETURNS TEXT AS $$
  -- 1. convert only real numbers
  SELECT CASE WHEN type_value($2)='REAL'
  THEN unit_tobase($1, $2)::TEXT ELSE $1 END;
$$ LANGUAGE SQL STABLE;


CREATE OR REPLACE FUNCTION "unit_insertone" (JSONB)
RETURNS VOID AS $$
  INSERT INTO "unit" VALUES($1->>'id', ($1->>'value')::REAL);
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_deleteone" (JSONB)
RETURNS VOID AS $$
  DELETE FROM "unit" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_upsertone" (JSONB)
RETURNS VOID AS $$
  INSERT INTO "unit" VALUES($1->>'id', ($1->>'value')::REAL)
  ON CONFLICT ("id") DO UPDATE SET "value"=($1->>'value')::REAL;
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_selectone" (JSONB)
RETURNS SETOF "unit" AS $$
  SELECT * FROM "unit" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;
