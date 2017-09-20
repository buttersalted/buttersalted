-- 1. create table to store alternate terms for "type"
CREATE TABLE IF NOT EXISTS "term" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'' AND "value"<>''),
-- 2. prevent "type" delete and cascade update
  FOREIGN KEY ("value") REFERENCES "type" ("id")
  ON DELETE NO ACTION ON UPDATE CASCADE
);
-- 3. create index for value (for sonic speeds)
CREATE INDEX IF NOT EXISTS "term_value_idx"
ON "term" ("value");


CREATE OR REPLACE FUNCTION "term_insertone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  -- 1. insert into table using json directly
  INSERT INTO "term" SELECT * FROM json_populate_record(NULL::"term", _a);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "term_upsertone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  -- 1. should try to insert first, else make an update
  INSERT INTO "term" VALUES (_a->>'id', _a->>'value')
  ON CONFLICT DO UPDATE SET "value"=_a->>'value';
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "term_deleteone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  -- 1. delete row from table
  DELETE FROM "term" WHERE id=_a->>'id';
END;
$$ LANGUAGE plpgsql;
