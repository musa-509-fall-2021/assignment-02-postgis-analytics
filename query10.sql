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

-- DROP INDEX IF EXISTS septa_bus_stops_the_geom_idx;
-- create index septa_bus_stops_the_geom_idx
--     on septa_bus_stops
--     using GiST(st_transform(the_geom, 32129));

-- DROP INDEX IF EXISTS septa_rail_stops_the_geom_idx;
-- CREATE index septa_rail_stops_the_geom_idx
-- 	on septa_rail_stops
-- 	using GiST(st_transform(the_geom, 32129));

with rail_stops as(
	select stop_id, stop_name, stop_lat, stop_lon, the_geom
	from septa_rail_stops
), 
bus_stops as (
	select stop_id, stop_name, the_geom
	from septa_bus_stops
),
bus_routes as (
	select bs.stop_id, bs.stop_name, br.route_long_name 
	from bus_stops bs
	left join septa_bus_stoptimes bst on bs.stop_id = bst.stop_id
		inner join septa_bus_trips bt on bst.trip_id = bt.trip_id
		inner join septa_bus_routes br on bt.route_id::varchar = br.route_id
		
)

select * from bus_routes
-- nearestBusStop as (
-- 	select *
-- 	from rail_stops rs
-- 	cross join lateral (
-- 		select stop_id, st_transform(rs.the_geom,32129) <-> st_transform(bs.the_geom,32129) as distance_m
-- 		from bus_stops bs
-- 		order by distance_m
-- 		limit 1
-- 	) closestBusStation
-- )

-- select stop_id, stop_name, stop_desc, stop_lon, stop_lat  
-- from nearestBusStop



