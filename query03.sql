/*
	Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
	pair each parcel with its closest bus stop. The final result should give the parcel address, 
	bus stop name, and distance apart in meters. Order by distance (largest on top).

	Structure:
	
	(
    address text,  -- The address of the parcel
    stop_name text,  -- The name of the bus stop
    distance_m double precision  -- The distance apart in meters
	)
*/

with stop_in_buffer as(
	select p.parcelid, p.address, p.geom, s.stop_name, s.the_geom
	from phl_pwd_parcels as p
	join septa_bus_stops as s
	on ST_dwithin(ST_Transform(s.the_geom, 32129),
            	 ST_Transform(p.geom, 32129), 500)
),
distance_stops as (
	select sp.address, sb.stop_name, 
	st_distance(st_transform(sb.the_geom, 32129), st_transform(sp.geom, 32129)) as distance
	from stop_in_buffer as sb
	cross join phl_pwd_parcels as sp
	where sb.parcelid = sp.parcelid
)
select distance_stops.*
from distance_stops
right join
(
	select address, min(distance) as min_dis
	from distance_stops
	group by address
) as min
on distance_stops.distance = min.min_dis and
distance_stops.address = min.address









