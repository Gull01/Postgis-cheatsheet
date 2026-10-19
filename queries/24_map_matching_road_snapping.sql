-- title: Snap noisy GPS pings to nearest road centerline
-- category: Trajectory & mobility
-- functions: ST_ClosestPoint, ST_LineLocatePoint, ST_Distance, ::geography
-- expect_rows: 16
-- note: Projects noisy raw sensor telemetry to nearest road segment using a LATERAL nearest-neighbour join.
SELECT p.id                                                                 AS ping_id,
       p.recorded_at,
       r.name                                                               AS matched_road,
       round(ST_Distance(p.geom::geography, r.geom::geography)::numeric, 1) AS offset_error_m,
       ST_AsText(p.geom, 5)                                                 AS raw_point,
       ST_AsText(ST_ClosestPoint(r.geom, p.geom), 5)                        AS snapped_point,
       round((ST_LineLocatePoint(r.geom, p.geom) * 100)::numeric, 2)        AS pct_along_road
FROM (
    SELECT id, recorded_at, geom
    FROM gps_pings
    WHERE vehicle_id = 3
) p
CROSS JOIN LATERAL (
    SELECT name, geom
    FROM roads
    ORDER BY p.geom <-> geom
    LIMIT 1
) r
ORDER BY p.recorded_at;
