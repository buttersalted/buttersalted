-- 1. create table to store data types
CREATE TABLE IF NOT EXISTS "type" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'' AND "value"<>'')
);
-- 2. create index for value (faster search i hope)
CREATE INDEX IF NOT EXISTS "type_value_idx"
ON "type" ("value");


CREATE OR REPLACE FUNCTION "type_insertone" (
  IN _a JSON
) RETURNS VOID AS $$
DECLARE
  _id    TEXT;
  _value TEXT;
BEGIN
  -- 1. get id, value from input (and set proper case)
  SELECT "id", upper("value") INTO _id, _value
  FROM json_populate_record(NULL::"type", _a);
  -- 2. add column id to food table with index (if its a column)
  IF _value<>'TABLE' THEN
    EXECUTE format('ALTER TABLE "food" ADD COLUMN IF NOT EXISTS %I %s', _id, _value);
    EXECUTE format('CREATE INDEX IF NOT EXISTS %I ON "food" (%I)', 'food_'||_id||'_idx', _id);
  END IF;
  -- 3. insert into table using id, value
  INSERT INTO "type" VALUES (_id, _value);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_deleteone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  -- 1. delete from table with id
  DELETE FROM "type" WHERE id=_a->>'id';
  -- 2. drop column if it exists
  EXECUTE format('ALTER TABLE "food" DROP COLUMN IF EXISTS %I', _a->>'id');
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_upsertone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  -- 1. the very complex approach
  PERFORM type_deleteone(_a);
  PERFORM type_insertone(_a);
END;
$$ LANGUAGE plpgsql;
