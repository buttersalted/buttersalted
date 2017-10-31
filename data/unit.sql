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


CREATE OR REPLACE FUNCTION "unit_selectone" (JSONB)
RETURNS SETOF "unit" AS $$
  SELECT * FROM "unit" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_insertone" (JSONB)
RETURNS VOID AS $$
  INSERT INTO "unit" SELECT * FROM
  jsonb_populate_record(NULL::"unit", table_default('unit')||$1);
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_deleteone" (JSONB)
RETURNS VOID AS $$
  DELETE FROM "unit" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_updateone" (JSONB, JSONB)
RETURNS VOID AS $$
  UPDATE "unit" SET "id"=coalesce($2->>'id', r."id"),
  "factor"=coalesce(($2->>'factor')::REAL, r."factor"),
  "offset"=coalesce(($2->>'offset')::REAL, r."offset")
  WHERE "id"=$1->'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_upsertone" (_a JSONB)
RETURNS VOID AS $$
DECLARE
  _r JSONB := row_to_json(unit_selectone(_a));
  _z JSONB := _a||_r;
BEGIN
  IF _r IS NULL THEN
    PERFORM unit_insertone(_a);
  ELSE
    UPDATE "unit" SET "id"=_z->>'id', "factor"=_z->>'factor', "offset"=_z->>'offset'
    WHERE "id"=_a->>'id';
  END IF;
END;
$$ LANGUAGE plpgsql;
