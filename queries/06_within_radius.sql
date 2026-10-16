-- title: Facilities within 1.5 km of a point
-- category: Buffers & proximity
-- functions: ST_DWithin, ::geography
-- expect_rows: 3
-- note: ST_DWithin uses the spatial index; ST_Distance(...) < 1500 does not. Always prefer ST_DWithin.
SELECT name, type,
       round(ST_Distance(geom::geography,
                         ST_SetSRID(ST_MakePoint(73.05, 33.71), 4326)::geography)::numeric) AS dist_m
FROM facilities
WHERE ST_DWithin(geom::geography,
                 ST_SetSRID(ST_MakePoint(73.05, 33.71), 4326)::geography,
                 1500)
ORDER BY dist_m;
