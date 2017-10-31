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
);
CREATE INDEX IF NOT EXISTS "group_field_idx"
ON "group" ("field");
CREATE INDEX IF NOT EXISTS "group_value_idx"
ON "group" ("value");


CREATE OR REPLACE FUNCTION "group_startone" (_id TEXT)
RETURNS VOID AS $$
DECLARE
  _key   TEXT;
  _tag   TEXT;
  _value TEXT;
BEGIN
  -- 1. get key, tag, value
  SELECT "key", "tag", "value" INTO _key, _tag, _value
  FROM "group" WHERE "id"=_id;
  -- 2. create view
  EXECUTE format('CREATE OR REPLACE VIEW %I AS %s', _id, _value);
  -- 3. add tag to key column, if known
  IF _key IS NOT NULL AND _tag IS NOT NULL THEN
    EXECUTE format('UPDATE %I SET %I=array_sort(array_append(%I, %L))',
      _id, _key, _key, _tag, _key, _tag);
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_stopone" (_id TEXT)
RETURNS VOID AS $$
DECLARE
  _key   TEXT;
  _tag   TEXT;
BEGIN
  -- 1. get key, tag
  SELECT "key", "tag" INTO _key, _tag
  FROM "group" WHERE "id"=_id;
  -- 2. remove tag from key column, if known
  IF _key IS NOT NULL AND _tag IS NOT NULL THEN
    EXECUTE format('UPDATE %I SET %I=array_remove(%I, %L)',
      _id, _key, _key, _tag);
  END IF;
  -- 3. drop view
  EXECUTE format('DROP VIEW IF EXISTS %I RESTRICT', _id);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_insertone" (_a JSONB)
RETURNS VOID AS $$
DECLARE
  -- 1. get id, key, value
  _id    TEXT := _a->>'id';
  _key   TEXT := _a->>'key';
  _value TEXT := _a->>'value';
  _oid   TEXT;
BEGIN
  -- 2. insert record into table
  INSERT INTO "group" SELECT * FROM
  jsonb_populate_record(NULL::"group", table_default('group')||_a);
  -- 3. insert type key, if first group with that key
  SELECT "id" INTO _oid FROM "group" WHERE "key"=_key AND "id"<>_id LIMIT 1;
  IF _key IS NOT NULL AND _oid IS NULL THEN
    PERFORM type_insertone(jsonb_build_object('id', _key,
      'value', E'TEXT[] NOT NULL DEFAULT \'{}\'', 'index', 'jsonb_path_ops'));
  END IF;
  -- 4. create view and add tag to key
  PERFORM group_startone(_id);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_deleteone" (_a JSONB)
RETURNS VOID AS $$
DECLARE
  -- 1. get id, key
  _id  TEXT := _a->>'id';
  _key TEXT := _a->>'key';
  _oid TEXT;
BEGIN
  -- 2. drop view and remove tag from key
  PERFORM group_stopone(_id);
  -- 3. delete type key, if last group iwth that key
  SELECT "id" INTO _oid FROM "group" WHERE "key"=_key AND "id"<>_id LIMIT 1;
  IF _key IS NOT NULL AND _oid IS NULL THEN
    PERFORM type_deleteone(jsonb_build_object('id', _key));
  END IF;
  -- 4. delete row
  DELETE FROM "group" WHERE "id"=_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_upsertone" (_a JSONB)
RETURNS VOID AS $$
DECLARE
  _len INT;
BEGIN
  -- 1. get input key count
  SELECT count(*) INTO _len FROM jsonb_object_keys(_a);
  -- 2. if only 1 key (id), just refresh it
  IF _len = 1 THEN
    PERFORM group_stopone(_a->>'id');
    PERFORM group_startone(_a->>'id');
  -- 3. if multiple keys, update row as well
  ELSE
    SELECT row_to_json(group_selectone(_a))::JSONB||_a INTO _a;
    PERFORM group_deleteone(_a);
    PERFORM group_insertone(_a);
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_refresh" (_a JSONB)
RETURNS VOID AS $$
DECLARE
  _r "group";
BEGIN
  -- 1. update all groups as specified by json
  FOR _r IN EXECUTE query_selectlike('group', _a) LOOP
    PERFORM group_stopone(_r.id);
    PERFORM group_startone(_r.id);
  END LOOP;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_selectone" (JSONB)
RETURNS SETOF "group" AS $$
  SELECT * FROM "group" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;
