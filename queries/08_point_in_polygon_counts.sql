-- title: Count facilities per sector (point-in-polygon join)
-- category: Spatial joins
-- functions: ST_Contains, LEFT JOIN, GROUP BY
-- expect_rows: 20
-- note: LEFT JOIN keeps empty sectors (count = 0). ST_Contains ignores points exactly on a boundary; ST_Intersects would count them in both neighbours.
SELECT s.name,
       count(f.id) AS facilities
FROM sectors s
LEFT JOIN facilities f ON ST_Contains(s.geom, f.geom)
GROUP BY s.name
ORDER BY facilities DESC, s.name;
