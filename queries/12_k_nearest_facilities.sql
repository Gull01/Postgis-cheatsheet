-- title: 5 nearest facilities to a point (KNN)
-- category: Nearest neighbour (KNN)
-- functions: <->, ST_Distance, LIMIT
-- expect_rows: 5
-- note: ORDER BY geom <-> point LIMIT k is index-assisted. On 4326 the operator ranks by degrees, which is fine at city scale; for wide areas over-fetch, then re-rank by geography distance.
SELECT name, type,
       round(ST_Distance(geom::geography, 'SRID=4326;POINT(73.05 33.71)'::geography)::numeric) AS dist_m
FROM facilities
ORDER BY geom <-> 'SRID=4326;POINT(73.05 33.71)'::geometry
LIMIT 5;
