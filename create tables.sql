

01.septa_bus_stops
-- Clear database of table --
drop table if exists septa_bus_stops;
-- create table for septa_bus_stops
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
-- import data into septa_bus_stops table.
copy septa_bus_stops
    from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/septa_bus_stops.csv'
    with (format csv, header true);

-- add geometry field to bus stop data.
ALTER TABLE septa_bus_stops
	ADD COLUMN the_geom geometry(Point, 4326);

UPDATE septa_bus_stops
	SET the_geom = ST_SetSRID(ST_MakePoint(stop_long, stop_lat), 4326);

select*
	from septa_bus_stops;


02.census_populations
-- census_block_populations
DROP TABLE IF EXISTS census_populations;
create table census_populations (
    "id" VARCHAR(23) PRIMARY KEY NOT NULL,
    "name" VARCHAR(75) NOT NULL,
    "total" NUMERIC(7) NOT NULL
);

copy census_populations
    from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/census_population.csv'
    with (format csv, header true);

    select *
    	from census_population

03.septa_rail_stops
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


04.census_block_grouops
--load with postGIS
ALTER TABLE if exists census_block_group RENAME COLUMN geom TO the_geom;
UPDATE census_block_group SET the_geom = ST_Transform(ST_SetSRID(the_geom, 4326),32129);

05.phl_pwd_parcels
--load with postGIS
--phl_pwd_parcels
UPDATE phl_pwd_parcels
  SET the_geom = ST_Transform(the_geom,32129);

select*
from phl_pwd_parcels;

06.septa_bus_shapes
  --load with postGIS septa_but_shapes
  DROP TABLE IF EXISTS septa_bus_shapes;

create table septa_bus_shapes(
	"shape_id" NUMERIC(7) NOT NULL,
	"shape_pt_lat" FLOAT NOT NULL,
	"shape_pt_lon" FLOAT NOT NULL,
	"shape_pt_sequence" integer);

copy septa_bus_shapes
   from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/septa_bus_shapes.txt'
    with (format csv, header true,delimiter',');

alter table septa_bus_shapes
    add column if not exists the_geom geometry(Point, 4326);

update septa_bus_shapes
	SET the_geom = ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat), 4326);

select*
from  septa_bus_shapes


create index.

  DROP INDEX IF EXISTS septa_bus_stops_the_geom_idx;
  create index septa_bus_stops_the_geom_idx
      on septa_bus_stops
      using GiST(the_geom);


  DROP INDEX IF EXISTS phl_pwd_parcels_the_geom_idx;
      CREATE index phl_pwd_parcels_the_geom_idx
      	on phl_pwd_parcels
      	using GiST(the_geom);
