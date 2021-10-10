With joined as (
	select 
		c.geoid10 as block_name,
		st_setsrid(c.geom,4326),
		s.stop_name,
		s.wheelchair_boarding,
		s.the_geom
	from census_block_groups as c
	left join septa_bus_stops as s
		on st_contains(st_setsrid(c.geom,4326),s.the_geom))
	, accessible as (
	select block_name,
			count(*) as num_bus_stops_accessible
	from joined
	where wheelchair_boarding = '1'
	group by 1
	)
	, unaccessible as (
	select block_name,
			count(*) as num_bus_stops_unaccessible
	from joined
	where wheelchair_boarding = '2'
	group by 1)

select a.*,u.num_bus_stops_unaccessible
from accessible as a
join unaccessible as u
	on a.block_name = u.block_name
order by a.num_bus_stops_accessible desc
limit 5
