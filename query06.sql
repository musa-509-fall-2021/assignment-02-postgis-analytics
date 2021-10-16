/*
What are the _top five_ neighborhoods according to your accessibility metric
*/
with stop_info as(
		select
		sum(wheelchair_boarding) as num_wb,
		count(*) filter(where wheelchair_boarding in (1,2)) as num_bus_stops_accessible,
	    count(*) filter(where wheelchair_boarding = 0) as num_bus_stops_inaccessible,
		name as neighborhood,
		count(*) as num_stop
		from septa_bus_stops s
		join neighborhoods_philadelphia n
		on st_contains(n.geom,s.the_geom)
		group by neighborhood),

	neigh_info as (
		select shape_area,
		name
		from neighborhoods_philadelphia),


	all_info as (select *
		from stop_info s
		join neigh_info n
		on s.neighborhood=n.name)

select
		num_bus_stops_accessible,
		num_bus_stops_inaccessible,
		round((num_stop/shape_area*1000000)*0.6+(100*num_wb/num_stop)*0.4,2) as accessibility_metric,
		neighborhood as neighborhood_name
from all_info
order by accessibility_metric desc
limit 5

/*
Bartram_village, Woodland_terrance, Southwest_schulylkill, Paschall, Cedar_park
*/
