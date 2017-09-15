CREATE TABLE IF NOT EXISTS "food" (
  "id" INT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'')
);

CREATE TABLE IF NOT EXISTS "food_pending" (
  "value" TEXT NOT NULL,
  CHECK ("value"<>'')
)

CREATE OR REPLACE FUNCTION "food_insertone" (
  IN _val TEXT
) AS $$
DECLARE
  _out JSON;
BEGIN
  DELETE FROM "food_pending" WHERE "value"=_val;
  _out := json_populate_record(NULL::"food", _val::JSON);
  IF row_to_json(_out) @> _val::JSON THEN
    INSERT INTO "food" SELECT * FROM _out;
  ELSE
    INSERT INTO "food_pending" VALUES(_val);
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "food_pending_insert" (
) AS $$
DECLARE
  _val JSON;
  _out JSON;
BEGIN
  FOR _val IN SELECT "value" FROM "food_pending" LOOP
    _out := json_populate_record(NULL::"food", _val);
    IF row_to_json(_out) @> _val THEN
      DELETE FROM "food_pending" WHERE "value"=_val;
      INSERT INTO "food" SELECT * FROM _out;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

/* INSERT DEFAULT DATA HERE */
