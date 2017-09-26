-- 1. create table to store data types
CREATE TABLE IF NOT EXISTS "type" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'' AND "value"<>'')
);
CREATE INDEX IF NOT EXISTS "type_value_idx"
ON "type" ("value");


CREATE OR REPLACE FUNCTION "type_value" (TEXT)
RETURNS TEXT AS $$
  SELECT "value" FROM "type" WHERE "id"=$1;
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "type_insertone" (_a JSONB)
RETURNS VOID AS $$
DECLARE
-- 1. get id, value, index
  _id    TEXT := _a->>'id';
  _value TEXT := upper(_a->>'value');
  _index TEXT := coalesce(_a->>'index', 'btree');
BEGIN
  -- 2. insert into table (fail early)
  INSERT INTO "type" VALUES (_id, _value);
  -- 3. add column id to food table with index (if column)
  IF _value<>'TABLE' THEN
    EXECUTE format('ALTER TABLE "food" ADD COLUMN IF NOT EXISTS %I %s',
      _id, _value);
    EXECUTE format('CREATE INDEX IF NOT EXISTS %I ON "food" USING %s (%I)',
      'food_'||_id||'_idx', _index, _id);
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_deleteone" (_a JSONB)
RETURNS VOID AS $$
BEGIN
  -- 1. delete from table and drop column
  DELETE FROM "type" WHERE "id"=_a->>'id';
  EXECUTE format('ALTER TABLE "food" DROP COLUMN IF EXISTS %I', _a->>'id');
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_upsertone" (_a JSONB)
RETURNS VOID AS $$
BEGIN
  PERFORM type_deleteone(_a);
  PERFORM type_insertone(_a);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION "type_selectone" (JSONB)
RETURNS SETOF "type" AS $$
  SELECT * FROM "type" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "type_insertone" (_id TEXT, _value TEXT)
RETURNS VOID AS $$
BEGIN
  PERFORM type_insertone(jsonb_build_object('id', _id, 'value', _value));
END;
$$ LANGUAGE plpgsql;


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
