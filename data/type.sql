CREATE OR REPLACE FUNCTION "type_create" (
) RETURNS VOID AS $$
BEGIN
  CREATE TABLE IF NOT EXISTS "type" (
    "id"    TEXT NOT NULL,
    "value" TEXT NOT NULL,
    PRIMARY KEY ("id"),
    CHECK ("id"<>'' AND "value"<>'')
  );
  CREATE INDEX IF NOT EXISTS "idx_type_value"
  ON "type" ("value");
END;
$$ LANGUAGE plpgsql;

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
BEGIN
  INSERT INTO "type" VALUES (_a->>'id', _a->>'value')
  ON CONFLICT DO UPDATE SET "value"=_a->>'value';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "type_deleteone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  DELETE FROM "type" WHERE id=_a->>'id';
END;
$$ LANGUAGE plpgsql;
