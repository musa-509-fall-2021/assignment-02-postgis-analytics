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
	using GiST(the_geom);

DROP INDEX IF EXISTS pwd_parcels_the_geom_idx;
CREATE index pwd_parcels_the_geom_idx
	on pwd_parcels
	using GiST(the_geom);

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
-- Buffer radius of 152.5 meters = 500 ft --
accessibleBuffers as (
	select stop_id, st_buffer(st_transform(the_geom,32129),152.5) as the_geom
	from stops
	where wheelchair_boarding = 1
),
-- Make accessible region into one feature --
accessibleZone as (
	select st_union(the_geom) as the_geom
	from accessibleBuffers
), 
-- Associate neighborhoods with their accessible regions --
nbhdAccessibleZones as (
	select nbhd.name, st_intersection(nbhd.the_geom, az.the_geom) as the_geom
	from accessibleZone as az, neighborhoods_philadelphia as nbhd
), 
-- Count the number of parcels within each accessible zone --
nbhdAZpclCount as (
	select nbhdZns.name, count(pcls.the_geom) as accessibility_metric
	from nbhdAccessibleZones nbhdZns
	left join pwd_parcels pcls
	on st_contains(nbhdZns.the_geom, pcls.the_geom)
	group by nbhdZns.name
), 
Count number of accessible / inaccessible stops by PHL neighborhoods
nbhdCounts as (
	select nbhd.name,
	count(*) filter(where wheelchair_boarding=1) as num_bus_stops_accessible,
	count(*) filter(where wheelchair_boarding=2) as num_bus_stops_accessible
	from neighborhoods_philadelphia nbhd
	left join stops
	on st_contains(nbhd.the_geom, st_transform(stops.the_geom,32129))
	group by nbhd.name
)

select nc.name as neighborhood_name, 
		accessibility_metric, 
		num_bus_stops_accessible, 
		num_bus_stops_accessible
from nbhdCounts nc
full join nbhdAZpclCount nazc
on nc.name = nazc.name

-- select * from nbhdCounts



-- select nbhdZns.name,
-- 	count(pcls.gid) as accessibility_metric
-- -- 	,
-- -- 	count(*) filter(where wheelchair_boarding=1) as num_bus_stops_accessible,
-- -- 	count(*) filter(where wheelchair_boarding=2) as num_bus_stops_accessible
-- from nbhdAccessibleZones nbhdZns
-- 	left join pwd_parcels pcls
-- 	on st_contains(nbhdZns.the_geom, pcls.the_geom)
-- -- 	left join stops 
-- -- 	on st_contains(nbhdZns.the_geom, st_transform(stops.the_geom,32129))
-- group by nbhdZns.name
-- order by accessibility_metric desc
-- limit 5