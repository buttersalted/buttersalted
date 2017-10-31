-- 1. create table to store field data
CREATE TABLE IF NOT EXISTS "field" (
  "id"   TEXT NOT NULL,
  "type" TEXT NOT NULL,
  "unit" TEXT NOT NULL DEFAULT '',
  PRIMARY KEY ("id"),
  CHECK ("id"<>'' AND "type"<>'')
);
CREATE INDEX IF NOT EXISTS "field_type_idx"
ON "field" ("type");
CREATE INDEX IF NOT EXISTS "field_unit_idx"
ON "field" ("unit");


CREATE OR REPLACE FUNCTION "field_insertone" (_a JSONB)
RETURNS VOID AS $$
DECLARE
  -- 1. get id, type, index
  _id    TEXT := _a->>'id';
  _type  TEXT := upper(_a->>'type');
  _index TEXT := coalesce(_a->>'index', 'btree');
BEGIN
  -- 2. insert into table (fail early)
  INSERT INTO "field" SELECT * FROM
    jsonb_populate_record(NULL::"field", table_default('field')||_a);
  -- 3. add column id to food table with index (if column)
  IF _value<>'TABLE' THEN
    EXECUTE format('ALTER TABLE "food" ADD COLUMN IF NOT EXISTS %I %s',
      _id, _type);
    EXECUTE format('CREATE INDEX IF NOT EXISTS %I ON "food" USING %s (%I)',
      'food_'||_id||'_idx', _index, _id);
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "field_deleteone" (_a JSONB)
RETURNS VOID AS $$
BEGIN
  -- 1. delete from table and drop column
  DELETE FROM "field" WHERE "id"=_a->>'id';
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


CREATE OR REPLACE FUNCTION "type_insertoneifnotexists" (TEXT, TEXT)
RETURNS VOID AS $$
  SELECT type_insertone(jsonb_build_object('id', $1, 'value', $2))
  WHERE NOT EXISTS (SELECT "id" FROM "type" WHERE "id"=$1);
$$ LANGUAGE SQL;
