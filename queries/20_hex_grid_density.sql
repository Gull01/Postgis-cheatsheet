-- title: Facility density on a ~1 km hexagon grid
-- category: Tessellation & dissolve
-- functions: ST_HexagonGrid, ST_Intersects
-- expect_rows: 23
-- note: Requires PostGIS 3.1+. Size is in CRS units (degrees here). Inner join returns only occupied hexagons.
SELECT h.i, h.j,
       count(f.id) AS facilities,
       h.geom
FROM ST_HexagonGrid(0.01, ST_MakeEnvelope(72.986, 33.660, 73.096, 33.740, 4326)) AS h
JOIN facilities f ON ST_Intersects(h.geom, f.geom)
GROUP BY h.i, h.j, h.geom
ORDER BY facilities DESC, h.i, h.j;
