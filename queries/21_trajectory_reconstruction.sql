-- title: Reconstruct vehicle trajectories and total trip distance
-- category: Trajectory & mobility
-- functions: ST_MakeLine, ST_Length, ::geography
-- expect_rows: 3
-- note: Aggregates chronological GPS fixes into a LineString and computes total geodesic distance in kilometres.
SELECT v.id,
       v.name,
       v.vehicle_type,
       count(p.id)                                                                                   AS ping_count,
       round((ST_Length(ST_MakeLine(p.geom ORDER BY p.recorded_at)::geography) / 1000)::numeric, 2) AS trip_length_km,
       ST_AsText(ST_MakeLine(p.geom ORDER BY p.recorded_at))                                        AS trip_linestring
FROM vehicles v
JOIN gps_pings p ON v.id = p.vehicle_id
GROUP BY v.id, v.name, v.vehicle_type
ORDER BY v.id;
