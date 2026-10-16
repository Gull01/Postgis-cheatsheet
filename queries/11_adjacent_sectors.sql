-- title: Neighbouring sectors that share an edge
-- category: Spatial joins
-- functions: ST_Touches, ST_Intersection, ST_Dimension, array_agg
-- expect_rows: 20
-- note: ST_Touches alone also returns diagonal (corner-only) neighbours. Requiring a 1-D intersection keeps edge neighbours only.
SELECT a.name AS sector,
       array_agg(b.name ORDER BY b.name) AS neighbours
FROM sectors a
JOIN sectors b
  ON a.id <> b.id
 AND ST_Touches(a.geom, b.geom)
 AND ST_Dimension(ST_Intersection(a.geom, b.geom)) = 1
GROUP BY a.name
ORDER BY a.name;
