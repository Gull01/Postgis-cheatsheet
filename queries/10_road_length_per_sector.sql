-- title: Road length inside each sector (line-polygon overlay)
-- category: Spatial joins
-- functions: ST_Intersection, ST_CollectionExtract, ST_Length
-- expect_rows: 48
-- note: ST_CollectionExtract(..., 2) keeps only the line parts, so stray touch points cannot break ST_Length.
SELECT r.name AS road,
       s.name AS sector,
       round((ST_Length(ST_CollectionExtract(ST_Intersection(r.geom, s.geom), 2)::geography) / 1000)::numeric, 2) AS km_in_sector
FROM roads r
JOIN sectors s ON ST_Intersects(r.geom, s.geom)
ORDER BY r.name, s.name;
