INSERT INTO "group" VALUES ($1, $2, $3)
ON CONFLICT ("field", "value") DO UPDATE SET "query"=$3
