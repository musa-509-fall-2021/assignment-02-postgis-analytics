01.septa_bus_stops
-- Clear database of table --
drop table if exists septa_bus_stops;
-- Create new table --
create table septa_bus_stops(
	  "stop_id" text,
    "stop_name" text,
    "stop_lat" float,
	"stop_lon" float,
	"location_type" integer,
	"parent_station" integer,
	"zone_id" integer,
	"wheelchair_boarding" integer
);
-- Import csv file into server --
copy septa_bus_stops
    from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/datafinal/septa_bus_stops.csv'
    with (format csv, header true);
-- Add the_geom,which is empty now --
ALTER TABLE septa_bus_stops
	ADD COLUMN if not exists the_geom geometry(Point, 4326);
-- Make point with lon and lat,and set projection to 4326 --
UPDATE septa_bus_stops
	SET the_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);
-- Check the dataset --
select*
	from septa_bus_stops


02.septa_bus_shapes
-- Clear database of table --
drop table if exists septa_bus_shapes;
-- Create new table --
create table septa_bus_shapes(
	  "shape_id" NUMERIC(7) NOT NULL,
	"shape_pt_lat" FLOAT NOT NULL,
	"shape_pt_lon" FLOAT NOT NULL,
	"shape_pt_sequence" integer
);
-- Import csv file into server --
copy septa_bus_shapes
    from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/datafinal/septa_bus_shapes.csv'
    with (format csv, header true);
-- Add the_geom,which is empty now --
ALTER TABLE septa_bus_shapes
	ADD COLUMN the_geom geometry(Point, 4326);
-- Make point with lon and lat,and set projection to 4326 --
UPDATE septa_bus_shapes
	SET the_geom = st_transform(ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat), 4326),32129);
-- Check the dataset --
select*
	from septa_bus_shapes

03.septa_rail_stops
-- Clear database of table --
drop table if exists septa_rail_stops;
-- Create new table --
create table septa_rail_stops(
	"stop_id" integer,
	"stop_name" text,
	"stop_desc" text,
	"stop_lat" double precision,
	"stop_lon" double precision,
	"zone_id" varchar,
	"stop_url" varchar
);

-- Import csv file into server --
copy septa_rail_stops
    from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/datafinal/septa_rail_stops.txt'
    with (format csv, header true,delimiter',');
-- Add the_geom,which is empty now --
ALTER TABLE septa_rail_stops
	ADD COLUMN the_geom geometry(Point, 4326);
-- Make point with lon and lat,and set projection to 4326 --
UPDATE septa_rail_stops
	SET the_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);
-- Check the dataset --
select*
	from septa_rail_stops

04.phl_pwd_parcels
--rename the geom column--
ALTER TABLE if exists phl_pwd_parcels
	RENAME COLUMN geom TO the_geom;
--set srid to 0 srid shpfile, then transform the projection to 32129--
UPDATE phl_pwd_parcels
  SET the_geom = ST_Transform(ST_SetSRID(the_geom, 4326),32129);
--check the table--
select *
  from phl_pwd_parcels

05.census_block_groups
drop table if exists census_block_groups;
create table census_block_groups(
  "OBJECTID" integer,
	"STATEFP10" integer,
	"COUNTYFP10" integer,
	"TRACTCE10" integer,
	"BLKGRPCE10" integer,
	"GEOID10" varchar,
	"NAMELSAD10" varchar,
	"MTFCC10" varchar,
	"FUNCSTAT10" varchar,
	"ALAND10"  varchar,
	"AWATER10" integer,
	"INTPTLAT10" FLOAT not null,
	"INTPTLON10" FLOAT not null,
	"Shape_Area" FLOAT not null,
	"Shape_Length" FLOAT not null
);

copy census_block_groups
    from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/datafinal/Census_Block_Groups_2010.csv'
    with (format csv, header true);

ALTER TABLE if exists census_block_groups
	RENAME COLUMN "INTPTLAT10" TO "lat";

ALTER TABLE if exists census_block_groups
	RENAME COLUMN "INTPTLON10" TO "lon";

ALTER TABLE census_block_groups
	ADD COLUMN the_geom geometry(Point, 4326);

update census_block_groups
	SET the_geom = ST_SetSRID(ST_MakePoint(lon, lat), 4326);

```constantly complain don't match.
  update census_block_groups
    SET the_geom = ST_Transform(the_geom,32129);
```

select *
from census_block_groups


06.census_population
DROP TABLE IF EXISTS census_population;
create table census_population (
    "id" VARCHAR(23) PRIMARY KEY NOT NULL,
    "name" VARCHAR(75) NOT NULL,
    "total" NUMERIC(7) NOT NULL
);

copy census_population
    from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/datafinal/census_population.csv'
    with (format csv, header true);

select *
    from census_population

07.bus/trips.txt
