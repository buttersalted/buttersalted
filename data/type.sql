-- 1. create table to store data types
CREATE TABLE IF NOT EXISTS "type" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'' AND "value"<>'')
);
CREATE INDEX IF NOT EXISTS "type_value_idx"
ON "type" ("value");


CREATE OR REPLACE FUNCTION "type_value" (TEXT)
RETURNS TEXT AS $$
  SELECT "value" FROM "type" WHERE "id"=$1;
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "type_insertone" (_a JSONB)
RETURNS VOID AS $$
DECLARE
-- 1. get id, value, index
  _id    TEXT := _a->>'id';
  _value TEXT := upper(_a->>'value');
  _index TEXT := coalesce(_a->>'index', 'btree');
BEGIN
  -- 2. insert into table (fail early)
  INSERT INTO "type" VALUES (_id, _value);
  -- 3. add column id to food table with index (if column)
  IF _value<>'TABLE' THEN
    EXECUTE format('ALTER TABLE "food" ADD COLUMN IF NOT EXISTS %I %s',
      _id, _value);
    EXECUTE format('CREATE INDEX IF NOT EXISTS %I ON "food" USING %s (%I)',
      'food_'||_id||'_idx', _index, _id);
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_deleteone" (_a JSONB)
RETURNS VOID AS $$
BEGIN
  -- 1. delete from table and drop column
  DELETE FROM "type" WHERE "id"=_a->>'id';
  EXECUTE format('ALTER TABLE "food" DROP COLUMN IF EXISTS %I', _a->>'id');
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_upsertone" (_a JSONB)
RETURNS VOID AS $$
BEGIN
  PERFORM type_deleteone(_a);
  PERFORM type_insertone(_a);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_selectone" (JSONB)
RETURNS SETOF "type" AS $$
  SELECT * FROM "type" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;
