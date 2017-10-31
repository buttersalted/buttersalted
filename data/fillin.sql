-- 1. create table to store fill-ins for fields
CREATE TABLE IF NOT EXISTS "fillin" (
  "id"    TEXT NOT NULL,
  "field" TEXT NOT NULL,
  PRIMARY KEY ("id"),
  CHECK ("id"<>''),
  FOREIGN KEY ("field") REFERENCES "field" ("id")
  ON DELETE NO ACTION ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS "fillin_field_idx"
ON "fillin" ("field");


CREATE OR REPLACE FUNCTION "fillin_field" (TEXT)
RETURNS TEXT AS $$
  SELECT coalesce(c."field", l."field") FROM "fillin" c, "fillin" l
  WHERE c."id"=$1 AND l."id"=lower($1);
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


CREATE OR REPLACE FUNCTION "term_insertoneifnotexists" (TEXT, TEXT)
RETURNS VOID AS $$
  SELECT term_insertone(jsonb_build_object('id', $1, 'value', $2))
  WHERE NOT EXISTS (SELECT "id" FROM "term" WHERE "id"=$1);
$$ LANGUAGE SQL;
