/*
	Using the shapes.txt file from GTFS bus feed, find the two routes with the longest trips. 
	In the final query, give the trip_headsign that corresponds to the shape_id of this route 
	and the length of the trip.
	
	Structure:
	
	(
    trip_headsign text,  -- Headsign of the trip
    trip_length double precision  -- Length of the trip in meters
	)
*/
ALTER TABLE septa_bus_shapes
ADD geom geometry;
UPDATE septa_bus_shapes
set geom = st_transform(st_setsrid(st_makepoint(shape_pt_lon, shape_pt_lat), 4326),32129);

with shape_lines as (
select shape_id, st_makeline(geom order by shape_pt_sequence) as lines
from septa_bus_shapes
group by shape_id
),
shape_length as (
select shape_id, st_length(lines) as length, lines
from shape_lines
order by length desc
)

select sl.shape_id as trip_headsign, sl.length as trip_length
from shape_length as sl
order by length desc
limit 2

/*
Query result:
266630	46504.1353058882
266697	45331.4675320343
*/

