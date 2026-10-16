-- title: K-means into 4 groups, with a centre per group
-- category: Clustering
-- functions: ST_ClusterKMeans, ST_Collect, ST_Centroid
-- expect_rows: 4
-- note: Unlike DBSCAN, every point is assigned, and you choose k up front.
WITH k AS (
    SELECT geom,
           ST_ClusterKMeans(ST_Transform(geom, 32643), 4) OVER () AS cid
    FROM facilities
)
SELECT cid,
       count(*)                                         AS n,
       ST_AsText(ST_Centroid(ST_Collect(geom)), 5)      AS centre
FROM k
GROUP BY cid
ORDER BY cid;
