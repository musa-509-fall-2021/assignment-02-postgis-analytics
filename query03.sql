/**
3. Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with 
its closest bus stop.  The final result should give the parcel address, bus stop name, 
and distance apart in
meters. Order by distance (largest on top).

  **Structure:**
  ```sql
  (
      address text,  -- The address of the parcel
      stop_name text,  -- The name of the bus stop
      distance_m double precision  -- The distance apart in meters
  )
  ```
**/


-- take the parcels geometry and join it to the bus stop data
-- using ST_Nearest to find the nearest bus stop
-- Then use ST_Distance to calculate the distance between the parcels
-- center and the bus stop X, Y
-- then order by distance descending

with bus_stop_geom as (		
	select stop_id, stop_name, ST_SetSRID(ST_Point(stop_lon, stop_lat),6) as geometry
	from septa_bus_stops
),
phl_pwd_parcels_lim as (
	select *
	from phl_pwd_parcels
	limit 20
)
select *
from phl_pwd_parcels_lim
as pwd
cross join lateral (
    select
        bg.stop_name AS stop_name,
		ST_Distance(ST_Transform(bg.geometry,32129), ST_Transform(pwd.geometry,32129)) as distance_m		
    from bus_stop_geom as bg
    order by distance_m desc
    limit 1
) as q