/*
	Rate neighborhoods by their bus stop accessibility for wheelchairs. 
	Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset 
	from the Septa GTFS bus feed. Use the GTFS documentation for help. 
	Use some creativity in the metric you devise in rating neighborhoods. 
	
	Describe your accessibility metric:
	
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
	select a.neighborhood_name, (a.stops_available - COALESCE(una.stops_unavail,0)) as accessibility_index
	from stops_available as a
	left join 
	(
		select neighborhood_name, stops_unavail
		from stops_unavailable
	) as una
	on a.neighborhood_name = una.neighborhood_name
)
select neighborhood_name, accessibility_index,
case
	when accessibility_index<0 then '1'
	when accessibility_index>0 and accessibility_index<10 then '2'
	when accessibility_index>=10 and accessibility_index<50 then '3'
	when accessibility_index>=50 and accessibility_index<100 then '4'
	when accessibility_index>=100 then '5'
end as rating
from neigh_with_index


/*
	Description:
	
	The accessibility index is calculated as the number of wheelchair-friendly bus stops 
	minus the number of wheelchair-unfriendly bus stops in each neighborhood. 
	This index shows the accessibility for the disabled to get on and off a bus. 
	It is linked with a specific bus stop name.
	
	I also rated the accessibility in a scale of 5. 
	5 means great accessibilty while 1 means no accessibility to wheelchair at all.

*/