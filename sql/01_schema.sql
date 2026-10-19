-- Schema for the PostGIS cheat sheet sample dataset.
-- All geometries are stored in EPSG:4326 (WGS 84, lon/lat).
CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS gps_pings, vehicles, facilities, roads, sectors CASCADE;

-- 20 simplified rectangular "sectors" on an Islamabad-style grid (F-6 ... I-10).
CREATE TABLE sectors (
    id     serial PRIMARY KEY,
    name   text   NOT NULL UNIQUE,
    series char(1) NOT NULL,                      -- F, G, H, I
    geom   geometry(Polygon, 4326) NOT NULL
);

-- 60 synthetic points of interest.
CREATE TABLE facilities (
    id   serial PRIMARY KEY,
    name text   NOT NULL,
    type text   NOT NULL CHECK (type IN ('hospital','school','park','market','pharmacy')),
    geom geometry(Point, 4326) NOT NULL
);

-- 10 synthetic roads (4 east-west, 5 north-south, 1 diagonal).
CREATE TABLE roads (
    id   serial PRIMARY KEY,
    name text   NOT NULL,
    geom geometry(LineString, 4326) NOT NULL
);

-- Vehicles for trajectory and mobility tracking.
CREATE TABLE vehicles (
    id           serial PRIMARY KEY,
    name         text   NOT NULL UNIQUE,
    vehicle_type text   NOT NULL CHECK (vehicle_type IN ('ambulance', 'delivery_van', 'patrol_car'))
);

-- GPS breadcrumb telemetry for vehicles.
CREATE TABLE gps_pings (
    id           serial PRIMARY KEY,
    vehicle_id   int    NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    recorded_at  timestamptz NOT NULL,
    speed_kmh    numeric(5,1),
    geom         geometry(Point, 4326) NOT NULL
);

-- Spatial indexes. The functional geography indexes let queries that cast
-- `geom::geography` (for metre-based ST_DWithin / ST_Distance) use an index too.
CREATE INDEX sectors_geom_gix      ON sectors    USING gist (geom);
CREATE INDEX facilities_geom_gix   ON facilities USING gist (geom);
CREATE INDEX roads_geom_gix        ON roads      USING gist (geom);
CREATE INDEX gps_pings_geom_gix    ON gps_pings  USING gist (geom);

CREATE INDEX sectors_geog_gix      ON sectors    USING gist ((geom::geography));
CREATE INDEX facilities_geog_gix   ON facilities USING gist ((geom::geography));
CREATE INDEX roads_geog_gix        ON roads      USING gist ((geom::geography));
CREATE INDEX gps_pings_geog_gix    ON gps_pings  USING gist ((geom::geography));

-- Temporal index for trajectory chronological queries.
CREATE INDEX gps_pings_vehicle_time_idx ON gps_pings (vehicle_id, recorded_at);

