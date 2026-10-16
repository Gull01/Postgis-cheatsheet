-- title: Detect and repair an invalid geometry
-- category: Measurement & validity
-- functions: ST_IsValid, ST_IsValidReason, ST_MakeValid
-- expect_rows: 1
-- note: A "bowtie" polygon self-intersects. To audit a real table use:
--       SELECT id, ST_IsValidReason(geom) FROM my_table WHERE NOT ST_IsValid(geom);
SELECT ST_IsValid(g)                      AS is_valid,
       ST_IsValidReason(g)                AS reason,
       ST_AsText(ST_MakeValid(g))         AS repaired_wkt,
       GeometryType(ST_MakeValid(g))      AS repaired_type
FROM (SELECT 'POLYGON((0 0, 2 2, 2 0, 0 2, 0 0))'::geometry AS g) t;
