CREATE TABLE IF NOT EXISTS "group" (
  "field" TEXT NOT NULL,
  "value" TEXT NOT NULL,
  "query" TEXT NOT NULL,
  PRIMARY KEY ("field", "value"),
  CHECK (
    "field" <> '' AND "value" <> '' AND
    "query" NOT LIKE '%;%' AND lower("query") LIKE 'select %'
  )
);
