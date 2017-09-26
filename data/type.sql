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


CREATE OR REPLACE FUNCTION "type_insertone" (TEXT, TEXT)
RETURNS VOID AS $$
  SELECT type_insertone(jsonb_build_object('id', $1, 'value', $2));
$$ LANGUAGE SQL;


/* DEFAULT VALUES */
INSERT INTO "type" VALUES ('Id', 'INT NOT NULL');
type_insertone('Name', 'TEXT NOT NULL');
type_insertone('Food Group', 'TEXT');
type_insertone('Carbohydrate Factor', 'REAL');
type_insertone('Fat Factor', 'REAL');
type_insertone('Protein Factor', 'REAL');
type_insertone('Nitrogen to Protein Conversion Factor', 'REAL');
type_insertone('Water', 'REAL');
type_insertone('Energy', 'REAL');
type_insertone('Protein', 'REAL');
type_insertone('Total lipid (fat)', 'REAL');
type_insertone('Ash', 'REAL');
type_insertone('Carbohydrate, by difference', 'REAL');
type_insertone('Fiber, total dietary', 'REAL');
type_insertone('Sugars, total', 'REAL');
type_insertone('Calcium, Ca', 'REAL');
type_insertone('Iron, Fe', 'REAL');
type_insertone('Magnesium, Mg', 'REAL');
type_insertone('Phosphorus, P', 'REAL');
type_insertone('Potassium, K', 'REAL');
type_insertone('Sodium, Na', 'REAL');
type_insertone('Zinc, Zn', 'REAL');
type_insertone('Copper, Cu', 'REAL');
type_insertone('Manganese, Mn', 'REAL');
type_insertone('Selenium, Se', 'REAL');
type_insertone('Fluoride, F', 'REAL');
type_insertone('Vitamin C, total ascorbic acid', 'REAL');
type_insertone('Thiamin', 'REAL');
type_insertone('Riboflavin', 'REAL');
type_insertone('Niacin', 'REAL');
type_insertone('Pantothenic acid', 'REAL');
type_insertone('Vitamin B-6', 'REAL');
type_insertone('Folate, total', 'REAL');
type_insertone('Folic acid', 'REAL');
type_insertone('Folate, food', 'REAL');
type_insertone('Folate, DFE', 'REAL');
type_insertone('Choline, total', 'REAL');
type_insertone('Betaine', 'REAL');
type_insertone('Vitamin B-12', 'REAL');
type_insertone('Vitamin B-12, added', 'REAL');
type_insertone('Vitamin A, RAE', 'REAL');
type_insertone('Retinol', 'REAL');
type_insertone('Carotene, beta', 'REAL');
type_insertone('Carotene, alpha', 'REAL');
type_insertone('Cryptoxanthin, beta', 'REAL');
type_insertone('Vitamin A, IU', 'REAL');
type_insertone('Lycopene', 'REAL');
type_insertone('Lutein + zeaxanthin', 'REAL');
type_insertone('Vitamin E (alpha-tocopherol)', 'REAL');
type_insertone('Vitamin E, added', 'REAL');
type_insertone('Tocopherol, beta', 'REAL');
type_insertone('Tocopherol, gamma', 'REAL');
type_insertone('Tocopherol, delta', 'REAL');
type_insertone('Vitamin D (D2 + D3)', 'REAL');
type_insertone('Vitamin D2 (ergocalciferol)', 'REAL');
type_insertone('Vitamin D3 (cholecalciferol)', 'REAL');
type_insertone('Vitamin D', 'REAL');
type_insertone('Vitamin K (phylloquinone)', 'REAL');
type_insertone('Fatty acids, total saturated', 'REAL');
type_insertone('Butanoic acid', 'REAL');
type_insertone('Hexanoic acid', 'REAL');
type_insertone('Octanoic acid', 'REAL');
type_insertone('Decanoic acid', 'REAL');
type_insertone('Dodecanoic acid', 'REAL');
type_insertone('Tetradecanoic acid', 'REAL');
type_insertone('Hexadecanoic acid', 'REAL');
type_insertone('Heptadecanoic acid', 'REAL');
type_insertone('Octadecanoic acid', 'REAL');
type_insertone('Eicosanoic acid', 'REAL');
type_insertone('Fatty acids, total monounsaturated', 'REAL');
type_insertone('Hexadecenoic acid', 'REAL');
type_insertone('Cis-hexadecenoic acid', 'REAL');
type_insertone('Octadecenoic acid', 'REAL');
type_insertone('Cis-octadecenoic acid', 'REAL');
type_insertone('Trans-octadecenoic acid', 'REAL');
type_insertone('Eicosenoic acid', 'REAL');
type_insertone('Docosenoic acid', 'REAL');
type_insertone('Fatty acids, total polyunsaturated', 'REAL');
type_insertone('Octadecadienoic acid', 'REAL');
type_insertone('Cis,cis-octadecadienoic n-6 acid', 'REAL');
type_insertone('Octadecadienoic CLAs acid', 'REAL');
type_insertone('Irans-Octadecadienoic acid', 'REAL');
type_insertone('Octadecatrienoic acid', 'REAL');
type_insertone('Cis,cis,cis-octadecatrienoic n-3 acid', 'REAL');
type_insertone('Octadecatetraenoic acid', 'REAL');
type_insertone('Eicosatetraenoic acid', 'REAL');
type_insertone('Eicosapentaenoic n-3 acid', 'REAL');
type_insertone('Docosapentaenoic n-3 acid', 'REAL');
type_insertone('Docosahexaenoic n-3 acid', 'REAL');
type_insertone('Fatty acids, total trans', 'REAL');
type_insertone('Fatty acids, total trans-monoenoic', 'REAL');
type_insertone('Fatty acids, total trans-polyenoic', 'REAL');
type_insertone('Cholesterol', 'REAL');
type_insertone('Stigmasterol', 'REAL');
type_insertone('Campesterol', 'REAL');
type_insertone('Beta-sitosterol', 'REAL');
type_insertone('Tryptophan', 'REAL');
type_insertone('Threonine', 'REAL');
type_insertone('Isoleucine', 'REAL');
type_insertone('Leucine', 'REAL');
type_insertone('Lysine', 'REAL');
type_insertone('Methionine', 'REAL');
type_insertone('Cystine', 'REAL');
type_insertone('Phenylalanine', 'REAL');
type_insertone('Tyrosine', 'REAL');
type_insertone('Valine', 'REAL');
type_insertone('Arginine', 'REAL');
type_insertone('Histidine', 'REAL');
type_insertone('Alanine', 'REAL');
type_insertone('Aspartic acid', 'REAL');
type_insertone('Glutamic acid', 'REAL');
type_insertone('Glycine', 'REAL');
type_insertone('Proline', 'REAL');
type_insertone('Serine', 'REAL');
type_insertone('Alcohol, ethyl', 'REAL');
type_insertone('Caffeine', 'REAL');
type_insertone('Theobromine', 'REAL');
