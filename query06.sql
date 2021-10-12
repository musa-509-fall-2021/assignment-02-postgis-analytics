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

DROP INDEX IF EXISTS neighborhoods_philadelphia_the_geom_idx;
CREATE index neighborhoods_philadelphia_the_geom_idx
	on neighborhoods_philadelphia
	using GiST(st_transform(the_geom, 32129));

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
), 
nbhdAccessibleStops as (
	select nbhd.name, count(*)
	from neighborhoods_philadelphia nbhd
	left join accessibleStops accStp 
	on st_contains(nbhd.the_geom, st_transform(accStp.the_geom,32129))
	group by nbhd.name
), 
nbhdInAccessibleStops as (
	select nbhd.name, count(*)
	from neighborhoods_philadelphia nbhd
	left join inaccessibleStops inAccStp
	on st_contains(nbhd.the_geom, st_transform(inAccStp.the_geom,32129))
	group by nbhd.name
)

select nbhd.name as neighborhood_name, 
		sum(aidxgeom.accessibility_metric) as accessibility_metric,
		max(accStp.count) as num_bus_stops_accessible,
		max(inAccStp.count) as num_bus_stops_inaccessible
from neighborhoods_philadelphia nbhd
	join accessibilityIDXgeom aidxgeom 
	on st_contains(nbhd.the_geom, aidxgeom.the_geom)
	left join nbhdAccessibleStops accStp 
	on nbhd.name = accStp.name
	left join nbhdInAccessibleStops inAccStp
	on nbhd.name = inAccStp.name
group by nbhd.name
order by accessibility_metric desc
limit 5;