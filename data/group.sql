-- 1. create table for view based groups
CREATE TABLE IF NOT EXISTS "group" (
  "id"    TEXT NOT NULL,
  "field" TEXT NULL,
  "value" TEXT NULL,
  "query" TEXT NOT NULL DEFAULT 'SELECT NULL LIMIT 0',
  PRIMARY KEY ("id"),
  UNIQUE ("field", "value"),
-- 2. to make sure its just select
  CHECK (
    "id"<>'' AND
    ("field"=NULL OR "field"<>'') AND
    ("value"=NULL OR "value"<>'') AND
    "query" NOT LIKE '%;%'
  )
  FOREIGN KEY "field" REFERENCES "field" ("id")
  ON DELETE NO ACTION ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS "group_field_idx"
ON "group" ("field");
CREATE INDEX IF NOT EXISTS "group_value_idx"
ON "group" ("value");


CREATE OR REPLACE FUNCTION "group_startone" (_id TEXT)
RETURNS VOID AS $$
DECLARE
  _field TEXT;
  _value TEXT;
  _query TEXT;
BEGIN
  -- 1. get field, value, query
  SELECT "field", "value", "query" INTO _field, _value, _query
  FROM "group" WHERE "id"=_id;
  -- 2. create view
  EXECUTE format('CREATE OR REPLACE VIEW %I AS %s', _id, _query);
  -- 3. add value to field, if known
  IF _field IS NOT NULL AND _value IS NOT NULL THEN
    EXECUTE format('UPDATE %I SET %I=array_sort(array_append(%I, %L))',
      _id, _field, _field, _value);
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_stopone" (_id TEXT)
RETURNS VOID AS $$
DECLARE
  _field TEXT;
  _value TEXT;
BEGIN
  -- 1. get field, value
  SELECT "field", "value" INTO _field, _value
  FROM "group" WHERE "id"=_id;
  -- 2. remove value from field, if known
  IF _field IS NOT NULL AND _value IS NOT NULL THEN
    EXECUTE format('UPDATE %I SET %I=array_remove(%I, %L)',
      _id, _field, _field, _value);
  END IF;
  -- 3. drop view
  EXECUTE format('DROP VIEW IF EXISTS %I RESTRICT', _id);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_selectone" (JSONB)
RETURNS SETOF "group" AS $$
  SELECT * FROM "group" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "group_insertone" (_a JSONB)
RETURNS VOID AS $$
DECLARE
  -- 1. get id, field
  _id    TEXT := _a->>'id';
  _field TEXT := _a->>'field';
  _oid   TEXT;
BEGIN
  -- 2. insert row into table
  INSERT INTO "group" SELECT * FROM
  jsonb_populate_record(NULL::"group", table_default('group')||_a);
  -- 3. insert new field, if first group with that field
  SELECT "id" INTO _oid FROM "group" WHERE "field"=_field AND "id"<>_id LIMIT 1;
  IF _field IS NOT NULL AND _oid IS NULL THEN
    PERFORM field_insertone(jsonb_build_object('id', _field,
      'value', E'TEXT[] NOT NULL DEFAULT \'{}\'', 'index', 'jsonb_path_ops'));
  END IF;
  -- 4. create view and add value to field
  PERFORM group_startone(_id);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_deleteone" (_a JSONB)
RETURNS VOID AS $$
DECLARE
  -- 1. get id, field
  _id    TEXT := _a->>'id';
  _field TEXT := _a->>'field';
  _oid   TEXT;
BEGIN
  -- 2. drop view and remove value from field
  PERFORM group_stopone(_id);
  -- 3. delete field, if last group with that field
  SELECT "id" INTO _oid FROM "group" WHERE "field"=_field AND "id"<>_id LIMIT 1;
  IF _field IS NOT NULL AND _oid IS NULL THEN
    PERFORM field_deleteone(jsonb_build_object('id', _field));
  END IF;
  -- 4. delete row
  DELETE FROM "group" WHERE "id"=_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_updateone" (_f JSONB, _t JSONB)
RETURNS VOID AS $$
DECLARE
  _r JSONB := row_to_json(group_selectone(_f));
  _z JSONB := _t||_r;
BEGIN
  -- 1. if update is pointless, just refresh
  IF _r @> _z THEN
    PERFORM group_stopone(_r->>'id');
    PERFORM group_startone(_r->>'id');
  -- 2. otherwise, update everything
  ELSE
    PERFORM group_deleteone(_r);
    PERFORM group_insertone(_z);
  END IF;
END;
$$ LANGUAGE plpgsql;
