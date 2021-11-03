
/*Using the shapes.txt file from GTFS bus feed, find the two routes with the
longest trips. In the final query, give the trip_headsign that corresponds to
 the shape_id of this route and the length of the trip.*/

trip_headsign text,  -- Headsign of the trip
trip_length double precision  -- Length of the trip in meters

alter table septa_bus_shapes
	add column the_geom2 geometry(Geometry, 32129);

update septa_bus_shapes
	set the_geom = ST_Transform(ST_SetSRID(st_makepoint(shape_pt_lon,shape_pt_lat),4326),32129);


  --transform the crs into 32129,add new column.

  update septa_bus_shapes
    	set the_geom2= ST_Transform(ST_SetSRID(st_makepoint(shape_pt_lon,shape_pt_lat),4326),32129);

  --
  select *
  	FROM septa_bus_trips

  drop table if exists septa_bus_trips;

  create table septa_bus_trips(
  	"route_id" text,
  	"service_id" integer,
  	"trip_id" integer,
  	"trip_headsign" text,
  	"block_id" integer,
  	"direction_id" integer,
  	"shape_id" integer
  );

  copy septa_bus_trips
      from 'E:/Class/MUSA 509-geospatial computing visulization/Assignment02/data/final/datafinal/trips.txt'
      with (format csv, header true,delimiter',');


with name as(
				select shape_id,trip_headsign
				from septa_bus_trips
				group by 1,2),
		shape as (
				select shape_id,
			 		 st_length(st_makeline(
						 the_geom2 order by shape_pt_sequence)
							  )as trip_length
			from septa_bus_shapes
			group by shape_id)

	select name.trip_headsign,
					shape.trip_length
					from name
			left join shape
			on name.shape_id=shape.shape_id
			order by trip_length desc
			limit 2

/*example in first class
with stations_line as (
  select st_makeline(the_geom order by addresszipcode) as the_geom
  from indego_station_statuses
)

SELECT
  1 as cartodb_id,
  the_geom,
  st_transform(the_geom, 3857) as the_geom_webmercator
FROM stations_line
*/
