/*
You're tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed.
Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), and PostgreSQL string functions,
build a description (alias as `stop_desc`) for each stop.
Feel free to supplement with other datasets (must provide link to data used so it's reproducible),
and other methods of describing the relationships. PostgreSQL's `CASE` statements may be helpful for some operations.
*/

/* In this query, I combined the 'septa_rail_stops' and 'septa_bus_stops' and calulate the convenience of transfer of each rail stop:
with the radius of 300m, how many bus stops near the rail stop
*/

ALTER TABLE septa_rail_stops
  ADD the_geom  geometry;
  
UPDATE septa_rail_stops
    set the_geom = st_setsrid(st_makepoint(stop_lon, stop_lat), 4326);

with rail as (
	select stop_name,
			the_geom
	from septa_rail_stops
 ),

	bus as (
		select stop_name,
		       the_geom
		from septa_bus_stops
	),

	convenience as(
			select count(*) as bus_stop,
		       r.stop_name as rail_stop
			from rail r
		  join bus b
		  on st_dwithin(st_transform(r.the_geom,2272),st_transform(b.the_geom,2272),300)
		  group by rail_stop
	)

select
	stop_id,
	stop_name,
	coalesce(bus_stop,0) as stop_desc,
	stop_lon,
	stop_lat
from septa_rail_stops s
left join convenience c
on c.rail_stop=s.stop_name
