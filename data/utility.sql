CREATE OR REPLACE FUNCTION "array_sort" (ANYARRAY)
RETURNS ANYARRAY AS $$
  -- 1. stealthily taken from postgresql mailing list
  SELECT array(SELECT $1[i] FROM
  generate_series(array_lower($1,1), array_upper($1,1)) g(i)
  ORDER BY 1);
$$ LANGUAGE SQL STRICT IMMUTABLE;


CREATE OR REPLACE FUNCTION "json_keys" (JSON)
RETURNS TEXT[] AS $$
  -- 1. stealthily take from stackoverflow (Marth)
  SELECT array_agg(f) FROM
  (SELECT json_object_keys($1) AS f) u;
$$ LANGUAGE SQL STRICT IMMUTABLE;


CREATE OR REPLACE FUNCTION "query_format" (JSON, TEXT, TEXT, TEXT)
RETURNS TEXT AS $$
  -- 5. return completed string
  SELECT $2||g
  -- 4. aggregate all parts with separator
  FROM (SELECT string_agg(f, $4) AS g
  -- 3. create parts with given format
  FROM (SELECT format($3, "key",
  -- 2. convert json double quotes to sql single
    replace("value"::TEXT, E'\"'::TEXT, E'\''::TEXT)) AS f
  -- 1. get all keys and values (as json)
  FROM json_each($1) t) u) v;
$$ LANGUAGE SQL STRICT IMMUTABLE;


CREATE OR REPLACE FUNCTION "query_selectlike" (TEXT, JSON)
RETURNS TEXT AS $$
  SELECT format('SELECT * FROM %I%s', $1,
    query_format($2, ' WHERE ', '%I LIKE %s', ' AND '));
$$ LANGUAGE SQL STRICT IMMUTABLE;


CREATE OR REPLACE FUNCTION "query_deletelike" (TEXT, JSON)
RETURNS TEXT AS $$
  SELECT format('DELETE FROM %I%s', $1,
    query_format($2, ' WHERE ', '%I LIKE %s', ' AND '));
$$ LANGUAGE SQL STRICT IMMUTABLE;


CREATE OR REPLACE FUNCTION "query_updatelike" (TEXT, JSON, JSON)
RETURNS TEXT AS $$
  SELECT format('UPDATE %I%s%s', $1,
    query_format($2, ' SET ', '%I = %s', ', '),
    query_format($3, ' WHERE ', '%I LIKE %s', ' AND '));
$$ LANGUAGE SQL STRICT IMMUTABLE;


CREATE OR REPLACE FUNCTION "table_default" (TEXT)
RETURNS JSON AS $$
  SELECT json_object_agg(column_name, replace(split_part(column_default,'::',1), E'\'', ''))
  FROM information_schema.columns
  WHERE (table_schema, table_name) = ('public', $1);
$$ LANGUAGE SQL STRICT IMMUTABLE;
