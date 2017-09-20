-- 1. create table to store data types
CREATE TABLE IF NOT EXISTS "type" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'' AND "value"<>'')
);
-- 2. create index for value (faster search i hope)
CREATE INDEX IF NOT EXISTS "idx_type_value"
ON "type" ("value");


CREATE OR REPLACE FUNCTION "type_insertone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  -- 1. insert into table using json directly (is it required?)
  INSERT INTO "type" SELECT * FROM json_populate_record(NULL::"type", _a);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_upsertone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  -- 1. try to insert row into table, else update
  INSERT INTO "type" VALUES (_a->>'id', _a->>'value')
  ON CONFLICT DO UPDATE SET "value"=_a->>'value';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "type_deleteone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  -- 1. delete from table with id
  DELETE FROM "type" WHERE id=_a->>'id';
END;
$$ LANGUAGE plpgsql;
