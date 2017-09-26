-- 1. create table to store alternate terms for "type"
CREATE TABLE IF NOT EXISTS "term" (
  "id"    TEXT NOT NULL,
  "value" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>'' AND "value"<>''),
  FOREIGN KEY ("value") REFERENCES "type" ("id")
  ON DELETE NO ACTION ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS "term_value_idx"
ON "term" ("value");


CREATE OR REPLACE FUNCTION "term_value" (TEXT)
RETURNS TEXT AS $$
  SELECT "value" FROM "term" WHERE "id"=$1;
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "term_insertone" (JSONB)
RETURNS VOID AS $$
  INSERT INTO "term" VALUES ($1->>'id', $1->>'value');
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "term_deleteone" (JSONB)
RETURNS VOID AS $$
  DELETE FROM "term" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "term_upsertone" (JSONB)
RETURNS VOID AS $$
  INSERT INTO "term" VALUES ($1->>'id', $1->>'value')
  ON CONFLICT ("id") DO UPDATE SET "value"=$1->>'value';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "term_selectone" (JSONB)
RETURNS SETOF "term" AS $$
  SELECT * FROM "term" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "term_insertone" (_id TEXT, _value TEXT)
RETURNS VOID AS $$
BEGIN
  PERFORM term_insertone(jsonb_build_object('id', _id, 'value', _value));
END;
$$ LANGUAGE plpgsql;


/* DEFAULT VALUES */
INSERT INTO "term" VALUES ('id', 'Id');
term_insertone('4:0', 'Butanoic acid');
term_insertone('6:0', 'Hexanoic acid');
term_insertone('8:0', 'Octanoic acid');
term_insertone('10:0', 'Decanoic acid');
term_insertone('12:0', 'Dodecanoic acid');
term_insertone('14:0', 'Tetradecanoic acid');
term_insertone('16:0', 'Hexadecanoic acid');
term_insertone('17:0', 'Heptadecanoic acid');
term_insertone('18:0', 'Octadecanoic acid');
term_insertone('20:0', 'Eicosanoic acid');
term_insertone('16:1 undifferentiated', 'Hexadecenoic acid');
term_insertone('16:1 c', 'Cis-hexadecenoic acid');
term_insertone('18:1 undifferentiated', 'Octadecenoic acid');
term_insertone('18:1 c', 'Cis-octadecenoic acid');
term_insertone('18:1 t', 'Trans-octadecenoic acid');
term_insertone('20:1', 'Eicosenoic acid');
term_insertone('22:1 undifferentiated', 'Docosenoic acid');
term_insertone('18:2 undifferentiated', 'Octadecadienoic acid');
term_insertone('18:2 n-6 c,c', 'Cis,cis-octadecadienoic n-6 acid');
term_insertone('18:2 CLAs', 'Octadecadienoic CLAs acid');
term_insertone('18:2 i', 'Irans-Octadecadienoic acid');
term_insertone('18:3 undifferentiated', 'Octadecatrienoic acid');
term_insertone('18:3 n-3 c,c,c (ALA)', 'Cis,cis,cis-octadecatrienoic n-3 acid');
term_insertone('18:4', 'Octadecatetraenoic acid');
term_insertone('20:4 undifferentiated', 'Eicosatetraenoic acid');
term_insertone('20:5 n-3 (EPA)', 'Eicosapentaenoic n-3 acid');
term_insertone('22:5 n-3 (DPA)', 'Docosapentaenoic n-3 acid');
term_insertone('22:6 n-3 (DHA)', 'Docosahexaenoic n-3 acid');
