-- 1. create bare table for storing food details
CREATE TABLE IF NOT EXISTS "food" (
  "Id" INT NOT NULL,
  PRIMARY KEY ("Id")
);


CREATE OR REPLACE FUNCTION "food_tobase" (JSONB)
RETURNS JSONB AS $$
  -- 4. aggregate all keys and values to jsonb
  SELECT jsonb_object_agg("key", "value") FROM (
  -- 2. field names to base field names
  SELECT coalesce(term_value("key"), "key") AS "key",
  -- 3. unit values to base unit values
  unit_convert("value", coalesce(term_value("key"), "key")) AS "value"
  -- 1. get keys, values from input
  FROM jsonb_each_text($1) t) u;
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "food_insertone" (_a JSONB)
RETURNS VOID AS $$
DECLARE
  -- 1. get base jsonb and row jsonb
  _b   JSONB := food_tobase(_a);
  _row JSONB := row_to_json(jsonb_populate_record(NULL::"food", _b))::JSONB;
BEGIN
  -- 2. does it fit in the row (no extra columns)?
  IF NOT jsonb_keys(_row) @> jsonb_keys(_b) THEN
    RAISE EXCEPTION 'invalid column(s): %',
    array_removes(jsonb_keys(_b), jsonb_keys(_row))::TEXT;
  END IF;
  -- 3. insert to table (hopefully valid data)
  INSERT INTO "food" SELECT * FROM
  jsonb_populate_record(NULL::"food", table_default('food')||_b);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "food_deleteone" (JSONB)
RETURNS VOID AS $$
  DELETE FROM "food" WHERE "Id"=($1->>'Id')::INT;
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "food_selectone" (JSONB)
RETURNS SETOF "food" AS $$
  SELECT * FROM "food" WHERE "Id"=($1->>'Id')::INT;
$$ LANGUAGE SQL;
