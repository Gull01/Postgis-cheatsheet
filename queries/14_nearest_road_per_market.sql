-- title: Nearest road to every market, with distance
-- category: Nearest neighbour (KNN)
-- functions: CROSS JOIN LATERAL, <->, ST_Distance
-- expect_rows: 10
-- note: KNN works for points against lines and polygons too, not just point-to-point.
SELECT m.name AS market,
       r.name AS nearest_road,
       round(ST_Distance(m.geom::geography, r.geom::geography)::numeric) AS dist_m
FROM facilities m
CROSS JOIN LATERAL (
    SELECT name, geom
    FROM roads
    ORDER BY geom <-> m.geom
    LIMIT 1
) r
WHERE m.type = 'market'
ORDER BY dist_m;
