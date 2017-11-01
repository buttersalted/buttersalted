-- I. UNIT
-- 1. temporary unit inserter
CREATE OR REPLACE FUNCTION x(TEXT, REAL, REAL)
RETURNS VOID AS $$
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
SELECT x('Name', 'TEXT NOT NULL');
SELECT x('Common Name', 'TEXT');
SELECT x('Scientific Name', 'TEXT');
SELECT x('Manufacturer', 'TEXT');
SELECT x('Food Group', 'TEXT');
SELECT x('Carbohydrate Factor', 'REAL');
SELECT x('Fat Factor', 'REAL');
SELECT x('Protein Factor', 'REAL');
SELECT x('Nitrogen to Protein Conversion Factor', 'REAL');
SELECT x('Water', 'REAL');
SELECT x('Energy', 'REAL');
SELECT x('Protein', 'REAL');
SELECT x('Adjusted Protein', 'REAL');
SELECT x('Total lipid (fat)', 'REAL');
SELECT x('Ash', 'REAL');
SELECT x('Carbohydrate, by difference', 'REAL');
SELECT x('Fiber, total dietary', 'REAL');
SELECT x('Starch', 'REAL');
SELECT x('Sugars, total', 'REAL');
SELECT x('Lactose', 'REAL');
SELECT x('Maltose', 'REAL');
SELECT x('Sucrose', 'REAL');
SELECT x('Fructose', 'REAL');
SELECT x('Galactose', 'REAL');
SELECT x('Glucose (dextrose)', 'REAL');
SELECT x('Calcium, Ca', 'REAL');
SELECT x('Iron, Fe', 'REAL');
SELECT x('Magnesium, Mg', 'REAL');
SELECT x('Phosphorus, P', 'REAL');
SELECT x('Potassium, K', 'REAL');
SELECT x('Sodium, Na', 'REAL');
SELECT x('Zinc, Zn', 'REAL');
SELECT x('Copper, Cu', 'REAL');
SELECT x('Manganese, Mn', 'REAL');
SELECT x('Selenium, Se', 'REAL');
SELECT x('Fluoride, F', 'REAL');
SELECT x('Vitamin C, total ascorbic acid', 'REAL');
SELECT x('Thiamin', 'REAL');
SELECT x('Riboflavin', 'REAL');
SELECT x('Niacin', 'REAL');
SELECT x('Pantothenic acid', 'REAL');
SELECT x('Vitamin B-6', 'REAL');
SELECT x('Folate, total', 'REAL');
SELECT x('Folic acid', 'REAL');
SELECT x('Folate, food', 'REAL');
SELECT x('Folate, DFE', 'REAL');
SELECT x('Choline, total', 'REAL');
SELECT x('Betaine', 'REAL');
SELECT x('Vitamin B-12', 'REAL');
SELECT x('Vitamin B-12, added', 'REAL');
SELECT x('Vitamin A, RAE', 'REAL');
SELECT x('Retinol', 'REAL');
SELECT x('Carotene, beta', 'REAL');
SELECT x('Carotene, alpha', 'REAL');
SELECT x('Cryptoxanthin, beta', 'REAL');
SELECT x('Vitamin A, IU', 'REAL');
SELECT x('Lycopene', 'REAL');
SELECT x('Lutein + zeaxanthin', 'REAL');
SELECT x('Vitamin E (alpha-tocopherol)', 'REAL');
SELECT x('Vitamin E, added', 'REAL');
SELECT x('Tocopherol, beta', 'REAL');
SELECT x('Tocopherol, gamma', 'REAL');
SELECT x('Tocopherol, delta', 'REAL');
SELECT x('Vitamin D (D2 + D3)', 'REAL');
SELECT x('Vitamin D2 (ergocalciferol)', 'REAL');
SELECT x('Vitamin D3 (cholecalciferol)', 'REAL');
SELECT x('Vitamin D', 'REAL');
SELECT x('Vitamin K (phylloquinone)', 'REAL');
SELECT x('Fatty acids, total saturated', 'REAL');
SELECT x('Butanoic acid', 'REAL');
SELECT x('Hexanoic acid', 'REAL');
SELECT x('Octanoic acid', 'REAL');
SELECT x('Decanoic acid', 'REAL');
SELECT x('Dodecanoic acid', 'REAL');
SELECT x('Tridecanoic acid', 'REAL');
SELECT x('Tetradecanoic acid', 'REAL');
SELECT x('Pentadecanoic acid', 'REAL');
SELECT x('Hexadecanoic acid', 'REAL');
SELECT x('Heptadecanoic acid', 'REAL');
SELECT x('Octadecanoic acid', 'REAL');
SELECT x('Eicosanoic acid', 'REAL');
SELECT x('Docosanoic acid', 'REAL');
SELECT x('Tetracosanoic acid', 'REAL');
SELECT x('Fatty acids, total monounsaturated', 'REAL');
SELECT x('Tetradecenoic acid', 'REAL');
SELECT x('Pentadecenoic acid', 'REAL');
SELECT x('Hexadecenoic acid', 'REAL');
SELECT x('Cis-hexadecenoic acid', 'REAL');
SELECT x('Trans-hexadecenoic acid', 'REAL');
SELECT x('Heptadecenoic acid', 'REAL');
SELECT x('Octadecenoic acid', 'REAL');
SELECT x('Cis-octadecenoic acid', 'REAL');
SELECT x('Trans-octadecenoic acid', 'REAL');
SELECT x('Eicosenoic acid', 'REAL');
SELECT x('Docosenoic acid', 'REAL');
SELECT x('Cis-docosenoic acid', 'REAL');
SELECT x('Trans-docosenoic acid', 'REAL');
SELECT x('Cis-tetracosenoic acid', 'REAL');
SELECT x('Fatty acids, total polyunsaturated', 'REAL');
SELECT x('Octadecadienoic acid', 'REAL');
SELECT x('Cis,cis-octadecadienoic n-6 acid', 'REAL');
SELECT x('Octadecadienoic CLAs acid', 'REAL');
SELECT x('Irans-Octadecadienoic acid', 'REAL');
SELECT x('Trans-octadecadienoic acid', 'REAL');
SELECT x('Trans,trans-octadecadienoic acid', 'REAL');
SELECT x('Cis,cis-eicosadienoic n-6 acid', 'REAL');
SELECT x('Octadecatrienoic acid', 'REAL');
SELECT x('Cis,cis,cis-octadecatrienoic n-3 acid', 'REAL');
SELECT x('Cis,cis,cis-octadecatrienoic n-6 acid', 'REAL');
SELECT x('Trans-octadecatrienoic acid', 'REAL');
SELECT x('Eicosatrienoic acid', 'REAL');
SELECT x('Eicosatrienoic n-6 acid', 'REAL');
SELECT x('Octadecatetraenoic acid', 'REAL');
SELECT x('Eicosatetraenoic acid', 'REAL');
SELECT x('Eicosatetraenoic n-6 acid', 'REAL');
SELECT x('Docosatetraenoic acid', 'REAL');
SELECT x('Eicosapentaenoic n-3 acid', 'REAL');
SELECT x('Uncosapentaenoic acid', 'REAL');
SELECT x('Docosapentaenoic n-3 acid', 'REAL');
SELECT x('Docosahexaenoic n-3 acid', 'REAL');
SELECT x('Fatty acids, total trans', 'REAL');
SELECT x('Fatty acids, total trans-monoenoic', 'REAL');
SELECT x('Fatty acids, total trans-polyenoic', 'REAL');
SELECT x('Tryptophan', 'REAL');
SELECT x('Threonine', 'REAL');
SELECT x('Isoleucine', 'REAL');
SELECT x('Leucine', 'REAL');
SELECT x('Lysine', 'REAL');
SELECT x('Methionine', 'REAL');
SELECT x('Cystine', 'REAL');
SELECT x('Phenylalanine', 'REAL');
SELECT x('Tyrosine', 'REAL');
SELECT x('Valine', 'REAL');
SELECT x('Arginine', 'REAL');
SELECT x('Histidine', 'REAL');
SELECT x('Alanine', 'REAL');
SELECT x('Aspartic acid', 'REAL');
SELECT x('Glutamic acid', 'REAL');
SELECT x('Glycine', 'REAL');
SELECT x('Proline', 'REAL');
SELECT x('Serine', 'REAL');
SELECT x('Total isoflavones', 'REAL');
SELECT x('Hydroxyproline', 'REAL');
SELECT x('Genistein', 'REAL');
SELECT x('Daidzein', 'REAL');
SELECT x('Glycitein', 'REAL');
SELECT x('Formononetin', 'REAL');
SELECT x('Apigenin', 'REAL');
SELECT x('Naringenin', 'REAL');
SELECT x('Luteolin', 'REAL');
SELECT x('Isorhamnetin', 'REAL');
SELECT x('Hesperetin', 'REAL');
SELECT x('Myricetin', 'REAL');
SELECT x('Quercetin', 'REAL');
SELECT x('Phytosterols', 'REAL');
SELECT x('Coumestrol', 'REAL');
SELECT x('Cholesterol', 'REAL');
SELECT x('Stigmasterol', 'REAL');
SELECT x('Campesterol', 'REAL');
SELECT x('Beta-sitosterol', 'REAL');
SELECT x('Kaempferol', 'REAL');
SELECT x('Eriodictyol', 'REAL');
SELECT x('Biochanin A', 'REAL');
SELECT x('Cyanidin', 'REAL');
SELECT x('Malvidin', 'REAL');
SELECT x('Peonidin', 'REAL');
SELECT x('Petunidin', 'REAL');
SELECT x('Delphinidin', 'REAL');
SELECT x('Pelargonidin', 'REAL');
SELECT x('Proanthocyanidin dimers', 'REAL');
SELECT x('Proanthocyanidin trimers', 'REAL');
SELECT x('Proanthocyanidin 4-6mers', 'REAL');
SELECT x('Proanthocyanidin 7-10mers', 'REAL');
SELECT x('Proanthocyanidin polymers (>10mers)', 'REAL');
SELECT x('(+)-Catechin', 'REAL');
SELECT x('(-)-Epicatechin', 'REAL');
SELECT x('(+)-Gallocatechin', 'REAL');
SELECT x('(-)-Epigallocatechin', 'REAL');
SELECT x('(-)-Epicatechin 3-gallate', 'REAL');
SELECT x('(-)-Epigallocatechin 3-gallate', 'REAL');
SELECT x('Alcohol, ethyl', 'REAL');
SELECT x('Caffeine', 'REAL');
SELECT x('Theobromine', 'REAL');
SELECT x('Refuse', 'REAL');
SELECT x('Refuse Description', 'REAL');


-- III. FILLIN
-- 1. temporary fillin inserter
CREATE OR REPLACE FUNCTION "x" (TEXT, TEXT)
RETURNS VOID AS $$
  SELECT fillin_insertone(jsonb_build_object('id', $1, 'field', $2))
  WHERE NOT EXISTS (SELECT "id" FROM "fillin" WHERE "id"=$1);
$$ LANGUAGE SQL;
-- 2. id exists by default, so just add it
INSERT INTO "term" VALUES ('id', 'Id')
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
