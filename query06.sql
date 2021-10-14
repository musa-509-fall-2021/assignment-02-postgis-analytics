with scores as (select stop_name,the_geom,wheelchair_boarding,
			case  when parent_station is null and wheelchair_boarding = '1'  then 1
				when parent_station is not null and wheelchair_boarding = '1' then 2
				when parent_station is not null and (wheelchair_boarding = '1' or wheelchair_boarding is null ) then 1
			end as scores
	from septa_bus_stops)

,joined as (select 
		n.name as neighborhood_name,
		s.*
	from neighborhoods_philadelphia as n
	left join scores as s
		on st_contains(st_transform(n.geom,4326),s.the_geom)
			)
	
select a.*,u.num_bus_stops_unaccessible,t.total_score
from (select neighborhood_name,
			count(*) as num_bus_stops_accessible
	from joined
	where wheelchair_boarding = '1'
	group by 1) as a
join (select neighborhood_name,
			count(*) as num_bus_stops_unaccessible
	from joined
	where wheelchair_boarding = '2'
	group by 1) as u
	on a.neighborhood_name = u.neighborhood_name
join (select neighborhood_name,
	 	sum(scores) as total_score
	 from joined
	 group by 1) as t
	 on t.neighborhood_name = u.neighborhood_name
order by t.total_score desc
