# PostGIS Cheat Sheet

[![tests](https://github.com/Gull01/Postgis-cheatsheet/actions/workflows/test.yml/badge.svg)](https://github.com/Gull01/Postgis-cheatsheet/actions/workflows/test.yml)
![PostGIS 3.4](https://img.shields.io/badge/PostGIS-3.4-336791)
![License MIT](https://img.shields.io/badge/license-MIT-green)

20 spatial SQL queries you can copy, run and adapt: measurement, buffers, spatial joins, KNN, clustering, Voronoi and dissolve. Every query runs against a small synthetic dataset modelled on an Islamabad-style sector grid. A test runner executes every query and checks its expected row count in GitHub Actions.

**Browse the queries with SQL inline: [CHEATSHEET.md](CHEATSHEET.md)**

## Quick start

```bash
git clone https://github.com/Gull01/Postgis-cheatsheet.git
cd postgis-cheatsheet

make up      # PostGIS in Docker, schema + sample data loaded automatically
make demo    # run a guided demonstration with representative results
make test    # runs all 20 queries and checks row counts
make psql    # open a shell and try them yourself
```

### Demo

The guided demo in [`scripts/demo.sql`](scripts/demo.sql) shows the project end to end:

1. Counts the sample sectors, facilities and roads.
2. Finds the five hospitals nearest to a point using a spatial KNN order.
3. Summarizes facilities by type.
4. Counts facilities inside each sector.
5. Summarizes DBSCAN clusters in metres after projecting to UTM.

With Docker Compose:

```bash
docker compose up -d --wait
docker compose exec -T db psql -U postgres -d gis -v ON_ERROR_STOP=1 -f - < scripts/demo.sql
```

On Windows PowerShell, use the same command from the repository directory. If `make` is unavailable, use the `docker compose` commands directly. The database is exposed on host port `5433`, while commands executed inside the `db` container use PostgreSQL's internal port.

The demo uses synthetic data for learning and does not represent official Islamabad boundaries or real facilities.

No Docker? Use any PostgreSQL 13+ with PostGIS 3.1+ (query 20 needs `ST_HexagonGrid`):

```bash
createdb gis
psql -d gis -v ON_ERROR_STOP=1 -f sql/01_schema.sql -f sql/02_sample_data.sql
PGPORT=5432 PGDATABASE=gis ./scripts/run_tests.sh
```

## The queries

<!-- QUERIES:START -->
| # | Query | Key functions |
|---|-------|---------------|
| 1 | [Area and centroid of each polygon](queries/01_area_and_centroid.sql) | `ST_Area, ST_Centroid, ::geography` |
| 2 | [Distance from a point to every hospital (metres)](queries/02_distance_to_point.sql) | `ST_Distance, ST_MakePoint, ::geography` |
| 3 | [Length of each road in kilometres](queries/03_line_length.sql) | `ST_Length, ::geography` |
| 4 | [Detect and repair an invalid geometry](queries/04_validity_check_and_repair.sql) | `ST_IsValid, ST_IsValidReason, ST_MakeValid` |
| 5 | [500 m buffer around every hospital](queries/05_buffer.sql) | `ST_Buffer, ::geography, ::geometry` |
| 6 | [Facilities within 1.5 km of a point](queries/06_within_radius.sql) | `ST_DWithin, ::geography` |
| 7 | [Sectors with no hospital within 1 km (service gaps)](queries/07_sectors_without_hospital.sql) | `NOT EXISTS, ST_DWithin` |
| 8 | [Count facilities per sector (point-in-polygon join)](queries/08_point_in_polygon_counts.sql) | `ST_Contains, LEFT JOIN, GROUP BY` |
| 9 | [Facility counts by type per sector (pivot with FILTER)](queries/09_pivot_counts_by_type.sql) | `ST_Contains, count(*) FILTER` |
| 10 | [Road length inside each sector (line-polygon overlay)](queries/10_road_length_per_sector.sql) | `ST_Intersection, ST_CollectionExtract, ST_Length` |
| 11 | [Neighbouring sectors that share an edge](queries/11_adjacent_sectors.sql) | `ST_Touches, ST_Intersection, ST_Dimension, array_agg` |
| 12 | [5 nearest facilities to a point (KNN)](queries/12_k_nearest_facilities.sql) | `<->, ST_Distance, LIMIT` |
| 13 | [Nearest hospital for every school (KNN with LATERAL)](queries/13_nearest_hospital_per_school.sql) | `CROSS JOIN LATERAL, <->, ST_Distance` |
| 14 | [Nearest road to every market, with distance](queries/14_nearest_road_per_market.sql) | `CROSS JOIN LATERAL, <->, ST_Distance` |
| 15 | [DBSCAN density clusters (400 m, min 4 points)](queries/15_dbscan_clusters.sql) | `ST_ClusterDBSCAN, ST_Transform` |
| 16 | [K-means into 4 groups, with a centre per group](queries/16_kmeans_clusters.sql) | `ST_ClusterKMeans, ST_Collect, ST_Centroid` |
| 17 | [Convex hull and area of each DBSCAN cluster](queries/17_cluster_hulls.sql) | `ST_ClusterDBSCAN, ST_ConvexHull, ST_Collect` |
| 18 | [Hospital catchments with Voronoi polygons](queries/18_voronoi_catchments.sql) | `ST_VoronoiPolygons, ST_Dump, ST_Intersection, ST_Envelope` |
| 19 | [Dissolve sectors into one polygon per series](queries/19_dissolve_by_attribute.sql) | `ST_Union, GROUP BY` |
| 20 | [Facility density on a ~1 km hexagon grid](queries/20_hex_grid_density.sql) | `ST_HexagonGrid, ST_Intersects` |
<!-- QUERIES:END -->

Each file in [`queries/`](queries) starts with a header (title, functions, expected row count, a one-line tip), followed by a single `SELECT`.

## Sample data

Synthetic, in EPSG:4326, centred on an Islamabad-style sector grid. It is for practising queries, not for real analysis.

| Table | Rows | Geometry | Notes |
|-------|------|----------|-------|
| `sectors` | 20 | Polygon | Simplified rectangles named F-6 to I-10; not official boundaries |
| `facilities` | 60 | Point | hospital, school, park, market, pharmacy; part clumped so clustering has something to find |
| `roads` | 10 | LineString | 4 east-west, 5 north-south, 1 diagonal |

`sql/02_sample_data.sql` is generated with a fixed seed by `scripts/generate_sample_data.py`, so results are reproducible.

## Things worth knowing

- **geometry vs geography.** Data is stored as `geometry(..., 4326)`. For metres, cast: `geom::geography`. Areas and lengths computed directly on 4326 geometry are in degrees.
- **Use `ST_DWithin`, not `ST_Distance(...) < x`.** Only `ST_DWithin` can use a spatial index.
- **Clustering needs metres.** DBSCAN and K-means queries project to EPSG:32643 (UTM zone 43N, which covers Islamabad) first. Pick the UTM zone for your own area.
- **Indexes.** `sql/01_schema.sql` creates GiST indexes on each geometry column, plus functional indexes on `(geom::geography)` so geography-cast queries can use an index.
- **KNN.** `ORDER BY geom <-> point LIMIT k` is index-assisted; on 4326 the operator ranks by degrees, which is fine at city scale.

## Project layout

```
queries/       20 numbered .sql files (one query each)
sql/           schema and generated sample data (loaded by Docker on first start)
scripts/       run_tests.sh, build_cheatsheet.py, generate_sample_data.py
CHEATSHEET.md  generated browsable version
```

After editing a query, run `make cheatsheet` to refresh `CHEATSHEET.md` and the table above (CI fails if they are stale).

## Author

Gul Nawaz, [gulnawaz.dev](https://gulnawaz.dev). MIT licensed.
