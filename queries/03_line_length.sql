-- title: Length of each road in kilometres
-- category: Measurement & validity
-- functions: ST_Length, ::geography
-- expect_rows: 10
-- note: ST_Length(geom) on 4326 gives degrees; the geography cast gives metres.
SELECT name,
       round((ST_Length(geom::geography) / 1000)::numeric, 2) AS length_km
FROM roads
ORDER BY length_km DESC;
