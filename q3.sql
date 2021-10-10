/*Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. 
The final result should give the parcel address, bus stop name, and distance apart in meters. 
Order by distance (largest on top).
*/

alter table phl_pwd_parcels
	alter column geom TYPE geometry(geomtry,0)
	using ST_SetSRID(geom,32129);

select
	ph.ADDRESS,
	s.stop_name,
	ST_Distance(geometry(s.the_geom),geometry(ph.geom)) as distance_m
from
	phl_pwd_parcels as ph
	cross join LATERAL
	(select stop_name, the_geom
	from septa_bus_stops
	order by ph.geom desc
	limit 1) as s
