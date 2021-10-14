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


-- Try unionized buffer, then st_intersection of that buffer w/ nbhds to get neighborhood accessibility regions
-- then count the # parcels within the stop buffers

DROP INDEX IF EXISTS neighborhoods_philadelphia_the_geom_idx;
CREATE index neighborhoods_philadelphia_the_geom_idx
	on neighborhoods_philadelphia
	using GiST(st_transform(the_geom, 32129));

DROP INDEX IF EXISTS stopBufferIDX;
CREATE INDEX stopBufferIDX
	on septa_bus_stops
	using GiST(st_buffer(st_transform(the_geom,32129),322));

-- Remove bus stops outside of County of PHL limits 
with PHL as(
	select st_union(the_geom) as the_geom
	from neighborhoods_philadelphia nbhd
), 
stops as (
	select stop_id, wheelchair_boarding, s.the_geom as the_geom
	from septa_bus_stops s, PHL
	where st_contains(PHL.the_geom, st_transform(s.the_geom,32129))
), 
-- Buffer radius of 322 meters = 0.2 miles --
accessibleBuffers as (
	select stop_id, st_buffer(st_transform(the_geom,32129),322) as the_geom
	from stops
	where wheelchair_boarding = 1
), 
stop_accessibilityScore as (
	select s.stop_id as stop_id, count(distinct(pcls.the_geom)) as accessibility_metric,
		st_transform(s.the_geom,32129) as the_geom
	from accessibleBuffers buf
	left join pwd_parcels pcls
	on st_contains(buf.the_geom, pcls.the_geom)
	left join septa_bus_stops s
	on buf.stop_id = s.stop_id
	group by s.stop_id
), 
nbhd_counts as (
	select nbhd.name,
		sum(accScore.accessibility_metric) as accessibility_metric,
		count(*) filter(where wheelchair_boarding=1) as num_bus_stops_accessible,
		count(*) filter(where wheelchair_boarding=2) as num_bus_stops_accessible
	from neighborhoods_philadelphia nbhd
		left join stop_accessibilityScore accScore
		on st_contains(nbhd.the_geom, accScore.the_geom)
		left join stops 
		on st_contains(nbhd.the_geom, st_transform(stops.the_geom,32129))
	group by nbhd.name
	order by accessibility_metric desc
	limit 5
)

select * from nbhd_counts
