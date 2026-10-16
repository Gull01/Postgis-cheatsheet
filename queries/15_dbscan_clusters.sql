-- title: DBSCAN density clusters (400 m, min 4 points)
-- category: Clustering
-- functions: ST_ClusterDBSCAN, ST_Transform
-- expect_rows: 60
-- note: eps is in CRS units, so project first (EPSG:32643 = UTM 43N, metres). cluster_id NULL means noise.
SELECT id, name, type,
       ST_ClusterDBSCAN(ST_Transform(geom, 32643), 400, 4) OVER () AS cluster_id
FROM facilities
ORDER BY cluster_id NULLS LAST, id;
