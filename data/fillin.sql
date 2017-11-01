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
$$ LANGUAGE SQL STABLE;


CREATE OR REPLACE FUNCTION "fillin_selectone" (JSONB)
RETURNS SETOF "fillin" AS $$
  SELECT * FROM "fillin" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "fillin_insertone" (JSONB)
RETURNS VOID AS $$
  INSERT INTO "fillin" VALUES ($1->>'id', $1->>'field');
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "fillin_deleteone" (JSONB)
RETURNS VOID AS $$
  DELETE FROM "fillin" WHERE "id"=$1->>'id';
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION "fillin_updateone" (JSONB, JSONB)
RETURNS VOID AS $$
  UPDATE "fillin" u SET "id"=coalesce($2->>'id', r."id"),
  "field"=coalesce(($2->>'field'), r."field")
  FROM (SELECT * FROM "fillin" WHERE "id"=$1->>'id') r
  WHERE u."id"=$1->>'id';
$$ LANGUAGE SQL;
