-- title: Area and centroid of each polygon
-- category: Measurement & validity
-- functions: ST_Area, ST_Centroid, ::geography
-- expect_rows: 20
-- note: Cast to geography for square metres on the ellipsoid. ST_Area on 4326 geometry returns square degrees.
SELECT name,
       round((ST_Area(geom::geography) / 1e6)::numeric, 3) AS area_km2,
       ST_AsText(ST_Centroid(geom), 5)                      AS centroid
FROM sectors
ORDER BY name;
