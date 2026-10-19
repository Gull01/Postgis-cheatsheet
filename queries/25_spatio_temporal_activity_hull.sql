-- title: Compute vehicle activity convex hull and operational area
-- category: Trajectory & mobility
-- functions: ST_ConvexHull, ST_Collect, ST_Area, ::geography
-- expect_rows: 3
-- note: Outlines each vehicle's spatial bounding envelope and calculates its geographic coverage in square kilometres.
SELECT v.id,
       v.name,
       count(p.id)                                                                        AS ping_count,
       round((ST_Area(ST_ConvexHull(ST_Collect(p.geom))::geography) / 1e6)::numeric, 3) AS activity_area_km2,
       ST_AsText(ST_ConvexHull(ST_Collect(p.geom)), 5)                                    AS hull_wkt
FROM vehicles v
JOIN gps_pings p ON v.id = p.vehicle_id
GROUP BY v.id, v.name
ORDER BY v.id;
