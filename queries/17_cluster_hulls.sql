-- title: Convex hull and area of each DBSCAN cluster
-- category: Clustering
-- functions: ST_ClusterDBSCAN, ST_ConvexHull, ST_Collect
-- expect_rows: 3
-- note: Turns point clusters into polygons you can map. Noise points (cluster_id NULL) are excluded.
WITH c AS (
    SELECT geom,
           ST_ClusterDBSCAN(ST_Transform(geom, 32643), 400, 4) OVER () AS cid
    FROM facilities
)
SELECT cid,
       count(*) AS n,
       round((ST_Area(ST_ConvexHull(ST_Collect(geom))::geography) / 10000)::numeric, 1) AS hull_ha,
       ST_ConvexHull(ST_Collect(geom)) AS hull
FROM c
WHERE cid IS NOT NULL
GROUP BY cid
ORDER BY cid;
