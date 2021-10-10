create table census_population (
	"id" text,
	"name" text,
	"total" integer
);

copy census_population
from '/Users/Shared/Assignment2-data/census_population.csv'
with (format csv, header true);

create table census_block_groups (
    "id" integer,
    "statefp10" numeric(4,0),
    "countyfp10" character varying(12),
    "tractce10" character varying(12),
    "blkgrpce10" character  varying(13),
    "geoid10" character  varying(12),
    "namelsad10" character  varying(13),
    "MTFCC10" character  varying(12),
    "FUNCSTAT10" character  varying(12),
    "ALAND10" numeric(8,0),
    "AWATER10" numeric(7,0),
    "INTPTLAT10" character  varying(11),
    "INTPTLON10" character  varying(12),
    "Shape__Area" numeric(24,15),
    "Shape__Length" numeric(24,15)
);

copy census_block_groups
from '/Users/Shared/Assignment2-data/census_block_groups.csv'
with (format csv, header true);

create table phl_pwd_parcels (
    "OBJECTID" integer,
    "PARCELID" integer,
    "TENCODE" text,
    "ADDRESS" text,
    "OWNER1" text,
    "OWNER2" text,
    "BLDG_CODE" text,
    "BLDG_DESC" text,
    "BRT_ID" text,
    "NUM_BRT" integer,
    "NUM_ACCOUNTS" integer,
    "GROSS_AREA" integer,
    "Shape__Area" numeric,
    "Shape__Length" numeric
);
copy phl_pwd_parcels
from '/Users/Shared/Assignment2-data/phl_pwd_parcels.csv'
with (format csv, header true);

create table septa_bus_shapes (
    "shape_id" integer,
    "shape_pt_lat" numeric,
    "shape_pt_lon" numeric,
    "shape_pt_sequence" integer
);

create table septa_bus_stops (
    stop_id integer,
    stop_name text,
    stop_lat numeric,
    stop_lon numeric,
    location_type text,
    parent_station integer,
    zone_id text,
    wheelchair_boarding integer   
);

create table septa_rail_stops(
    stop_id integer,
    stop_name text,
    stop_desc text,
    stop_lat numeric,
    stop_lon numeric,
    zone_id text,
    stop_url text
);

copy septa_bus_shapes
from '/Users/Shared/Assignment2-data/septa_bus_shapes.csv'
with (format csv, header true);

copy septa_bus_stops
from '/Users/Shared/Assignment2-data/septa_bus_stops.csv'
with (format csv, header true);

copy septa_rail_stops
from '/Users/Shared/Assignment2-data/septa_rail_stops.csv'
with (format csv, header true);

create table septa_bus_trips (
	route_id text,
	service_id integer,
	trip_id integer,
	trip_headsign text,
	block_id integer,
	direction_id integer,
	shape_id integer
);

copy septa_bus_trips
from '/Users/Shared/Assignment2-data/septa_bus_trips.csv'
with (format csv, header true);