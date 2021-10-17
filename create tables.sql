
-- septa_bus_stops
drop table if exists septa_bus_stops;
create table septa_bus_stops (
    "stop_id" text,
    "stop_name" text,
    "stop_lat" float,
	"stop_long" float,
	"location_type" integer,
	"parent_station" integer,
	"zone_id" integer,
	"wheelchair_boarding" integer
);

copy septa_bus_stops
    from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/septa_bus_stops.csv'
    with (format csv, header true);


ALTER TABLE septa_bus_stops
	ADD COLUMN the_geom geometry(Point, 4326);

UPDATE septa_bus_stops
	SET the_geom = ST_SetSRID(ST_MakePoint(stop_long, stop_lat), 4326);

select*
	from septa_bus_stops;

-- census_block_populations
create table census_block_populations (
    "id" text,
    "name" text,
    "total" integer
);

copy census_block_populations
    from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/census_population.csv'
    with (format csv, headers true);

--septa_rail_stops
DROP TABLE IF EXISTS septa_rail_stops;
create table septa_rail_stops (
    "stop_id" NUMERIC(5) PRIMARY KEY NOT NULL,
    "stop_name" text,
    "stop_lat" FLOAT NOT NULL,
	"stop_long" FLOAT NOT NULL,
	"zone_id" varchar
);

copy septa_rail_stops
    from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/septa_rail_stops -2.csv'
    with (format csv, header true);

ALTER TABLE septa_rail_stops
	ADD COLUMN the_geom geometry(Point, 4326);

update septa_rail_stops
	SET the_geom = ST_SetSRID(ST_MakePoint(stop_long, stop_lat), 4326);

select *
	from septa_rail_stops


--census_population
DROP TABLE IF EXISTS census_population;
create table census_population (
    "id"	VARCHAR(23) PRIMARY KEY NOT NULL,
	"geographic_area_name" VARCHAR(75) NOT NULL,
	"Total" NUMERIC(7) NOT NULL
);

copy census_population
    from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/census_population.csv'
    with (format csv, header true);

select *
	from census_population


****
DROP TABLE IF EXISTS phl_pwd_parcels;
create table phl_pwd_parcels (
   "OBJECTID" NUMERIC(6),
   "PARCELID" NUMERIC(10),
   "TENCODE" varchar,
   "ADDRESS" VARCHAR(75),
   "OWNER1"	text,
	"OWNER2" VARCHAR(70),
	"BLDG_CODE"	varchar,
	"BLDG_DESC"	VARCHAR(100) ,
	"BRT_ID" varchar,
	"NUM_BRT" integer,
	"NUM_ACCOUNTS" integer,
	"GROSS_AREA" integer,
	"Shape__Area" FLOAT,
	"Shape__Length" FLOAT
);

copy phl_pwd_parcels
    from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/phl_pwd_parcels.csv'
    with (format csv, header true);



UPDATE phl_pwd_parcels
	SET the_geom = ST_SetSRID(the_geom, 4326);

select *
	from phl_pwd_parcels
