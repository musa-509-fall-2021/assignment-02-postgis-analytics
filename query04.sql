/*
Using the shapes.txt file from GTFS bus feed, find the two routes with the longest trips. In the final query, give the trip_headsign that corresponds to the shape_id of this route and the length of the trip.

*/



WITH copy_shapes AS (
	select * 
    FROM SEPTA_BUS_SHAPES)
, joined as (
	select 
		a.shape_id,
		a.shape_pt_sequence as sps_1,
		a.the_geom as geo_1,
		b.shape_pt_sequence as sps_2,
		b.the_geom as geo_2
	from septa_bus_shapes as a
	left join copy_shapes as b 
	on a.shape_id = b.shape_id and a.shape_pt_sequence = b.shape_pt_sequence-1)

select 
	shape_id as trip_headsign,
	sum(st_distance(st_transform(geo_1,32129),st_transform(geo_2,32129))) as trip_length
from joined
group by 1
order by 2 DESC
limit 2



/*
trip_headsign trip_length
266630        46452.89305160814
266697        45328.09812355311
*/
