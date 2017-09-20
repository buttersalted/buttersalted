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


CREATE OR REPLACE FUNCTION "group_appendtag" (
  IN _dst TEXT[],
  IN _val TEXT
) RETURNS TEXT[] AS $$
DECLARE
  _z TEXT[];
BEGIN
  -- 2. convert distinct rows into array
  SELECT array_agg(DISTINCT a) INTO _z FROM
  -- 1. get dst appended with val as rows
  (SELECT unnest(array_append(_dst, _val)) AS a ORDER BY a) AS "val";
  -- 3. return array
  RETURN _z;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "group_executeone" (
  IN _a JSON
) RETURNS VOID AS $$
DECLARE
  _id   TEXT;
  _key  TEXT;
  _tag  TEXT;
  _hkey TEXT;
BEGIN
  -- 1. get id from input
  SELECT "id" INTO _id FROM json_populate_record(NULL::"group", _a);
  -- 2. get key, tag from group row
  SELECT "key", "tag" INTO _key, _tag FROM "group" WHERE "id"=_id;
  -- 3. are key and tag known?
  IF _key<>NULL AND _tag<>NULL THEN
  -- 4. generate quoted id, key, tag, #key
    _hkey := quote_ident('#'||_key);
    _tag := quote_literal(_tag);
    _key := quote_ident(_key);
    _id := quote_ident(_id);
  -- 5. update food to add the tag to key, #key (if not exists)
    EXECUTE 'UPDATE "food" SET '||
    _key||'=array_to_string(group_appendtag('||_hkey||','||_tag||')) AND '||
    _hkey||'=group_appendtag('||_hkey||','||_tag||') '||
    'WHERE NOT '||_hkey||' @> ARRAY['||_tag||']';
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
  _hkey TEXT;
BEGIN
  -- 1. get id from input
  SELECT "id" INTO _id FROM json_populate_record(NULL::"group", _a);
  -- 2. get key, tag from group row
  SELECT "key", "tag" INTO _key, _tag FROM "group" WHERE "id"=_id;
  -- 3. are key and tag are known?
  IF _key<>NULL AND _tag<>NULL THEN
  -- 4. generate quoted id, key, tag, and #key
    _hkey := quote_ident('#'||_key);
    _tag := quote_literal(_tag);
    _key := quote_ident(_key);
    _id := quote_ident(_id);
  -- 5. update food to remove the tag from key, #key (if exists)
    EXECUTE 'UPDATE "food" SET'||
    _key||'=array_to_string(array_remove('||_hkey||','||_tag||')) AND '||
    _hkey||'=array_remove('||_hkey||','||_tag||') '||
    'WHERE '||_hkey||' @> ARRAY['||_tag||']';
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
  SELECT "id", "key", "value" INTO _id, _key, _value FROM
  json_populate_record(NULL::"group", _a);
  -- 2. insert record into table
  INSERT INTO "group" SELECT * FROM json_populate_record(NULL::"group", _a);
  -- 3. create view (id) using value
  EXECUTE 'CREATE OR REPLACE VIEW '||quote_ident(_id)||' AS '||_value;
  -- 4. is this the first group with that key?
  SELECT "id" INTO _oid FROM "group" WHERE "key"=_key AND "id"<>_id LIMIT 1;
  IF _out=NULL THEN
    EXECUTE '_oid=NULL';
  ELSE
    EXECUTE '_oid='||_oid;
  END IF;
  IF _key<>NULL AND _oid=NULL THEN
  -- 5. add columns key, #key
    EXECUTE 'ALTER TABLE "food" ADD COLUMN IF NOT EXISTS'||
    quote_ident(_key)||' TEXT';
    EXECUTE 'ALTER TABLE "food" ADD COLUMN IF NOT EXISTS'||
    quote_ident('#'||_key)||' TEXT[]';
  -- 6. add indexes for key, #key
    EXECUTE 'CREATE INDEX IF NOT EXISTS '||quote_ident('idx_food_'||_key)||
    'ON "food" ('||quote_ident(_key)||')';
    EXECUTE 'CREATE INDEX IF NOT EXISTS '||quote_ident('idx_food_#'||_key)||
    'ON "food" USING gin ('||quote_ident('#'||_key)||')';
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
  SELECT "id", "key" INTO _id, _key FROM
  json_populate_record(NULL::"group", _a);
  -- 2. remove tag from key
  PERFORM group_unexecuteone(_a);
  -- 3. is this the last group with that key?
  SELECT "id" INTO _oid FROM "group" WHERE "key"=_key AND "id"<>_id LIMIT 1;
  IF _key<>NULL AND _oid=NULL THEN
  -- 4. drop columns key, #key (indexes dropped too)
    EXECUTE 'ALTER TABLE "food" DROP COLUMN IF EXISTS '||quote_ident(_key);
    EXECUTE 'ALTER TABLE "food" DROP COLUMN IF EXISTS '||quote_ident('#'||_key);
  END IF;
  -- 5. drop view of this group
  EXECUTE 'DROP VIEW IF EXISTS '||quote_ident(_id)||' RESTRICT';
  -- 6. delete group (finally, needs big persistence)
  DELETE FROM "group" WHERE "id"=_id;
END;
$$ LANGUAGE plpgsql;
