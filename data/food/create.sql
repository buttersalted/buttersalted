CREATE TABLE IF NOT EXISTS "food" (
  "id" INT NOT NULL,
  PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "food_pending" (
  "value" TEXT NOT NULL,
  CHECK ("value"<>'')
);

CREATE OR REPLACE FUNCTION "food_insertone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  IF row_to_json(json_populate_record(NULL::"food", _a))::JSONB @> _a::JSONB THEN
    INSERT INTO "food" SELECT * FROM json_populate_record(NULL::"food", _a);
    DELETE FROM "food_pending" WHERE "value"=_a::TEXT;
  ELSE
    RAISE EXCEPTION 'Bad row: %', _a::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "food_deleteone" (
  IN _a JSON
) RETURNS VOID AS $$
DECLARE
  _id INT;
BEGIN
  SELECT "id" INTO _id FROM json_populate_record(NULL::"food", _a);
  DELETE FROM "food" WHERE "id"=_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "food_pendinginsert" (
) RETURNS VOID AS $$
DECLARE
  _value TEXT;
BEGIN
  FOR _value IN SELECT "value" FROM "food_pending" LOOP
    PERFORM food_insertone(_value::JSON);
  END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "food_pendingdeleteone" (
  IN _value TEXT
) RETURNS VOID AS $$
BEGIN
  DELETE FROM "food_pending" WHERE "value"=_value;
END;
$$ LANGUAGE plpgsql;
