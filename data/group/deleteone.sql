BEGIN;
SELECT group_unexecuteone($1);
SELECT group_deleteone($1);
COMMIT;
