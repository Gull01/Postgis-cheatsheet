-- title: Facility counts by type per sector (pivot with FILTER)
-- category: Spatial joins
-- functions: ST_Contains, count(*) FILTER
-- expect_rows: 20
-- note: FILTER is a tidy alternative to SUM(CASE WHEN ...) for conditional counts.
SELECT s.name,
       count(f.id) FILTER (WHERE f.type = 'hospital') AS hospitals,
       count(f.id) FILTER (WHERE f.type = 'school')   AS schools,
       count(f.id) FILTER (WHERE f.type = 'park')     AS parks,
       count(f.id) FILTER (WHERE f.type = 'market')   AS markets,
       count(f.id) FILTER (WHERE f.type = 'pharmacy') AS pharmacies
FROM sectors s
LEFT JOIN facilities f ON ST_Contains(s.geom, f.geom)
GROUP BY s.name
ORDER BY s.name;
