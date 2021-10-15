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
	select nei.name AS neighborhood_name, 
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
on a.neighborhood_name = u.name
join total_score as t
on u.name = t.neighborhood_name)


select *
from final
order by total_scores 
limit 5


/*  

neighborhood_name    num_bus_stops_accessible    num_bus_stops_accessible   total_scores
MECHANICSVILLE       NULL                        NULL                       0
BARTRAM_VILLAGE      NULL                        14                         0
CRESTMONT_FARMS      1                           NULL                       1
WEST_TORRESDALE      1                           NULL                       1
WISSAHICKON_HILLS    2                           NULL                       2

*/
