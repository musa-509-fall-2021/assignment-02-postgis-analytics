-- 4. Using the _shapes.txt_ file from GTFS bus feed, find the **two** routes with the longest trips. 
-- In the final query, give the `trip_headsign` that corresponds to the `shape_id` of this route 
-- and the length of the trip.

--   **Structure:**
--   ```sql
--   (
--       trip_headsign text,  -- Headsign of the trip
--       trip_length double precision  -- Length of the trip in meters
--   )
--   ```

with busRouteLines as (
	select shape_id, st_transform(st_makeline(the_geom),32129) as the_line_geom
	from septa_bus_shapes
	group by shape_id
)

select distinct(t.trip_headsign) as trip_headsign, st_length(r.the_line_geom) as trip_length
from busRouteLines r
left join septa_bus_trips t
on r.shape_id = t.shape_id
order by trip_length desc
limit 2;
