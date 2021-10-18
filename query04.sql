/*
  Using the shapes.txt file from GTFS bus feed, find the two routes with the longest trips. In the final query, give the
  trip_headsign that corresponds to the shape_id of this route and the length of the trip.
*/

alter table septa_bus_shapes
	add column shape_the_geom geometry(Geometry, 32129);

UPDATE septa_bus_shapes
    set shape_the_geom = st_transform(st_setsrid(st_makepoint(shape_pt_lon, shape_pt_lat), 4326), 32129);

with septa_bus_shapes_length as (
    select
        shape_id,
        st_length(st_makeline(shape_the_geom)) as trip_length
    from septa_bus_shapes
	group by shape_id
)

select
	shape_id as trip_headsign,
    trip_length
from septa_bus_shapes_length
order by trip_length desc
limit 2

/*Result: 
trip_headsign     trip_length
266630	          46504.13530588818
266697	          45331.46753203432