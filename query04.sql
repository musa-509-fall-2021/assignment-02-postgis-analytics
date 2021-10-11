alter table septa_bus_shapes
    add column the_geom geometry(Geometry, 32129);

update septa_bus_shapes
    set the_geom = ST_Transform(ST_SetSRID(st_makepoint(
	               shape_pt_lon, shape_pt_lat),4326),32129);

with septa_bus_lines as (
	SELECT shape_id, 
      ST_MakeLine(the_geom) As linepath
	FROM septa_bus_shapes As bl
	GROUP BY shape_id)

select shape_id as trip_headsign,
       ST_Length(linepath) as trip_length
	   FROM septa_bus_lines
	   order by trip_length
	   desc
	   limit 2

/*
  266630 46504meters
  266697 45331meters
*/
