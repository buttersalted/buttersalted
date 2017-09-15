BEGIN;
SELECT group_insertone($1, $2, $3, $4);
SELECT group_executeone($1);
COMMIT;
