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
    ("tag" = NULL OR "tag" <> '') AND
    "value" NOT LIKE '%;%' AND
    lower("value") LIKE 'select %' AND
    lower("value") NOT LIKE '% into %'
  )
);

CREATE OR REPLACE FUNCTION "group_executeone" (
  IN _field TEXT,
  IN _value TEXT
) AS $$
DECLARE
  _query TEXT;
BEGIN
  SELECT "query" INTO _query FROM "group"
  WHERE "field"=_field AND "value"=_value;
  EXECUTE 'WITH ('||_query||') AS t '||
  'UPDATE t SET "'||_field||'"='
END;
$$ LANGUAGE plpgsql;
