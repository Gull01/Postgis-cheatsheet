-- title: Sectors with no hospital within 1 km (service gaps)
-- category: Buffers & proximity
-- functions: NOT EXISTS, ST_DWithin
-- expect_rows: 7
-- note: Anti-join pattern. Distance is measured to the sector boundary, so a hospital inside the sector counts as 0 m.
SELECT s.name
FROM sectors s
WHERE NOT EXISTS (
    SELECT 1
    FROM facilities f
    WHERE f.type = 'hospital'
      AND ST_DWithin(s.geom::geography, f.geom::geography, 1000)
)
ORDER BY s.name;
