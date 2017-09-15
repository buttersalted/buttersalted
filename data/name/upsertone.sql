INSERT INTO "name" VALUES ($1, $2)
ON CONFLICT ("id") DO UPDATE SET "value"=$2;
