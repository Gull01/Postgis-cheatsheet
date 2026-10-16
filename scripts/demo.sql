-- Interactive demonstration for the PostGIS cheat sheet sample database.
-- Run with: docker compose exec -T db psql -U postgres -d gis -f - < scripts/demo.sql

\echo ''
\echo '=== PostGIS cheat sheet demo ==='
\echo 'Synthetic Islamabad-style data: 20 sectors, 60 facilities, 10 roads'

\echo ''
\echo '--- 1. Dataset summary ---'
SELECT 'sectors' AS table_name, count(*) AS rows FROM sectors
UNION ALL
SELECT 'facilities', count(*) FROM facilities
UNION ALL
SELECT 'roads', count(*) FROM roads
ORDER BY table_name;

\echo ''
\echo '--- 2. Five nearest hospitals to the demo point ---'
SELECT name,
       round(ST_Distance(
           geom::geography,
           ST_SetSRID(ST_MakePoint(73.05, 33.71), 4326)::geography
       )::numeric) AS distance_m
FROM facilities
WHERE type = 'hospital'
ORDER BY geom <-> ST_SetSRID(ST_MakePoint(73.05, 33.71), 4326)
LIMIT 5;

\echo ''
\echo '--- 3. Facility totals by type ---'
SELECT type, count(*) AS facilities
FROM facilities
GROUP BY type
ORDER BY facilities DESC, type;

\echo ''
\echo '--- 4. Sectors with the most facilities ---'
SELECT s.name, count(f.id) AS facilities
FROM sectors AS s
LEFT JOIN facilities AS f ON ST_Contains(s.geom, f.geom)
GROUP BY s.name
ORDER BY facilities DESC, s.name
LIMIT 5;

\echo ''
\echo '--- 5. DBSCAN cluster summary ---'
WITH clustered AS (
    SELECT ST_ClusterDBSCAN(ST_Transform(geom, 32643), 400, 4) OVER () AS cluster_id
    FROM facilities
)
SELECT COALESCE(cluster_id::text, 'noise') AS cluster, count(*) AS facilities
FROM clustered
GROUP BY cluster_id
ORDER BY cluster_id NULLS LAST;

\echo ''
\echo 'Demo complete. Browse all 20 queries in CHEATSHEET.md.'
