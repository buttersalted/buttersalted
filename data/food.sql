CREATE TABLE IF NOT EXISTS "food" (
  "id" INT NOT NULL,
  PRIMARY KEY ("id")
);


CREATE OR REPLACE FUNCTION "food_insertone" (
  IN _a JSON
) RETURNS VOID AS $$
DECLARE
  _row JSON;
BEGIN
  _row := row_to_json(json_populate_record(NULL::"food", _a));
  IF NOT json_keys(_row) @> json_keys(_a) THEN
    RAISE EXCEPTION 'Bad row: %', _a::TEXT;
  END IF;
  SELECT json_object_agg("key", "value") FROM (
    SELECT coalesce(term_selectone("key"), "key") AS "key", "value"
    FROM json_each(_a) t) u;
  INSERT INTO "food" SELECT * FROM json_populate_record(NULL::"food", _a);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "food_deleteone" (
  IN _a JSON
) RETURNS VOID AS $$
BEGIN
  DELETE FROM "food" WHERE "id"=_a->>'id'::INT;
END;
$$ LANGUAGE plpgsql;
