-- title: Detect vehicle stop and dwell events (>15 minutes within 50 metres)
-- category: Trajectory & mobility
-- functions: ST_ClusterDBSCAN, ST_Transform, ST_Centroid, ST_Collect, EXTRACT(EPOCH)
-- expect_rows: 1
-- note: Projects to UTM 43N to cluster stationary GPS pings within 50 metres and filters for dwell duration >= 15 minutes.
WITH clustered AS (
    SELECT vehicle_id,
           recorded_at,
           geom,
           ST_ClusterDBSCAN(ST_Transform(geom, 32643), eps := 50, minpoints := 3) OVER (
               PARTITION BY vehicle_id ORDER BY recorded_at
           ) AS cluster_id
    FROM gps_pings
    WHERE vehicle_id = 1
),
stops AS (
    SELECT vehicle_id,
           cluster_id,
           min(recorded_at) AS stop_start,
           max(recorded_at) AS stop_end,
           count(*)         AS pings_in_stop,
           ST_Centroid(ST_Collect(geom)) AS stop_location
    FROM clustered
    WHERE cluster_id IS NOT NULL
    GROUP BY vehicle_id, cluster_id
)
SELECT vehicle_id,
       stop_start,
       stop_end,
       round((EXTRACT(EPOCH FROM (stop_end - stop_start)) / 60)::numeric, 1) AS dwell_minutes,
       pings_in_stop,
       ST_AsText(stop_location, 5) AS stop_centroid
FROM stops
WHERE EXTRACT(EPOCH FROM (stop_end - stop_start)) >= 900
ORDER BY stop_start;
