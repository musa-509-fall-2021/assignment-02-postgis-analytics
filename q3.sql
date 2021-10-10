alter table phl_pwd_parcels
	alter column geom TYPE geometry(geomtry,0)
	using ST_SetSRID(geom,32129);

select
	p.ADDRESS,
	s.stop_name,
	ST_Distance(geometry(s.the_geom),geometry(p.geom)) as distance_m
from
	phl_pwd_parcels as p
	cross join LATERAL
	(select stop_name, the_geom
	from septa_bus_stops
	order by p.geom desc
	limit 1) as s