/*
Using the _shapes.txt_ file from GTFS bus feed, find the **two** routes with the longest trips.
In the final query, give the `trip_headsign` that corresponds to the `shape_id` of this route and the length of the trip.
*/

alter table septa_bus_shapes
add the_geom geometry;

update septa_bus_shapes
set the_geom = st_setsrid(st_makepoint(shape_pt_lon, shape_pt_lat), 4326);

/* import the _trips.text_ file to get the `trip_headsign` information
create table trips(
	"route_id" text,
	"service_id" integer,
	"trip_id" integer,
	"trip_headsign" text,
	"block_id" integer,
	"direction_id" integer,
	"shape_id" integer
);
copy trips from 'C:\Users\Public\musa509\google_bus\trips.txt'
with (format csv, header true, delimiter ',')
*/

with name as(
	select shape_id,
	       trip_headsign
	from trips
group by shape_id,trip_headsign),

length as (select shape_id,
       st_length(st_makeline(the_geom))*111000 as trip_length
from septa_bus_shapes
group by shape_id
order by trip_length desc)

select n.trip_headsign,
       l.trip_length
from length l
left join name n
on l.shape_id = n.shape_id
order by trip_length desc
limit 2
