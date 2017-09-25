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


CREATE OR REPLACE FUNCTION "query_wherelike" (JSON)
RETURNS TEXT AS $$
  -- 4. return where part
  SELECT ' WHERE '||g
  -- 3. aggregate all parts with and
  FROM (SELECT string_agg(f, ' AND ') AS g
  -- 2. create 'key LIKE value' parts
  FROM (SELECT format('%I::TEXT LIKE %L', "key", "value") AS f
  -- 1. get all keys and values
  FROM json_each_text($1) t) u) v;
$$ LANGUAGE SQL STRICT IMMUTABLE;


CREATE OR REPLACE FUNCTION "query_format" (JSON, TEXT, TEXT, TEXT)
RETURNS TEXT AS $$
  -- 5. return set part
  SELECT $2||g
  -- 4. aggregate all parts with comma
  FROM (SELECT string_agg(f, $4) AS g
  -- 3. create 'key = value' parts
  FROM (SELECT format($3, "key",
  -- 2. convert json double quotes to sql single
    replace("value"::TEXT, E'\"'::TEXT, E'\''::TEXT)) AS f
  -- 1. get all keys and values (as json)
  FROM json_each($1) t) u) v;
$$ LANGUAGE SQL STRICT IMMUTABLE;


CREATE OR REPLACE FUNCTION "query_set" (JSON)
RETURNS TEXT AS $$
  -- 5. return set part
  SELECT ' SET '||g
  -- 4. aggregate all parts with comma
  FROM (SELECT string_agg(f, ', ') AS g
  -- 3. create 'key = value' parts
  FROM (SELECT format('%I = %s', "key",
  -- 2. convert json double quotes to sql single
    replace("value"::TEXT, E'\"'::TEXT, E'\''::TEXT)) AS f
  -- 1. get all keys and values (as json)
  FROM json_each($1) t) u) v;
$$ LANGUAGE SQL STRICT IMMUTABLE;


CREATE OR REPLACE FUNCTION "query_selectlike" (TEXT, JSON)
RETURNS TEXT AS $$
  SELECT format('SELECT * FROM %I%s', $1, query_wherelike($2));
$$ LANGUAGE SQL STRICT IMMUTABLE;


CREATE OR REPLACE FUNCTION "query_deletelike" (TEXT, JSON)
RETURNS TEXT AS $$
  SELECT format('DELETE FROM %I%s', $1, query_wherelike($2));
$$ LANGUAGE SQL STRICT IMMUTABLE;


CREATE OR REPLACE FUNCTION "query_updatelike" (TEXT, JSON, JSON)
RETURNS TEXT AS $$
  SELECT format('UPDATE %I%s%s', $1, query_set($2), query_wherelike($3));
$$ LANGUAGE SQL STRICT IMMUTABLE;
