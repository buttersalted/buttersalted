CREATE TABLE IF NOT EXISTS "name" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'' AND "value"<>''),
  FOREIGN KEY ("value") REFERENCES "type" ("id")
  ON DELETE NO ACTION ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS "idx_name_value"
ON "name" ("value");

CREATE OR REPLACE FUNCTION "name_insertone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  INSERT INTO "name" SELECT * FROM json_populate_record(NULL::"name", _a);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "name_upsertone" (
  IN _a JSON
) RETURNS VOID AS $$
DECLARE
  _id    TEXT;
  _value TEXT;
BEGIN
  SELECT "id", "value" INTO _id, _value FROM json_populate_record(NULL::"name", _a);
  INSERT INTO "name" VALUES (_id, _value)
  ON CONFLICT DO UPDATE SET "value"=_value;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "name_deleteone" (
  IN _a JSON
) RETURNS VOID AS $$
DECLARE
  _id TEXT;
BEGIN
  SELECT "id" INTO _id FROM json_populate_record(NULL::"name", _a);
  DELETE FROM "name" WHERE id=_id;
END;
$$ LANGUAGE plpgsql;
