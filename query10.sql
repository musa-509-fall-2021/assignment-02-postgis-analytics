-- 10. You're tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed. 
-- Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), and PostgreSQL string functions, 
-- build a description (alias as `stop_desc`) for each stop. Feel free to supplement with other datasets 
-- (must provide link to data used so it's reproducible), and other methods of describing the relationships. 
-- PostgreSQL's `CASE` statements may be helpful for some operations.

--   **Structure:**
--   ```sql
--   (
--       stop_id integer,
--       stop_name text,
--       stop_desc text,
--       stop_lon double precision,
--       stop_lat double precision
--   )
--   ```

-- As an example, your `stop_desc` for a station stop may be something like "37 meters NE of 1234 Market St" 
-- (that's only an example, feel free to be creative, silly, descriptive, etc.)
--   **Tip when experimenting:** Use subqueries to limit your query to just a few rows to keep query times faster. 
-- Once your query is giving you answers you want, scale it up. E.g., instead of `FROM tablename`, 
-- use `FROM (SELECT * FROM tablename limit 10) as t`.

DROP INDEX IF EXISTS septa_bus_stops_the_geom_idx;
create index septa_bus_stops_the_geom_idx
    on septa_bus_stops
    using GiST(st_transform(the_geom, 32129));

DROP INDEX IF EXISTS septa_rail_stops_the_geom_idx;
CREATE index septa_rail_stops_the_geom_idx
	on septa_rail_stops
	using GiST(st_transform(the_geom, 32129));
	
DROP INDEX IF EXISTS busStopTimes_tripid;
CREATE index busStopTimes_tripid
	on septa_bus_stoptimes
	using BTREE(trip_id);

DROP INDEX IF EXISTS busStopTimes_stopid;
CREATE index busStopTimes_stopid
	on septa_bus_stoptimes
	using BTREE(stop_id);


with rail_stops as(
	select stop_id, stop_name, stop_lat, stop_lon, the_geom
	from septa_rail_stops
), 
bus_stops as (
	select stop_id as bus_stop_id, stop_name as bus_stop_name, the_geom
	from septa_bus_stops
),
nearestBusStop as (
	select rs.stop_id as rail_stop_id, rs.stop_name, rs.stop_lon, rs.stop_lat, cbs.bus_stop_id, round(distance_m::numeric, 2) as distance_m
	from rail_stops rs
	cross join lateral (
		select bs.bus_stop_id, st_transform(rs.the_geom,32129) <-> st_transform(bs.the_geom,32129) as distance_m
		from bus_stops bs
		order by distance_m
		limit 1
	) cbs
),
bus_routes as (
	select distinct(bs.bus_stop_id), bs.bus_stop_name, sbr.route_long_name as bus_route_name, bs.the_geom
	from bus_stops bs
	left join septa_bus_stoptimes bst on bs.bus_stop_id = bst.stop_id
		inner join septa_bus_trips bt on bst.trip_id = bt.trip_id
		inner join septa_bus_routes sbr on bt.route_id::varchar = sbr.route_id
),
rail_and_NBS as (
	select distinct(nbs.rail_stop_id), nbs.stop_name, nbs.stop_lon, nbs.stop_lat, 
		br.bus_stop_name, br.bus_route_name, nbs.distance_m
	from nearestBusStop nbs
	left join bus_routes br 
	on nbs.bus_stop_id = br.bus_stop_id
	order by 1
)

select rail_stop_id as stop_id, 
		stop_name, 
		format('The closest bus stop is %s and is %s meters away. It is serviced by the %s route.',bus_stop_name, distance_m, bus_route_name) stop_desc, 
		stop_lon, 
		stop_lat
from rail_and_NBS

