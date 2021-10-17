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
