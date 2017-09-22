-- 1. create bare table for storing food details
CREATE TABLE IF NOT EXISTS "food" (
  "id" INT NOT NULL,
  PRIMARY KEY ("id")
);


CREATE OR REPLACE FUNCTION "food_tobase" (JSON)
RETURNS JSON AS $$
  -- 4. aggregate all keys and values to json
  SELECT json_object_agg("key", "value") FROM (
  -- 2. field names to base field names
  SELECT coalesce(term_value("key"), "key") AS "key",
  -- 3. unit values to base unit values
  unit_convert("value", coalesce(term_value("key"), "key")) AS "value"
  -- 1. get keys, values from input
  FROM json_each_text($1) t) u;
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "food_insertone" (_a JSON)
RETURNS VOID AS $$
DECLARE
  -- 1. get base json and row json
  _b   JSON := food_tobase(_a);
  _row JSON := row_to_json(json_populate_record(NULL::"food", _b));
BEGIN
  -- 2. does it fit in the row (no extra columns)?
  IF NOT json_keys(_row) @> json_keys(_b) THEN
    RAISE EXCEPTION 'invalid row %', _b::TEXT;
  END IF;
  -- 3. insert to table (hopefully valid data)
  INSERT INTO "food" SELECT * FROM json_populate_record(NULL::"food", _b);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "food_deleteone" (JSON)
RETURNS VOID AS $$
  DELETE FROM "food" WHERE "id"=($1->>'id')::INT;
$$ LANGUAGE SQL;
