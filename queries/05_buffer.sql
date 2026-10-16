-- title: 500 m buffer around every hospital
-- category: Buffers & proximity
-- functions: ST_Buffer, ::geography, ::geometry
-- expect_rows: 8
-- note: Buffering geography takes metres. Cast back to geometry to store or map the result.
SELECT id,
       name,
       ST_Buffer(geom::geography, 500)::geometry AS buffer_500m
FROM facilities
WHERE type = 'hospital';
