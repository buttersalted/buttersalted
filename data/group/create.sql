CREATE TABLE IF NOT EXISTS "group" (
  "id"    TEXT NOT NULL,
  "key"   TEXT NULL,
  "tag"   TEXT NULL,
  "value" TEXT NOT NULL DEFAULT 'SELECT NULL LIMIT 0',
  PRIMARY KEY ("id"),
  UNIQUE ("key", "tag"),
  CHECK (
    "id" <> '' AND
    ("key" = NULL OR "key" <> '') AND
    "key" NOT LIKE '%_tags' AND
    ("tag" = NULL OR "tag" <> '') AND
    "value" NOT LIKE '%;%' AND
    lower("value") LIKE 'select %' AND
    lower("value") NOT LIKE '% into %'
  )
);

CREATE OR REPLACE FUNCTION "group_appendtag" (
  IN _tags TEXT[],
  IN _tag  TEXT
) RETURNS TEXT[] AS $$
DECLARE
  _a TEXT[];
BEGIN
  SELECT array_agg(DISTINCT a) INTO _a FROM (
    SELECT unnest(array_append(_tags, _tag)) AS a ORDER BY a
  );
  RETURN _a;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "group_insertone" (
  IN _id    TEXT,
  IN _key   TEXT,
  IN _tag   TEXT,
  IN _value TEXT,
) AS $$
BEGIN
  INSERT INTO "group" VALUES (_id, _key, _tag, _value);
  EXECUTE 'CREATE OR REPLACE VIEW '||quote_ident(_id)||' AS '||_value;
  SELECT "id" FROM "group" WHERE "key"=_key AND "id"<>_id LIMIT 1;
  IF NOT FOUND AND _key<>NULL THEN
    ALTER TABLE "food" ADD COLUMN IF NOT EXISTS
    quote_ident(_key) TEXT;
    ALTER TABLE "food" ADD COLUMN IF NOT EXISTS
    quote_ident(_key||'_tags') TEXT[];
    CREATE INDEX IF NOT EXISTS quote_ident('idx_food_'||_key)
    ON "food" (quote_ident(_key));
    CREATE INDEX IF NOT EXISTS quote_ident('idx_food_'||_key||'_tags')
    ON "food" (quote_ident(_key||'_tags'));
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "group_deleteone" (
  IN _id TEXT
) AS $$
BEGIN
  SELECT "id" FROM "group" WHERE "key"=_key AND "id"<>_id LIMIT 1;
  IF NOT FOUND AND _key<>NULL THEN
    ALTER TABLE "food" DROP COLUMN IF EXISTS
    quote_ident(_key);
    ALTER TABLE "food" DROP COLUMN IF EXISTS
    quote_ident(_key||'_tags');
  END IF;
  EXECUTE 'DROP VIEW IF EXISTS '||quote_ident(_id)||' RESTRICT';
  DELETE FROM "group" WHERE "id"=_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "group_executeone" (
  IN _id TEXT
) AS $$
DECLARE
  _key TEXT;
  _tag TEXT;
BEGIN
  SELECT "key", "tag" FROM "group" WHERE "id"=_id;
  IF _key<>NULL THEN
    UPDATE quote_ident(_id) SET
    quote_ident(_key)=
    array_to_string(group_appendtag(quote_ident(_key||'_tags'), _tag)) AND
    quote_ident(_key||'_tags')=
    group_appendtag(quote_ident(_key||'_tags'), _tag)
    WHERE NOT quote_ident(_key||'_tags') @> ARRAY[_tag];
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "group_unexecuteone" (
  IN _id TEXT
) AS $$
DECLARE
  _key TEXT;
  _tag TEXT;
BEGIN
SELECT "key", "tag" FROM "group" WHERE "id"=_id;
IF _key<>NULL THEN
  UPDATE quote_ident(_id) SET
  quote_ident(_key)=
  array_to_string(array_remove(quote_ident(_key||'_tags'), _tag)) AND
  quote_ident(_key||'_tags')=
  array_remove(quote_ident(_key||'_tags'), _tag)
  WHERE quote_ident(_key||'_tags') @> ARRAY[_tag];
END IF;
END;
$$ LANGUAGE plpgsql;
