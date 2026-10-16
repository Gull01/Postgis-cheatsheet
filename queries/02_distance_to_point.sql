-- title: Distance from a point to every hospital (metres)
-- category: Measurement & validity
-- functions: ST_Distance, ST_MakePoint, ::geography
-- expect_rows: 8
-- note: geography distances are geodesic metres. Fine for reporting; use ST_DWithin for filtering.
SELECT name,
       round(ST_Distance(geom::geography,
                         ST_SetSRID(ST_MakePoint(73.05, 33.71), 4326)::geography)::numeric) AS dist_m
FROM facilities
WHERE type = 'hospital'
ORDER BY dist_m;
