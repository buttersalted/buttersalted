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
  -- 2. insert into table, and add column to food, if column
  INSERT INTO "field" SELECT * FROM
    jsonb_populate_record(NULL::"field", table_default('field')||_a);
  IF _type<>'TABLE' THEN
    EXECUTE format('ALTER TABLE "food" ADD COLUMN IF NOT EXISTS %I %s', _id, _type);
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


CREATE OR REPLACE FUNCTION "field_updateone" (_f JSONB, _t JSONB)
RETURNS VOID AS $$
  -- 1. get current, final rows
  _r JSONB := row_to_json(field_selectone(_f));
  _z JSONB := _t||_r;
BEGIN
  -- 2. update row
  UPDATE "field" SET "id"=_z->>'id', "type"=_z->>'type', "unit"=_z->>'unit'
  WHERE "id"=_f->>'id';
  -- 3. rename column if id changed
  IF _r->>'id'<>_z->>'id' THEN
    EXECUTE format('ALTER TABLE "food" RENAME COLUMN %I TO %I',
    _r->>'id', _z->>'id');
  END IF;
  -- 4. alter type if type changed
  IF _r->>'type'<>_z->>'type' THEN
    EXECUTE format('ALTER TABLE "food" ALTER COLUMN %I TYPE %s',
    _z->>'id', _z->>'type');
  END IF;
  -- 5. convert value if unit changed
  IF _r->>'unit'<>_z->>'unit' AND _z->>'unit'<>'' THEN
    EXECUTE format('UPDATE "food" SET %I=unit_convert(%I, %L, %L)',
    _z->>'id', _z->>'id', _r->>'unit', _z->>'unit');
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_insertoneifnotexists" (TEXT, TEXT)
RETURNS VOID AS $$
  SELECT type_insertone(jsonb_build_object('id', $1, 'value', $2))
  WHERE NOT EXISTS (SELECT "id" FROM "type" WHERE "id"=$1);
$$ LANGUAGE SQL;
