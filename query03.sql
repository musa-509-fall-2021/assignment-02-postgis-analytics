CREATE INDEX phl_pwd_parcels__the__geom__32129__idx
	ON phl_pwd_parcels
	using GiST (ST_Transform(geom, 32129));
  
with joined as (
	select s.stop_name,
		p.address,
		s.the_geom,
		p.geom
	from phl_pwd_parcels as p
	left join septa_bus_stops as s
		on ST_DWithin(
            ST_Transform(p.geom, 32129),
            ST_Transform(s.the_geom, 32129),
            500
        )
)

select m.*,a.stop_name
from (select 
			address,
			min(st_distance(st_transform(the_geom,32129),st_transform(geom,32129))) as distance_m
	from joined
	group by 1
	order by 2) as m
join (select 
		address,
		stop_name,
		st_distance(st_transform(the_geom,32129),st_transform(geom,32129)) as distance
	from joined) as a 
	on (m.address = a.address) and (m.distance_m = a.distance)
