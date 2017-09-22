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
BEGIN
  _a := food_tobase(_a);
  IF row_to_json(json_populate_record(NULL::"food", _a)) @> json_keys(_a) THEN
    INSERT INTO "food" SELECT * FROM json_populate_record(NULL::"food", _a);
  ELSE
    RAISE EXCEPTION 'invalid row %', _a::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "food_deleteone" (JSON)
RETURNS VOID AS $$
  DELETE FROM "food" WHERE "id"=($1->>'id')::INT;
$$ LANGUAGE SQL;
