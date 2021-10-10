-- 6. What are the _top five_ neighborhoods according to your accessibility metric?

--   **Both #6 and #7 should have the structure:**
--   ```sql
--   (
--     neighborhood_name text,  -- The name of the neighborhood
--     accessibility_metric ...,  -- Your accessibility metric value
--     num_bus_stops_accessible integer,
--     num_bus_stops_inaccessible integer
--   )
--   ```

with accessibleBuffers as (
	select stop_id, stop_name, st_buffer(st_transform(the_geom,32129),322) as the_geom
	from septa_bus_stops
	where wheelchair_boarding = 1
), 
accessibleProperties as (
	select stop_id, count(*)
	from accessibleBuffers buf
	left join pwd_parcels pcls
	on st_contains(buf.the_geom, pcls.the_geom)
	group by stop_id
)

select * 
from accessibleProperties