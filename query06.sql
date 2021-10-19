/*
	What are the top five neighborhoods according to your accessibility metric?
	
	Structure:
	
	(
	neighborhood_name text,  -- The name of the neighborhood
	accessibility_metric ...,  -- Your accessibility metric value
	num_bus_stops_accessible integer,
	num_bus_stops_inaccessible integer
	)
*/
with stops_available as(
	select np.name as neighborhood_name, count(bs.wheelchair_boarding) as stops_available
	from septa_bus_stops as bs
	join neighborhoods_phl as np
	on ST_within(ST_Transform(bs.the_geom, 4326),  ST_Transform(st_setsrid(np.geom, 2272), 4326))
	where bs.wheelchair_boarding = 1
	group by neighborhood_name
),
stops_unavailable as(
	select np.name as neighborhood_name, count(bs.wheelchair_boarding) as stops_unavail
	from septa_bus_stops as bs
	join neighborhoods_phl as np
	on ST_within(ST_Transform(bs.the_geom, 4326),  ST_Transform(st_setsrid(np.geom, 2272), 4326))
	where bs.wheelchair_boarding = 2
	group by neighborhood_name
),
neigh_with_index as(
	select a.neighborhood_name, a.stops_available, una.stops_unavail, (a.stops_available - COALESCE(una.stops_unavail,0)) as accessibility_index
	from stops_available as a
	left join 
	(
		select neighborhood_name, stops_unavail
		from stops_unavailable
	) as una
	on a.neighborhood_name = una.neighborhood_name
)
select neighborhood_name, stops_available as num_bus_stops_accessible, 
stops_unavail as num_bus_stops_inaccessible,
case
	when accessibility_index<0 then '1'
	when accessibility_index>0 and accessibility_index<10 then '2'
	when accessibility_index>=10 and accessibility_index<50 then '3'
	when accessibility_index>=50 and accessibility_index<100 then '4'
	when accessibility_index>=100 then '5'
end as accessibility_metric
from neigh_with_index
order by stops_available desc
limit 5


