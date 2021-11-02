
/*Using the shapes.txt file from GTFS bus feed, find the two routes with the
longest trips. In the final query, give the trip_headsign that corresponds to
 the shape_id of this route and the length of the trip.*/


alter table septa_bus_shapes
	add column the_geom geomtry(Geometry, 32129);

update septa_bus_shapes
	set the_geom = ST_Transform(ST_SetSRID(st_makepoint(shape_pt_lon,shape_pt_lat),4326),32129);

with septa_bus_lines as(
	select shape_id,
	ST_MakeLine(the_geom) as line
	from septa_bus_shapes as sh
	group by shape_id)

select shape_id as trip_headsign,
	ST_Length(line) as trip_length
	from septa_bus_lines
	limit 2
