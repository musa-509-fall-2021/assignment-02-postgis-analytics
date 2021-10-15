/*
Firstly, there are two types station, one is parentless station and another is children station.
For those parentless station, if its value is 1 then it can get 1 score, else it gets 0 score.
For those children station, if its value is 1 or null then it can plus 1 score, and if its value is 2 then it gets 2 scores, else it gets 0 score.
*/

create index if not exists wheelchair_boarding__idx
    on septa_bus_stops
    using HASH (wheelchair_boarding);
  
with scores as (select stop_name,the_geom,wheelchair_boarding,
			case  when parent_station is null and wheelchair_boarding = '1'  then 1
				when parent_station is not null and wheelchair_boarding = '1' then 2
				when parent_station is not null and (wheelchair_boarding = '0' or wheelchair_boarding is null ) then 1
				else 0
			end as scores
	from septa_bus_stops)

, joined as (select 
		n.name as neighborhood_name,
		s.*
	from neighborhoods_philadelphia as n
	left join scores as s
		on st_contains(st_transform(n.geom,4326),s.the_geom))
	
, total_score as (select neighborhood_name, coalesce(sum(scores),0) as total_scores
from joined
group by 1)

, n_accessible as (
	select nei.name, 
           acce.num_bus_stops_accessible
	from neighborhoods_philadelphia as nei
	left join (select neighborhood_name,
			count(*) as num_bus_stops_accessible
		from joined
		where scores = 1 or scores = 2
		group by 1 ) as acce
    on nei.name = acce.neighborhood_name)

, n_unaccessible as  (
	select nei.name,
           unacce.num_bus_stops_unaccessible
	from neighborhoods_philadelphia as nei
	left join (select neighborhood_name,
			count(*) as num_bus_stops_unaccessible
		from joined
		where scores = 0
		group by 1 ) as unacce
    on nei.name = unacce.neighborhood_name)

, final as (select a.*,u.num_bus_stops_unaccessible,t.total_scores
from n_accessible as a 
join n_unaccessible as u
on a.name = u.name
join total_score as t
on u.name = t.neighborhood_name)


select *
from final
order by total_scores desc

