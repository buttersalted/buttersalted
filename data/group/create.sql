CREATE TABLE IF NOT EXISTS "group" (
  "id"    TEXT NOT NULL,
  "key"   TEXT NULL,
  "tag"   TEXT NULL,
  "value" TEXT NOT NULL DEFAULT 'SELECT NULL LIMIT 0',
  PRIMARY KEY ("id"),
  UNIQUE ("key", "tag"),
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
  SELECT array_agg(DISTINCT a) INTO _z FROM
  (SELECT unnest(array_append(_dst, _val)) AS a ORDER BY a);
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
  _tkey TEXT;
BEGIN
  SELECT "id" INTO _id FROM json_populate_record(NULL::"group", _a);
  SELECT "key", "tag" INTO _key, _tag FROM "group" WHERE "id"=_id;
  IF _key<>NULL AND _tag<>NULL THEN
    _tkey := quote_ident('#'||_key);
    _tag := quote_literal(_tag);
    _key := quote_ident(_key);
    _id := quote_ident(_id);
    EXECUTE 'UPDATE "food" SET '||
    _key||'=array_to_string(group_appendtag('||_tkey||','||_tag||')) AND '||
    _tkey||'=group_appendtag('||_tkey||','||_tag||') '||
    'WHERE NOT '||_tkey||' @> ARRAY['||_tag||']';
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
  _tkey TEXT;
BEGIN
SELECT "id" INTO _id FROM json_populate_record(NULL::"group", _a);
SELECT "key", "tag" INTO _key, _tag FROM "group" WHERE "id"=_id;
IF _key<>NULL AND _tag<>NULL THEN
  _tkey := quote_ident('#'||_key);
  _tag := quote_literal(_tag);
  _key := quote_ident(_key);
  _id := quote_ident(_id);
  EXECUTE 'UPDATE "food" SET'||
  _key||'=array_to_string(array_remove('||_tkey||','||_tag||')) AND '||
  _tkey||'=array_remove('||_tkey||','||_tag||') '||
  'WHERE '||_tkey||' @> ARRAY['||_tag||']';
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
  SELECT "id", "key", "value" INTO _id, _key, _value FROM
  json_populate_record(NULL::"group", _a);
  INSERT INTO "group" SELECT FROM json_populate_record(NULL::"group", _a);
  EXECUTE 'CREATE OR REPLACE VIEW '||quote_ident(_id)||' AS '||_value;
  SELECT "id" INTO _oid FROM "group" WHERE "key"=_key AND "id"<>_id LIMIT 1;
  IF _oid<>NULL AND _key<>NULL THEN
    EXECUTE 'ALTER TABLE "food" ADD COLUMN IF NOT EXISTS'||
    quote_ident(_key)||' TEXT';
    EXECUTE 'ALTER TABLE "food" ADD COLUMN IF NOT EXISTS'||
    quote_ident('#'||_key)||' TEXT[]';
    EXECUTE 'CREATE INDEX IF NOT EXISTS '||quote_ident('idx_food_'||_key)||
    'ON "food" ('||quote_ident(_key)||')';
    EXECUTE 'CREATE INDEX IF NOT EXISTS '||quote_ident('idx_food_#'||_key)||
    'ON "food" USING gin('||quote_ident('#'||_key)||')';
  END IF;
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
  SELECT "id", "key" INTO _id, _key FROM
  json_populate_record(NULL::"group", _a);
  PERFORM group_unexecuteone(_a);
  SELECT "id" INTO _oid FROM "group" WHERE "key"=_key AND "id"<>_id LIMIT 1;
  IF _oid<>NULL AND _key<>NULL THEN
    EXECUTE 'ALTER TABLE "food" DROP COLUMN IF EXISTS '||quote_ident(_key);
    EXECUTE 'ALTER TABLE "food" DROP COLUMN IF EXISTS '||quote_ident('#'||_key);
  END IF;
  EXECUTE 'DROP VIEW IF EXISTS '||quote_ident(_id)||' RESTRICT';
  DELETE FROM "group" WHERE "id"=_id;
END;
$$ LANGUAGE plpgsql;
