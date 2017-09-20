CREATE TABLE IF NOT EXISTS "food" (
  "id" INT NOT NULL,
  PRIMARY KEY ("id")
);


CREATE OR REPLACE FUNCTION "food_insertone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  IF row_to_json(json_populate_record(NULL::"food", _a))::JSONB @> _a::JSONB THEN
    INSERT INTO "food" SELECT * FROM json_populate_record(NULL::"food", _a);
  ELSE
    RAISE EXCEPTION 'Bad row: %', _a::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "food_deleteone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  DELETE FROM "food" WHERE "id"=_a->>'id'::INT;
END;
$$ LANGUAGE plpgsql;
