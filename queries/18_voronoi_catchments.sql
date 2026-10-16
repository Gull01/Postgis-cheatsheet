-- title: Hospital catchments with Voronoi polygons
-- category: Tessellation & dissolve
-- functions: ST_VoronoiPolygons, ST_Dump, ST_Intersection, ST_Envelope
-- expect_rows: 8
-- note: Each cell is the area closer to its hospital than to any other. Voronoi is planar, so this is an approximation in 4326 at city scale.
WITH pts AS (
    SELECT ST_Collect(geom) AS g FROM facilities WHERE type = 'hospital'
),
study AS (
    SELECT ST_MakeEnvelope(72.986, 33.660, 73.096, 33.740, 4326) AS g
),
cells AS (
    SELECT (ST_Dump(ST_VoronoiPolygons(pts.g, 0, study.g))).geom AS cell
    FROM pts, study
)
SELECT h.name AS hospital,
       round((ST_Area(ST_Intersection(c.cell, study.g)::geography) / 1e6)::numeric, 3) AS catchment_km2,
       ST_Intersection(c.cell, study.g) AS catchment
FROM cells c
CROSS JOIN study
JOIN facilities h ON h.type = 'hospital' AND ST_Contains(c.cell, h.geom)
ORDER BY h.name;
