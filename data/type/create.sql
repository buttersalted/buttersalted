CREATE TABLE IF NOT EXISTS "type" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'' AND "value"<>'')
);
CREATE INDEX IF NOT EXISTS "idx_type_value"
ON "type" ("value");

CREATE OR REPLACE FUNCTION "type_insertone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  INSERT INTO "type" SELECT * FROM json_populate_record(NULL::"type", _a);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "type_upsertone" (
  IN _a JSON
) RETURNS VOID AS $$
DECLARE
  _id    TEXT;
  _value TEXT;
BEGIN
  SELECT "id", "value" INTO _id, _value FROM json_populate_record(NULL::"type", _a);
  INSERT INTO "type" VALUES (_id, _value)
  ON CONFLICT DO UPDATE SET "value"=_value;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "type_deleteone" (
  IN _a JSON
) RETURNS VOID AS $$
DECLARE
  _id TEXT;
BEGIN
  SELECT "id" INTO _id FROM json_populate_record(NULL::"type", _a);
  DELETE FROM "type" WHERE id=_id;
END;
$$ LANGUAGE plpgsql;
