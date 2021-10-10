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

select block_name,
		count(*) as num_bus_stops_accessible
from joined
where wheelchair_boarding = '1'
group by 1
order by 2 DESC
limit 5
