-- 1. create table for view based groups
CREATE TABLE IF NOT EXISTS "group" (
  "id"    TEXT NOT NULL,
  "key"   TEXT NULL,
  "tag"   TEXT NULL,
  "value" TEXT NOT NULL DEFAULT 'SELECT NULL LIMIT 0',
  PRIMARY KEY ("id"),
  UNIQUE ("key", "tag"),
-- 2. to make sure its just select
  CHECK (
    "id"<>'' AND
    ("key"=NULL OR "key"<>'') AND
    ("tag"=NULL OR "tag"<>'') AND
    "key" NOT LIKE '#%' AND
    "value" NOT LIKE '%;%' AND
    lower("value") LIKE 'select %' AND
    lower("value") NOT LIKE '% into %'
  )
);
CREATE INDEX IF NOT EXISTS "group_key_idx"
ON "group" ("key");
CREATE INDEX IF NOT EXISTS "group_tag_idx"
ON "group" ("tag");


CREATE OR REPLACE FUNCTION "group_startone" (_id TEXT)
RETURNS VOID AS $$
DECLARE
  _key   TEXT;
  _keyh  TEXT;
  _tag   TEXT;
  _value TEXT;
BEGIN
  -- 1. get key, keyh, tag, value
  SELECT "key", '#'||"key", "tag", "value" INTO _key, _keyh, _tag, _value
  FROM "group" WHERE "id"=_id;
  -- 2. create view
  EXECUTE format('CREATE OR REPLACE VIEW %I AS %s', _id, _value);
  -- 3. add tag to key column, if known
  IF _key IS NOT NULL AND _tag IS NOT NULL THEN
    EXECUTE format('UPDATE %I SET %I=array_sort(array_append(%I, %L)), '||
      '%I=array_to_string(array_sort(array_append(%I, %L)), %L)',
      _id, _keyh, _keyh, _tag, _key, _keyh, _tag, ', ', _keyh, _tag);
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_stopone" (_id TEXT)
RETURNS VOID AS $$
DECLARE
  _key   TEXT;
  _keyh  TEXT;
  _tag   TEXT;
BEGIN
  -- 1. get key, keyh, tag
  SELECT "key", '#'||"key", "tag" INTO _key, _keyh, _tag
  -- 2. remove tag from key column, if known
  FROM "group" WHERE "id"=_id;
  IF _key IS NOT NULL AND _tag IS NOT NULL THEN
    EXECUTE format('UPDATE %I SET %I=array_remove(%I, %L), '||
      '%I=array_to_string(array_remove(%I, %L), %L)',
      _id, _keyh, _keyh, _tag, _key, _keyh, _tag, ', ', _keyh, _tag);
  END IF;
  -- 3. drop view
  EXECUTE format('DROP VIEW IF EXISTS %I RESTRICT', _id);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_insertone" (_a JSON)
RETURNS VOID AS $$
DECLARE
-- 1. get id, key, value from input
  _id    TEXT := _a->>'id';
  _key   TEXT := _a->>'key';
  _value TEXT := _a->>'value';
  _oid   TEXT;
BEGIN
  -- 2. insert record into table
  INSERT INTO "group" SELECT * FROM json_populate_record(NULL::"group", _a);
  -- 4. is this the first group with that key?
  SELECT "id" INTO _oid FROM "group" WHERE "key"=_key AND "id"<>_id LIMIT 1;
  IF _key IS NOT NULL AND _oid IS NULL THEN
  -- 5. insert types key, #key
    PERFORM type_insertone(json_build_object('id', _key,
      'value', E'TEXT NOT NULL DEFAULT \'\''::TEXT));
    PERFORM type_insertone(json_build_object('id', '#'||_key,
      'value', 'TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[]', 'index', 'gin'));
  END IF;
  -- 7. create view and add tag to key
  PERFORM group_startone(_id);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_deleteone" (_a JSON)
RETURNS VOID AS $$
DECLARE
-- 1. get id, key
  _id  TEXT := _a->>'id';
  _key TEXT := _a->>'key';
  _oid TEXT;
BEGIN
  -- 2. drop view and remove tag from key
  PERFORM group_stopone(_id);
  -- 3. is this the last group with that key?
  SELECT "id" INTO _oid FROM "group" WHERE "key"=_key AND "id"<>_id LIMIT 1;
  IF _key IS NOT NULL AND _oid IS NULL THEN
  -- 4. delete types key, #key
    PERFORM type_deleteone(json_build_object('id', _key));
    PERFORM type_deleteone(json_build_object('id', '#'||_key));
  END IF;
  -- 5. delete row
  DELETE FROM "group" WHERE "id"=_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_selectone" (JSON)
RETURNS "group" AS $$
  SELECT * FROM "group" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "group_upsertone" (_a JSON)
RETURNS VOID AS $$
DECLARE
  _len INT;
BEGIN
  SELECT count(*) INTO _len FROM json_object_keys(_a);
  IF _len = 1 THEN
    PERFORM group_stopone(_a->>'id');
    PERFORM group_startone(_a->>'id');
  ELSE
    SELECT row_to_json(group_selectone(_a))||_a INTO _a;
    PERFORM group_deleteone(_a);
    PERFORM group_insertone(_a);
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_refresh" (_a JSON)
RETURNS VOID AS $$
DECLARE
  _r "group";
BEGIN
  FOR _r IN EXECUTE query_selectlike('group', _a) LOOP
    PERFORM group_stopone(_r.id);
    PERFORM group_startone(_r.id);
  END LOOP;
END;
$$ LANGUAGE plpgsql;
