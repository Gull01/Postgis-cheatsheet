-- title: Dissolve sectors into one polygon per series
-- category: Tessellation & dissolve
-- functions: ST_Union, GROUP BY
-- expect_rows: 4
-- note: ST_Union as an aggregate is PostGIS's dissolve. Shared edges disappear.
SELECT series,
       count(*) AS sectors,
       round((ST_Area(ST_Union(geom)::geography) / 1e6)::numeric, 2) AS area_km2,
       ST_Union(geom) AS geom
FROM sectors
GROUP BY series
ORDER BY series;
