-- I. UNIT
-- 1. temporary unit inserter
CREATE OR REPLACE FUNCTION x(TEXT, REAL, REAL)
RETURNS VOID AS $$
  INSERT INTO "unit" VALUES ($1, $2, $3) ON CONFLICT ("id") DO NOTHING;
$$ LANGUAGE SQL;
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
SELECT x('Cal', 4.184e+3, 0);
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


-- II. FIELD
-- 1. temporary field inserter
CREATE OR REPLACE FUNCTION "x" (TEXT, TEXT, TEXT)
RETURNS VOID AS $$
  SELECT field_insertone(jsonb_build_object('id', $1, 'type', $2, 'unit', $3))
  WHERE NOT EXISTS (SELECT "id" FROM "field" WHERE "id"=$1);
$$ LANGUAGE SQL;
-- 2. Id exists by default, so just add it
INSERT INTO "field" VALUES ('Id', 'INT NOT NULL')
ON CONFLICT ("id") DO NOTHING;
-- 3. insert fields
SELECT x('Name', 'TEXT NOT NULL', NULL);
SELECT x('Common Name', 'TEXT', NULL);
SELECT x('Scientific Name', 'TEXT', NULL);
SELECT x('Manufacturer', 'TEXT', NULL);
SELECT x('Food Group', 'TEXT', NULL);
SELECT x('Carbohydrate Factor', 'REAL', NULL);
SELECT x('Fat Factor', 'REAL', NULL);
SELECT x('Protein Factor', 'REAL', NULL);
SELECT x('Nitrogen to Protein Conversion Factor', 'REAL', NULL);
SELECT x('Water', 'REAL', 'g');
SELECT x('Energy', 'REAL', 'Cal');
SELECT x('Protein', 'REAL', 'g');
SELECT x('Adjusted Protein', 'REAL', 'g');
SELECT x('Total lipid (fat)', 'REAL', 'g');
SELECT x('Ash', 'REAL', 'g');
SELECT x('Carbohydrate, by difference', 'REAL', 'g');
SELECT x('Fiber, total dietary', 'REAL', 'g');
SELECT x('Starch', 'REAL', 'g');
SELECT x('Sugars, total', 'REAL', 'g');
SELECT x('Lactose', 'REAL', 'g');
SELECT x('Maltose', 'REAL', 'g');
SELECT x('Sucrose', 'REAL', 'g');
SELECT x('Fructose', 'REAL', 'g');
SELECT x('Galactose', 'REAL', 'g');
SELECT x('Glucose (dextrose)', 'REAL', 'g');
SELECT x('Calcium, Ca', 'REAL', 'g');
SELECT x('Iron, Fe', 'REAL', 'g');
SELECT x('Magnesium, Mg', 'REAL', 'g');
SELECT x('Phosphorus, P', 'REAL', 'g');
SELECT x('Potassium, K', 'REAL', 'g');
SELECT x('Sodium, Na', 'REAL', 'g');
SELECT x('Zinc, Zn', 'REAL', 'g');
SELECT x('Copper, Cu', 'REAL', 'g');
SELECT x('Manganese, Mn', 'REAL', 'g');
SELECT x('Selenium, Se', 'REAL', 'g');
SELECT x('Fluoride, F', 'REAL', 'g');
SELECT x('Vitamin C, total ascorbic acid', 'REAL', 'g');
SELECT x('Thiamin', 'REAL', 'g');
SELECT x('Riboflavin', 'REAL', 'g');
SELECT x('Niacin', 'REAL', 'g');
SELECT x('Pantothenic acid', 'REAL', 'g');
SELECT x('Vitamin B-6', 'REAL', 'g');
SELECT x('Folate, total', 'REAL', 'g');
SELECT x('Folic acid', 'REAL', 'g');
SELECT x('Folate, food', 'REAL', 'g');
SELECT x('Folate, DFE', 'REAL', 'g');
SELECT x('Choline, total', 'REAL', 'g');
SELECT x('Betaine', 'REAL', 'g');
SELECT x('Vitamin B-12', 'REAL', 'g');
SELECT x('Vitamin B-12, added', 'REAL', 'g');
SELECT x('Vitamin A, RAE', 'REAL', 'g');
SELECT x('Retinol', 'REAL', 'g');
SELECT x('Carotene, beta', 'REAL', 'g');
SELECT x('Carotene, alpha', 'REAL', 'g');
SELECT x('Cryptoxanthin, beta', 'REAL', 'g');
SELECT x('Vitamin A, IU', 'REAL', 'g');
SELECT x('Lycopene', 'REAL', 'g');
SELECT x('Lutein + zeaxanthin', 'REAL', 'g');
SELECT x('Vitamin E (alpha-tocopherol)', 'REAL', 'g');
SELECT x('Vitamin E, added', 'REAL', 'g');
SELECT x('Tocopherol, beta', 'REAL', 'g');
SELECT x('Tocopherol, gamma', 'REAL', 'g');
SELECT x('Tocopherol, delta', 'REAL', 'g');
SELECT x('Vitamin D (D2 + D3)', 'REAL', 'g');
SELECT x('Vitamin D2 (ergocalciferol)', 'REAL', 'g');
SELECT x('Vitamin D3 (cholecalciferol)', 'REAL', 'g');
SELECT x('Vitamin D', 'REAL', 'g');
SELECT x('Vitamin K (phylloquinone)', 'REAL', 'g');
SELECT x('Fatty acids, total saturated', 'REAL', 'g');
SELECT x('Butanoic acid', 'REAL', 'g');
SELECT x('Hexanoic acid', 'REAL', 'g');
SELECT x('Octanoic acid', 'REAL', 'g');
SELECT x('Decanoic acid', 'REAL', 'g');
SELECT x('Dodecanoic acid', 'REAL', 'g');
SELECT x('Tridecanoic acid', 'REAL', 'g');
SELECT x('Tetradecanoic acid', 'REAL', 'g');
SELECT x('Pentadecanoic acid', 'REAL', 'g');
SELECT x('Hexadecanoic acid', 'REAL', 'g');
SELECT x('Heptadecanoic acid', 'REAL', 'g');
SELECT x('Octadecanoic acid', 'REAL', 'g');
SELECT x('Eicosanoic acid', 'REAL', 'g');
SELECT x('Docosanoic acid', 'REAL', 'g');
SELECT x('Tetracosanoic acid', 'REAL', 'g');
SELECT x('Fatty acids, total monounsaturated', 'REAL', 'g');
SELECT x('Tetradecenoic acid', 'REAL', 'g');
SELECT x('Pentadecenoic acid', 'REAL', 'g');
SELECT x('Hexadecenoic acid', 'REAL', 'g');
SELECT x('Cis-hexadecenoic acid', 'REAL', 'g');
SELECT x('Trans-hexadecenoic acid', 'REAL', 'g');
SELECT x('Heptadecenoic acid', 'REAL', 'g');
SELECT x('Octadecenoic acid', 'REAL', 'g');
SELECT x('Cis-octadecenoic acid', 'REAL', 'g');
SELECT x('Trans-octadecenoic acid', 'REAL', 'g');
SELECT x('Eicosenoic acid', 'REAL', 'g');
SELECT x('Docosenoic acid', 'REAL', 'g');
SELECT x('Cis-docosenoic acid', 'REAL', 'g');
SELECT x('Trans-docosenoic acid', 'REAL', 'g');
SELECT x('Cis-tetracosenoic acid', 'REAL', 'g');
SELECT x('Fatty acids, total polyunsaturated', 'REAL', 'g');
SELECT x('Octadecadienoic acid', 'REAL', 'g');
SELECT x('Cis,cis-octadecadienoic n-6 acid', 'REAL', 'g');
SELECT x('Octadecadienoic CLAs acid', 'REAL', 'g');
SELECT x('Irans-Octadecadienoic acid', 'REAL', 'g');
SELECT x('Trans-octadecadienoic acid', 'REAL', 'g');
SELECT x('Trans,trans-octadecadienoic acid', 'REAL', 'g');
SELECT x('Cis,cis-eicosadienoic n-6 acid', 'REAL', 'g');
SELECT x('Octadecatrienoic acid', 'REAL', 'g');
SELECT x('Cis,cis,cis-octadecatrienoic n-3 acid', 'REAL', 'g');
SELECT x('Cis,cis,cis-octadecatrienoic n-6 acid', 'REAL', 'g');
SELECT x('Trans-octadecatrienoic acid', 'REAL', 'g');
SELECT x('Eicosatrienoic acid', 'REAL', 'g');
SELECT x('Eicosatrienoic n-6 acid', 'REAL', 'g');
SELECT x('Octadecatetraenoic acid', 'REAL', 'g');
SELECT x('Eicosatetraenoic acid', 'REAL', 'g');
SELECT x('Eicosatetraenoic n-6 acid', 'REAL', 'g');
SELECT x('Docosatetraenoic acid', 'REAL', 'g');
SELECT x('Eicosapentaenoic n-3 acid', 'REAL', 'g');
SELECT x('Uncosapentaenoic acid', 'REAL', 'g');
SELECT x('Docosapentaenoic n-3 acid', 'REAL', 'g');
SELECT x('Docosahexaenoic n-3 acid', 'REAL', 'g');
SELECT x('Fatty acids, total trans', 'REAL', 'g');
SELECT x('Fatty acids, total trans-monoenoic', 'REAL', 'g');
SELECT x('Fatty acids, total trans-polyenoic', 'REAL', 'g');
SELECT x('Tryptophan', 'REAL', 'g');
SELECT x('Threonine', 'REAL', 'g');
SELECT x('Isoleucine', 'REAL', 'g');
SELECT x('Leucine', 'REAL', 'g');
SELECT x('Lysine', 'REAL', 'g');
SELECT x('Methionine', 'REAL', 'g');
SELECT x('Cystine', 'REAL', 'g');
SELECT x('Phenylalanine', 'REAL', 'g');
SELECT x('Tyrosine', 'REAL', 'g');
SELECT x('Valine', 'REAL', 'g');
SELECT x('Arginine', 'REAL', 'g');
SELECT x('Histidine', 'REAL', 'g');
SELECT x('Alanine', 'REAL', 'g');
SELECT x('Aspartic acid', 'REAL', 'g');
SELECT x('Glutamic acid', 'REAL', 'g');
SELECT x('Glycine', 'REAL', 'g');
SELECT x('Proline', 'REAL', 'g');
SELECT x('Serine', 'REAL', 'g');
SELECT x('Total isoflavones', 'REAL', 'g');
SELECT x('Hydroxyproline', 'REAL', 'g');
SELECT x('Genistein', 'REAL', 'g');
SELECT x('Daidzein', 'REAL', 'g');
SELECT x('Glycitein', 'REAL', 'g');
SELECT x('Formononetin', 'REAL', 'g');
SELECT x('Apigenin', 'REAL', 'g');
SELECT x('Naringenin', 'REAL', 'g');
SELECT x('Luteolin', 'REAL', 'g');
SELECT x('Isorhamnetin', 'REAL', 'g');
SELECT x('Hesperetin', 'REAL', 'g');
SELECT x('Myricetin', 'REAL', 'g');
SELECT x('Quercetin', 'REAL', 'g');
SELECT x('Phytosterols', 'REAL', 'g');
SELECT x('Coumestrol', 'REAL', 'g');
SELECT x('Cholesterol', 'REAL', 'g');
SELECT x('Stigmasterol', 'REAL', 'g');
SELECT x('Campesterol', 'REAL', 'g');
SELECT x('Beta-sitosterol', 'REAL', 'g');
SELECT x('Kaempferol', 'REAL', 'g');
SELECT x('Eriodictyol', 'REAL', 'g');
SELECT x('Biochanin A', 'REAL', 'g');
SELECT x('Cyanidin', 'REAL', 'g');
SELECT x('Malvidin', 'REAL', 'g');
SELECT x('Peonidin', 'REAL', 'g');
SELECT x('Petunidin', 'REAL', 'g');
SELECT x('Delphinidin', 'REAL', 'g');
SELECT x('Pelargonidin', 'REAL', 'g');
SELECT x('Proanthocyanidin dimers', 'REAL', 'g');
SELECT x('Proanthocyanidin trimers', 'REAL', 'g');
SELECT x('Proanthocyanidin 4-6mers', 'REAL', 'g');
SELECT x('Proanthocyanidin 7-10mers', 'REAL', 'g');
SELECT x('Proanthocyanidin polymers (>10mers)', 'REAL', 'g');
SELECT x('(+)-Catechin', 'REAL', 'g');
SELECT x('(-)-Epicatechin', 'REAL', 'g');
SELECT x('(+)-Gallocatechin', 'REAL', 'g');
SELECT x('(-)-Epigallocatechin', 'REAL', 'g');
SELECT x('(-)-Epicatechin 3-gallate', 'REAL', 'g');
SELECT x('(-)-Epigallocatechin 3-gallate', 'REAL', 'g');
SELECT x('Alcohol, ethyl', 'REAL', 'g');
SELECT x('Caffeine', 'REAL', 'g');
SELECT x('Theobromine', 'REAL', 'g');
SELECT x('Refuse Description', 'TEXT', NULL);
SELECT x('Refuse', 'REAL', 'g');


-- III. FILLIN
-- 1. temporary fillin inserter
CREATE OR REPLACE FUNCTION "x" (TEXT, TEXT)
RETURNS VOID AS $$
  SELECT fillin_insertone(jsonb_build_object('id', $1, 'field', $2))
  WHERE NOT EXISTS (SELECT "id" FROM "fillin" WHERE "id"=$1);
$$ LANGUAGE SQL;
-- 2. id exists by default, so just add it
INSERT INTO "fillin" VALUES ('id', 'Id')
ON CONFLICT ("id") DO NOTHING;
-- 3. insert fillins
SELECT x('4:0', 'Butanoic acid');
SELECT x('6:0', 'Hexanoic acid');
SELECT x('8:0', 'Octanoic acid');
SELECT x('10:0', 'Decanoic acid');
SELECT x('12:0', 'Dodecanoic acid');
SELECT x('13:0', 'Tridecanoic acid');
SELECT x('14:0', 'Tetradecanoic acid');
SELECT x('15:0', 'Pentadecanoic acid');
SELECT x('16:0', 'Hexadecanoic acid');
SELECT x('17:0', 'Heptadecanoic acid');
SELECT x('18:0', 'Octadecanoic acid');
SELECT x('20:0', 'Eicosanoic acid');
SELECT x('22:0', 'Docosanoic acid');
SELECT x('24:0', 'Tetracosanoic acid');
SELECT x('14:1', 'Tetradecenoic acid');
SELECT x('15:1', 'Pentadecenoic acid');
SELECT x('16:1 undifferentiated', 'Hexadecenoic acid');
SELECT x('16:1 c', 'Cis-hexadecenoic acid');
SELECT x('16:1 t', 'Trans-hexadecenoic acid');
SELECT x('17:1', 'Heptadecenoic acid');
SELECT x('18:1 undifferentiated', 'Octadecenoic acid');
SELECT x('18:1 c', 'Cis-octadecenoic acid');
SELECT x('18:1 t', 'Trans-octadecenoic acid');
SELECT x('20:1', 'Eicosenoic acid');
SELECT x('22:1 undifferentiated', 'Docosenoic acid');
SELECT x('22:1 c', 'Cis-docosenoic acid');
SELECT x('22:1 t', 'Trans-docosenoic acid');
SELECT x('24:1 c', 'Cis-tetracosenoic acid');
SELECT x('18:2 undifferentiated', 'Octadecadienoic acid');
SELECT x('18:2 n-6 c,c', 'Cis,cis-octadecadienoic n-6 acid');
SELECT x('18:2 clas', 'Octadecadienoic CLAs acid');
SELECT x('18:2 i', 'Irans-Octadecadienoic acid');
SELECT x('18:2 t not further defined', 'Trans-octadecadienoic acid');
SELECT x('18:2 t,t', 'Trans,trans-octadecadienoic acid');
SELECT x('20:2 n-6 c,c', 'Cis,cis-eicosadienoic n-6 acid');
SELECT x('18:3 undifferentiated', 'Octadecatrienoic acid');
SELECT x('18:3 n-3 c,c,c (ala)', 'Cis,cis,cis-octadecatrienoic n-3 acid');
SELECT x('18:3 n-6 c,c,c', 'Cis,cis,cis-octadecatrienoic n-6 acid');
SELECT x('18:3i', 'Trans-octadecatrienoic acid');
SELECT x('20:3 undifferentiated', 'Eicosatrienoic acid');
SELECT x('20:3 n-6', 'Eicosatrienoic n-6 acid');
SELECT x('18:4', 'Octadecatetraenoic acid');
SELECT x('20:4 undifferentiated', 'Eicosatetraenoic acid');
SELECT x('20:4 n-6', 'Eicosatetraenoic n-6 acid');
SELECT x('22:4', 'Docosatetraenoic acid');
SELECT x('20:5 n-3 (epa)', 'Eicosapentaenoic n-3 acid');
SELECT x('21:5', 'Uncosapentaenoic acid');
SELECT x('22:5 n-3 (dpa)', 'Docosapentaenoic n-3 acid');
SELECT x('22:6 n-3 (dha)', 'Docosahexaenoic n-3 acid');
