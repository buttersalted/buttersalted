-- I. create table to store unit conversion factors
CREATE TABLE IF NOT EXISTS "unit" (
  "id"     TEXT NOT NULL,
  "factor" REAL NOT NULL DEFAULT 1,
  "offset" REAL NOT NULL DEFAULT 0,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'')
);


CREATE OR REPLACE FUNCTION "unit_get" (TEXT)
RETURNS "unit" AS $$
  -- 1. get exact or lowercase matching unit
  SELECT * FROM "unit" WHERE "id"=$1 UNION ALL
  SELECT * FROM "unit" WHERE "id"=lower($1) LIMIT 1;
$$ LANGUAGE SQL STABLE;


CREATE OR REPLACE FUNCTION "unit_convert" (REAL, TEXT, TEXT)
RETURNS REAL AS $$
  -- 1. convert number from one unit to another
  SELECT ($1*f."factor"+f."offset"-t."offset")/t."factor"
  FROM unit_get($2) f, unit_get($3) t;
$$ LANGUAGE SQL STABLE;


CREATE OR REPLACE FUNCTION "unit_toreal" (TEXT, TEXT, TEXT)
RETURNS REAL AS $$
  -- 1. convert text from one unit to another as number
  SELECT unit_convert(real_get($1)::REAL,
  coalesce(nullif(btrim(replace($1, real_get($1), '')), ''), $2), $3);
$$ LANGUAGE SQL STABLE;


CREATE OR REPLACE FUNCTION "unit_totext" (REAL, TEXT, TEXT)
RETURNS TEXT AS $$
  -- 1. convert number from one unit to another as text
  SELECT (unit_convert($1, $2, $3)::TEXT)||$3;
$$ LANGUAGE SQL STABLE;


CREATE OR REPLACE FUNCTION "unit_selectone" (JSONB)
RETURNS SETOF "unit" AS $$
  -- 1. select a row
  SELECT * FROM "unit" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_insertone" (JSONB)
RETURNS VOID AS $$
  -- 1. insert a row
  INSERT INTO "unit" SELECT * FROM
  jsonb_populate_record(NULL::"unit", table_default('unit')||$1);
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_deleteone" (JSONB)
RETURNS VOID AS $$
  -- 1. delete a row
  DELETE FROM "unit" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "unit_updateone" (JSONB, JSONB)
RETURNS VOID AS $$
  -- 1. update a row
  UPDATE "unit" SET "id"=coalesce($2->>'id', r."id"),
  "factor"=coalesce(($2->>'factor')::REAL, r."factor"),
  "offset"=coalesce(($2->>'offset')::REAL, r."offset")
  FROM (SELECT * FROM "unit" WHERE "id"=$1->>'id') r
  WHERE "id"=$1->'id';
$$ LANGUAGE SQL;


-- II. insert default data
CREATE OR REPLACE FUNCTION x(TEXT, REAL, REAL)
RETURNS VOID AS $$
  -- 1. insert a row, if not exists
  INSERT INTO "unit" VALUES ($1, $2, $3) ON CONFLICT ("id") DO NOTHING;
$$ LANGUAGE SQL;
-- 1. empty unit
SELECT x('', 1, 0);
-- 2. short mass units
SELECT x('ng', 1e-12, 0);
SELECT x('μg', 1e-9, 0);
SELECT x('ug', 1e-9, 0);
SELECT x('mg', 1e-6, 0);
SELECT x('g', 1e-3, 0);
SELECT x('gm', 1e-3, 0);
SELECT x('kg', 1, 0);
-- 3. long mass units
SELECT x('nanogram', 1e-12, 0);
SELECT x('microgram', 1e-9, 0);
SELECT x('milligram', 1e-6, 0);
SELECT x('gram', 1e-3, 0);
SELECT x('kilogram', 1, 0);
-- 4. short volume units
SELECT x('ml', 1e-3, 0);
SELECT x('l', 1, 0);
SELECT x('tsp', 5e-3, 0);
SELECT x('tbsp', 15e-3, 0);
-- 5. long volume units
SELECT x('millilitre', 1e-3, 0);
SELECT x('litre', 1e-3, 0);
SELECT x('teaspoon', 0.00492892, 0);
SELECT x('tablespoon', 0.0147868, 0);
SELECT x('fluid ounce', 0.0295735, 0);
SELECT x('cup', 0.24, 0);
SELECT x('pint', 0.473176, 0);
SELECT x('quart', 0.946353, 0);
SELECT x('gallon', 3.78541, 0);
-- 6. short energy units
SELECT x('j', 1, 0);
SELECT x('kj', 1e+3, 0);
SELECT x('cal', 4.184, 0);
SELECT x('kcal', 4.184e+3, 0);
SELECT x('Cal', 4.184e+3, 0)
-- 7. long energy units
SELECT x('joule', 1, 0);
SELECT x('kilojoule', 1e+3, 0);
SELECT x('calorie', 4.184, 0);
SELECT x('kilocalorie', 4.184e+3, 0);
SELECT x('Calorie', 4.184e+3, 0);
-- 8. short temperature units
SELECT x('k', 1, 0);
SELECT x('°c', 1, 273.15);
SELECT x('°f', 1.8, 255.372);
-- 9. long temperature units
SELECT x('kelvin', 1, 0);
SELECT x('celsius', 1, 273.15);
SELECT x('fahrenheit', 1.8, 255.372);
