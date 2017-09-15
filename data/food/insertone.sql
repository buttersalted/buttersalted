INSERT INTO "food"
SELECT * FROM json_populate_record(NULL::"food", $1)
