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
    array_remove(jsonb_keys(_b), jsonb_keys(_row))::TEXT;
  END IF;
  RAISE EXCEPTION 'valid row %', _a::TEXT;
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


/* DEFAULT VALUES */
INSERT INTO "type" VALUES ('Id', 'INT NOT NULL');
SELECT type_insertone('Name', 'TEXT NOT NULL');
SELECT type_insertone('Food Group', 'TEXT');
SELECT type_insertone('Carbohydrate Factor', 'REAL');
SELECT type_insertone('Fat Factor', 'REAL');
SELECT type_insertone('Protein Factor', 'REAL');
SELECT type_insertone('Nitrogen to Protein Conversion Factor', 'REAL');
SELECT type_insertone('Water', 'REAL');
SELECT type_insertone('Energy', 'REAL');
SELECT type_insertone('Protein', 'REAL');
SELECT type_insertone('Total lipid (fat)', 'REAL');
SELECT type_insertone('Ash', 'REAL');
SELECT type_insertone('Carbohydrate, by difference', 'REAL');
SELECT type_insertone('Fiber, total dietary', 'REAL');
SELECT type_insertone('Sugars, total', 'REAL');
SELECT type_insertone('Calcium, Ca', 'REAL');
SELECT type_insertone('Iron, Fe', 'REAL');
SELECT type_insertone('Magnesium, Mg', 'REAL');
SELECT type_insertone('Phosphorus, P', 'REAL');
SELECT type_insertone('Potassium, K', 'REAL');
SELECT type_insertone('Sodium, Na', 'REAL');
SELECT type_insertone('Zinc, Zn', 'REAL');
SELECT type_insertone('Copper, Cu', 'REAL');
SELECT type_insertone('Manganese, Mn', 'REAL');
SELECT type_insertone('Selenium, Se', 'REAL');
SELECT type_insertone('Fluoride, F', 'REAL');
SELECT type_insertone('Vitamin C, total ascorbic acid', 'REAL');
SELECT type_insertone('Thiamin', 'REAL');
SELECT type_insertone('Riboflavin', 'REAL');
SELECT type_insertone('Niacin', 'REAL');
SELECT type_insertone('Pantothenic acid', 'REAL');
SELECT type_insertone('Vitamin B-6', 'REAL');
SELECT type_insertone('Folate, total', 'REAL');
SELECT type_insertone('Folic acid', 'REAL');
SELECT type_insertone('Folate, food', 'REAL');
SELECT type_insertone('Folate, DFE', 'REAL');
SELECT type_insertone('Choline, total', 'REAL');
SELECT type_insertone('Betaine', 'REAL');
SELECT type_insertone('Vitamin B-12', 'REAL');
SELECT type_insertone('Vitamin B-12, added', 'REAL');
SELECT type_insertone('Vitamin A, RAE', 'REAL');
SELECT type_insertone('Retinol', 'REAL');
SELECT type_insertone('Carotene, beta', 'REAL');
SELECT type_insertone('Carotene, alpha', 'REAL');
SELECT type_insertone('Cryptoxanthin, beta', 'REAL');
SELECT type_insertone('Vitamin A, IU', 'REAL');
SELECT type_insertone('Lycopene', 'REAL');
SELECT type_insertone('Lutein + zeaxanthin', 'REAL');
SELECT type_insertone('Vitamin E (alpha-tocopherol)', 'REAL');
SELECT type_insertone('Vitamin E, added', 'REAL');
SELECT type_insertone('Tocopherol, beta', 'REAL');
SELECT type_insertone('Tocopherol, gamma', 'REAL');
SELECT type_insertone('Tocopherol, delta', 'REAL');
SELECT type_insertone('Vitamin D (D2 + D3)', 'REAL');
SELECT type_insertone('Vitamin D2 (ergocalciferol)', 'REAL');
SELECT type_insertone('Vitamin D3 (cholecalciferol)', 'REAL');
SELECT type_insertone('Vitamin D', 'REAL');
SELECT type_insertone('Vitamin K (phylloquinone)', 'REAL');
SELECT type_insertone('Fatty acids, total saturated', 'REAL');
SELECT type_insertone('Butanoic acid', 'REAL');
SELECT type_insertone('Hexanoic acid', 'REAL');
SELECT type_insertone('Octanoic acid', 'REAL');
SELECT type_insertone('Decanoic acid', 'REAL');
SELECT type_insertone('Dodecanoic acid', 'REAL');
SELECT type_insertone('Tetradecanoic acid', 'REAL');
SELECT type_insertone('Hexadecanoic acid', 'REAL');
SELECT type_insertone('Heptadecanoic acid', 'REAL');
SELECT type_insertone('Octadecanoic acid', 'REAL');
SELECT type_insertone('Eicosanoic acid', 'REAL');
SELECT type_insertone('Fatty acids, total monounsaturated', 'REAL');
SELECT type_insertone('Hexadecenoic acid', 'REAL');
SELECT type_insertone('Cis-hexadecenoic acid', 'REAL');
SELECT type_insertone('Octadecenoic acid', 'REAL');
SELECT type_insertone('Cis-octadecenoic acid', 'REAL');
SELECT type_insertone('Trans-octadecenoic acid', 'REAL');
SELECT type_insertone('Eicosenoic acid', 'REAL');
SELECT type_insertone('Docosenoic acid', 'REAL');
SELECT type_insertone('Fatty acids, total polyunsaturated', 'REAL');
SELECT type_insertone('Octadecadienoic acid', 'REAL');
SELECT type_insertone('Cis,cis-octadecadienoic n-6 acid', 'REAL');
SELECT type_insertone('Octadecadienoic CLAs acid', 'REAL');
SELECT type_insertone('Irans-Octadecadienoic acid', 'REAL');
SELECT type_insertone('Octadecatrienoic acid', 'REAL');
SELECT type_insertone('Cis,cis,cis-octadecatrienoic n-3 acid', 'REAL');
SELECT type_insertone('Octadecatetraenoic acid', 'REAL');
SELECT type_insertone('Eicosatetraenoic acid', 'REAL');
SELECT type_insertone('Eicosapentaenoic n-3 acid', 'REAL');
SELECT type_insertone('Docosapentaenoic n-3 acid', 'REAL');
SELECT type_insertone('Docosahexaenoic n-3 acid', 'REAL');
SELECT type_insertone('Fatty acids, total trans', 'REAL');
SELECT type_insertone('Fatty acids, total trans-monoenoic', 'REAL');
SELECT type_insertone('Fatty acids, total trans-polyenoic', 'REAL');
SELECT type_insertone('Cholesterol', 'REAL');
SELECT type_insertone('Stigmasterol', 'REAL');
SELECT type_insertone('Campesterol', 'REAL');
SELECT type_insertone('Beta-sitosterol', 'REAL');
SELECT type_insertone('Tryptophan', 'REAL');
SELECT type_insertone('Threonine', 'REAL');
SELECT type_insertone('Isoleucine', 'REAL');
SELECT type_insertone('Leucine', 'REAL');
SELECT type_insertone('Lysine', 'REAL');
SELECT type_insertone('Methionine', 'REAL');
SELECT type_insertone('Cystine', 'REAL');
SELECT type_insertone('Phenylalanine', 'REAL');
SELECT type_insertone('Tyrosine', 'REAL');
SELECT type_insertone('Valine', 'REAL');
SELECT type_insertone('Arginine', 'REAL');
SELECT type_insertone('Histidine', 'REAL');
SELECT type_insertone('Alanine', 'REAL');
SELECT type_insertone('Aspartic acid', 'REAL');
SELECT type_insertone('Glutamic acid', 'REAL');
SELECT type_insertone('Glycine', 'REAL');
SELECT type_insertone('Proline', 'REAL');
SELECT type_insertone('Serine', 'REAL');
SELECT type_insertone('Alcohol, ethyl', 'REAL');
SELECT type_insertone('Caffeine', 'REAL');
SELECT type_insertone('Theobromine', 'REAL');


/* DEFAULT VALUES */
INSERT INTO "term" VALUES ('id', 'Id');
SELECT term_insertone('4:0', 'Butanoic acid');
SELECT term_insertone('6:0', 'Hexanoic acid');
SELECT term_insertone('8:0', 'Octanoic acid');
SELECT term_insertone('10:0', 'Decanoic acid');
SELECT term_insertone('12:0', 'Dodecanoic acid');
SELECT term_insertone('14:0', 'Tetradecanoic acid');
SELECT term_insertone('16:0', 'Hexadecanoic acid');
SELECT term_insertone('17:0', 'Heptadecanoic acid');
SELECT term_insertone('18:0', 'Octadecanoic acid');
SELECT term_insertone('20:0', 'Eicosanoic acid');
SELECT term_insertone('16:1 undifferentiated', 'Hexadecenoic acid');
SELECT term_insertone('16:1 c', 'Cis-hexadecenoic acid');
SELECT term_insertone('18:1 undifferentiated', 'Octadecenoic acid');
SELECT term_insertone('18:1 c', 'Cis-octadecenoic acid');
SELECT term_insertone('18:1 t', 'Trans-octadecenoic acid');
SELECT term_insertone('20:1', 'Eicosenoic acid');
SELECT term_insertone('22:1 undifferentiated', 'Docosenoic acid');
SELECT term_insertone('18:2 undifferentiated', 'Octadecadienoic acid');
SELECT term_insertone('18:2 n-6 c,c', 'Cis,cis-octadecadienoic n-6 acid');
SELECT term_insertone('18:2 CLAs', 'Octadecadienoic CLAs acid');
SELECT term_insertone('18:2 i', 'Irans-Octadecadienoic acid');
SELECT term_insertone('18:3 undifferentiated', 'Octadecatrienoic acid');
SELECT term_insertone('18:3 n-3 c,c,c (ALA)', 'Cis,cis,cis-octadecatrienoic n-3 acid');
SELECT term_insertone('18:4', 'Octadecatetraenoic acid');
SELECT term_insertone('20:4 undifferentiated', 'Eicosatetraenoic acid');
SELECT term_insertone('20:5 n-3 (EPA)', 'Eicosapentaenoic n-3 acid');
SELECT term_insertone('22:5 n-3 (DPA)', 'Docosapentaenoic n-3 acid');
SELECT term_insertone('22:6 n-3 (DHA)', 'Docosahexaenoic n-3 acid');
