-- 1. create table to store unit conversion factors
CREATE TABLE IF NOT EXISTS "unit" (
  "id"    TEXT NOT NULL,
  "value" REAL NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'')
);


CREATE OR REPLACE FUNCTION "unit_insertone" (JSON)
RETURNS VOID AS $$
  INSERT INTO "unit" VALUES($1->>'id', ($1->>'value')::REAL);
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_deleteone" (JSON)
RETURNS VOID AS $$
  DELETE FROM "unit" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_upsertone" (JSON)
RETURNS VOID AS $$
  INSERT INTO "unit" VALUES($1->>'id', ($1->>'value')::REAL)
  ON CONFLICT ("id") DO UPDATE SET "value"=($1->>'value')::REAL;
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_selectone" (JSON)
RETURNS "unit" AS $$
  SELECT * FROM "unit" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_convert" (_a JSON)
RETURNS REAL AS $$
DECLARE
  -- 1. get id, value
  _id    TEXT := _a->>'id';
  _value TEXT := _a->>'value';
  _z     REAL;
BEGIN
  -- 1. original number
  _z := split_part(_value, ' ', 1);
  -- 2. convert to base unit
  SELECT _z*coalesce("value", 1) INTO _z
    FROM "unit" WHERE "id"=split_part(_value, ' ', 2);
  -- 3. convert to column-specific unit (optional)
  SELECT _z*coalesce("value", 1) INTO _z
    FROM "unit" WHERE "id"=_id;
  RETURN _z;
END;
$$ LANGUAGE plpgsql;
