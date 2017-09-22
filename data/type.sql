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
-- 1. get id, value, index from input (and set proper case)
  _id    TEXT := _a->>'id';
  _value TEXT := _a->>'value';
  _index TEXT := coalesce(_a->>'index', 'btree');
BEGIN
  -- 2. add column id to food table with index (if its a column)
  IF _value<>'TABLE' THEN
    EXECUTE format('ALTER TABLE "food" ADD COLUMN IF NOT EXISTS %I %s',
      _id, _value);
    EXECUTE format('CREATE INDEX IF NOT EXISTS %I ON "food" USING %s (%I)',
      'food_'||_id||'_idx', _index, _id);
  END IF;
  -- 3. insert into table using id, value
  INSERT INTO "type" VALUES (_id, _value);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_deleteone" (_a JSON)
RETURNS VOID AS $$
BEGIN
  -- 1. delete from table and drop column
  DELETE FROM "type" WHERE id=_a->>'id';
  EXECUTE format('ALTER TABLE "food" DROP COLUMN IF EXISTS %I', _a->>'id');
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_upsertone" (_a JSON)
RETURNS VOID AS $$
BEGIN
  PERFORM type_deleteone(_a);
  PERFORM type_insertone(_a);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_selectone" (JSON)
RETURNS "type" AS $$
  SELECT * FROM "type" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;
