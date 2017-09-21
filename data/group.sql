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


CREATE OR REPLACE FUNCTION "group_executeone" (
  IN _a JSON
) RETURNS VOID AS $$
DECLARE
  _id   TEXT;
  _key  TEXT;
  _tag  TEXT;
BEGIN
  -- 1. get id from input
  SELECT "id" INTO _id FROM json_populate_record(NULL::"group", _a);
  -- 2. get key, tag from group row
  SELECT "key", "tag" INTO _key, _tag FROM "group" WHERE "id"=_id;
  -- 3. are key and tag known?
  IF _key IS NOT NULL AND _tag IS NOT NULL THEN
  -- 4. update food to add the tag to key, #key (if not exists)
    EXECUTE format('UPDATE "food" SET %I=array_to_string(array_sort(array_append(%I, %L)), %L), %I=array_sort(array_append(%I, %L)) WHERE NOT %I @> ARRAY[%L]',
    _key, '#'||_key, _tag, ',', '#'||_key, '#'||_key, _tag, '#'||_key, _tag);
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_unexecuteone" (
  IN _a JSON
) RETURNS VOID AS $$
DECLARE
  _id   TEXT;
  _key  TEXT;
  _tag  TEXT;
BEGIN
  -- 1. get id from input
  SELECT "id" INTO _id FROM json_populate_record(NULL::"group", _a);
  -- 2. get key, tag from group row
  SELECT "key", "tag" INTO _key, _tag FROM "group" WHERE "id"=_id;
  -- 3. are key and tag are known?
  IF _key IS NOT NULL AND _tag IS NOT NULL THEN
  -- 4. update food to remove the tag from key, #key (if exists)
    EXECUTE format('UPDATE "food" SET %I=array_to_string(array_remove(%I, %L), %L), %I=array_remove(%I, %L) WHERE %I @> ARRAY[%L]',
    _key, '#'||_key, _tag, ',', '#'||_key, _tag, '#'||_key, _tag);
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_insertone" (
  IN _a JSON
) RETURNS VOID AS $$
DECLARE
  _id    TEXT;
  _key   TEXT;
  _value TEXT;
  _oid   TEXT;
BEGIN
  -- 1. get id, key, value from input
  SELECT "id", "key", "value" INTO _id, _key, _value
  FROM json_populate_record(NULL::"group", _a);
  -- 2. insert record into table
  INSERT INTO "group" SELECT * FROM json_populate_record(NULL::"group", _a);
  -- 3. create view (id) using value
  EXECUTE format('CREATE OR REPLACE VIEW %I AS %s', _id, _value);
  -- 4. is this the first group with that key?
  SELECT "id" INTO _oid FROM "group" WHERE "key"=_key AND "id"<>_id LIMIT 1;
  IF _key IS NOT NULL AND _oid IS NULL THEN
  -- 5. insert types key, #key
    PERFORM type_insertone(json_build_object('id', _key, 'value', E'TEXT NOT NULL DEFAULT \'\''));
    PERFORM type_insertone(json_build_object('id', '#'||_key, 'value', 'TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[]', 'index', 'gin'));
  END IF;
  -- 7. add tag to key
  PERFORM group_executeone(_a);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_deleteone" (
  IN _a JSON
) RETURNS VOID AS $$
DECLARE
  _id  TEXT;
  _key TEXT;
  _oid TEXT;
BEGIN
  -- 1. get id, key from input
  SELECT "id", "key" INTO _id, _key
  FROM json_populate_record(NULL::"group", _a);
  -- 2. remove tag from key
  PERFORM group_unexecuteone(_a);
  -- 3. is this the last group with that key?
  SELECT "id" INTO _oid FROM "group" WHERE "key"=_key AND "id"<>_id LIMIT 1;
  IF _key IS NOT NULL AND _oid IS NULL THEN
  -- 4. delete types key, #key
    PERFORM type_deleteone(json_build_object('id', _key));
    PERFORM type_deleteone(json_build_object('id', '#'||_key));
  END IF;
  -- 5. drop view of this group
  EXECUTE format('DROP VIEW IF EXISTS %I RESTRICT', _id);
  -- 6. delete group (finally, needs big persistence)
  DELETE FROM "group" WHERE "id"=_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_selectone" (JSON)
RETURNS "group" AS $$
  SELECT * FROM "group" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;
