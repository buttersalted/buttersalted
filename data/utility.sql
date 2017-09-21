CREATE OR REPLACE FUNCTION "array_sort" (ANYARRAY)
RETURNS ANYARRAY AS $$
  -- 1. stealthily taken from postgresql mailing list
  SELECT array(SELECT $1[i] FROM
  generate_series(array_lower($1,1), array_upper($1,1)) g(i)
  ORDER BY 1)
$$ LANGUAGE SQL STRICT IMMUTABLE;


CREATE OR REPLACE FUNCTION "json_keys" (JSON)
RETURNS TEXT[] AS $$
  -- 1. stealthily take from stackoverflow (Marth)
  SELECT array_agg(f) FROM
  (SELECT json_object_keys($1) AS f) u
$$ LANGUAGE SQL STRICT IMMUTABLE;
