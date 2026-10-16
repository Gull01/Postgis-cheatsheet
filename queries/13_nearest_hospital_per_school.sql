-- title: Nearest hospital for every school (KNN with LATERAL)
-- category: Nearest neighbour (KNN)
-- functions: CROSS JOIN LATERAL, <->, ST_Distance
-- expect_rows: 20
-- note: LATERAL runs the inner KNN query once per outer row, each using the spatial index.
SELECT s.name AS school,
       h.name AS nearest_hospital,
       round(ST_Distance(s.geom::geography, h.geom::geography)::numeric) AS dist_m
FROM facilities s
CROSS JOIN LATERAL (
    SELECT name, geom
    FROM facilities
    WHERE type = 'hospital'
    ORDER BY geom <-> s.geom
    LIMIT 1
) h
WHERE s.type = 'school'
ORDER BY dist_m DESC;
