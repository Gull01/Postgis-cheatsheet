-- title: Calculate segment speed and heading between consecutive GPS fixes
-- category: Trajectory & mobility
-- functions: LAG, ST_Distance, ST_Azimuth, degrees, ::geography
-- expect_rows: 15
-- note: Uses window functions to derive instantaneous velocity (km/h) and compass heading (degrees) between successive points.
WITH legs AS (
    SELECT vehicle_id,
           recorded_at,
           LAG(recorded_at) OVER (PARTITION BY vehicle_id ORDER BY recorded_at) AS prev_time,
           geom,
           LAG(geom)        OVER (PARTITION BY vehicle_id ORDER BY recorded_at) AS prev_geom
    FROM gps_pings
    WHERE vehicle_id = 1
)
SELECT vehicle_id,
       prev_time,
       recorded_at,
       round(ST_Distance(prev_geom::geography, geom::geography)::numeric, 1) AS step_dist_m,
       round(EXTRACT(EPOCH FROM (recorded_at - prev_time))::numeric, 0)      AS duration_sec,
       round((ST_Distance(prev_geom::geography, geom::geography) /
              NULLIF(EXTRACT(EPOCH FROM (recorded_at - prev_time)), 0) * 3.6)::numeric, 1) AS calc_speed_kmh,
       round(degrees(ST_Azimuth(prev_geom, geom))::numeric, 1)               AS heading_deg
FROM legs
WHERE prev_geom IS NOT NULL
ORDER BY recorded_at;
