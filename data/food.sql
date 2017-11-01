-- 1. create bare table for storing food details
CREATE TABLE IF NOT EXISTS "food" (
  "Id" INT NOT NULL,
  PRIMARY KEY ("Id")
);


CREATE OR REPLACE FUNCTION "food_jsonb" (JSONB)
RETURNS JSONB AS $$
  -- 4. aggregate all keys and values to jsonb
  SELECT jsonb_object_agg("key", "value") FROM (
  -- 2. field names to base field names
  SELECT coalesce(fillin_field("key"), "key") AS "key",
  -- 3. unit values to base unit values
  field_toreal("value", coalesce(fillin_field("key"), "key")) AS "value"
  -- 1. get keys, values from input
  FROM jsonb_each_text($1) t) u;
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "food_selectone" (JSONB)
RETURNS SETOF "food" AS $$
  SELECT * FROM "food" WHERE "Id"=(food_jsonb($1)->>'Id')::INT;
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "food_insertone" (_a JSONB)
RETURNS VOID AS $$
DECLARE
  -- 1. get base, row
  _b JSONB := food_jsonb(_a);
  _r JSONB := row_to_json(jsonb_populate_record(NULL::"food", _b));
BEGIN
  -- 2. does it have any extra columns?
  IF NOT jsonb_keys(_r) @> jsonb_keys(_b) THEN
    RAISE EXCEPTION 'invalid column(s): %',
    array_removes(jsonb_keys(_b), jsonb_keys(_r))::TEXT;
  END IF;
  -- 3. insert to table
  INSERT INTO "food" SELECT * FROM
  jsonb_populate_record(NULL::"food", table_default('food')||_b);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "food_deleteone" (JSONB)
RETURNS VOID AS $$
  DELETE FROM "food" WHERE "Id"=(food_jsonb($1)->>'Id')::INT;
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "food_updateone" (_f JSONB, _t JSONB)
RETURNS VOID AS $$
DECLARE
  _r JSONB := row_to_json(food_selectone(food_jsonb(_f)));
  _z JSONB := food_jsonb(_t)||_r;
BEGIN
  PERFORM food_deleteone(_r);
  PERFORM food_insertone(_z);
END;
$$ LANGUAGE plpgsql;
