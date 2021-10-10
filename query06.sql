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

with accessibleStops as (
	select stop_id, the_geom
	from septa_bus_stops
	where wheelchair_boarding = 1
), 
inaccessibleStops as (
	select stop_id, the_geom
	from septa_bus_stops
	where wheelchair_boarding = 0 OR wheelchair_boarding = 2
), 
accessibleBuffers as (
	select stop_id, st_buffer(st_transform(the_geom,32129),322) as the_geom
	from accessibleStops
), 
accessibilityIDX as (
	select stop_id, count(*) as accessibility_metric
	from accessibleBuffers buf
	left join pwd_parcels pcls
	on st_contains(buf.the_geom, pcls.the_geom)
	group by stop_id
), 
accessibilityIDXgeom as (
	select a.stop_id as stop_id, a.accessibility_metric as accessibility_metric, st_transform(s.the_geom,32129) as the_geom
	from accessibilityIDX a
	left join septa_bus_stops s
	on a.stop_id = s.stop_id
)

select nbhd.name as neighborhood_name, 
		sum(aidxgeom.accessibility_metric) as accessibility_metric,
		count(accStp.stop_id) as num_bus_stops_accessible,
		count(inAccStp.stop_id) as num_bus_stops_inaccessible
from neighborhoods_philadelphia nbhd
	left join accessibilityIDXgeom aidxgeom 
	on st_contains(st_transform(nbhd.the_geom,32129), aidxgeom.the_geom)
	left join accessibleStops accStp 
	on st_contains(st_transform(nbhd.the_geom,32129), st_transform(accStp.the_geom,32129))
	left join inaccessibleStops inAccStp
	on st_contains(st_transform(nbhd.the_geom,32129), st_transform(inAccStp.the_geom,32129))
group by nbhd.name
order by accessibility_metric desc
limit 5;

