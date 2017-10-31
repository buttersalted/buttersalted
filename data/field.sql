-- 1. create table to store field data
CREATE TABLE IF NOT EXISTS "field" (
  "id"   TEXT NOT NULL,
  "type" TEXT NOT NULL,
  "unit" TEXT NOT NULL DEFAULT '',
  PRIMARY KEY ("id"),
  CHECK ("id"<>'' AND "type"<>''),
  FOREIGN KEY "unit" REFERENCES "unit" ("id")
  ON DELETE NO ACTION ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS "field_type_idx"
ON "field" ("type");
CREATE INDEX IF NOT EXISTS "field_unit_idx"
ON "field" ("unit");


CREATE OR REPLACE FUNCTION "field_selectone" (JSONB)
RETURNS SETOF "field" AS $$
  SELECT * FROM "field" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


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
  IF _type<>'TABLE' THEN
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
  -- 1. delete from table and drop column, only if empty
  EXECUTE format('SELECT * FROM "food" WHERE %I IS NOT NULL', _a->>'id');
  IF NOT FOUND THEN
    DELETE FROM "field" WHERE "id"=_a->>'id';
    EXECUTE format('ALTER TABLE "food" DROP COLUMN IF EXISTS %I', _a->>'id');
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "field_upsertone" (_a JSONB)
RETURNS VOID AS $$
DECLARE
  _r JSONB := row_to_json(field_selectone(_a))::JSONB;
  _z JSONB := _a||_r;
BEGIN
  IF _r IS NOT NULL THEN
    EXECUTE format('ALTER TABLE "food" MODIFY COLUMN ');
  END IF;
  unit_deleteone(_a);
  unit_insertone(_a||_r);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_insertoneifnotexists" (TEXT, TEXT)
RETURNS VOID AS $$
  SELECT type_insertone(jsonb_build_object('id', $1, 'value', $2))
  WHERE NOT EXISTS (SELECT "id" FROM "type" WHERE "id"=$1);
$$ LANGUAGE SQL;
