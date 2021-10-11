/* 7. What are the bottom five neighborhoods according to your accessibility metric?
ANSWER: bottom five neighborhoods are: 
1.BARIRAM_VILLAGE
2.PORT_RICHMOND
3.WEST_TORRESDALE
4.NAVY_YARD
5.AIRPORT
*/

with accessible_bus_stops as
(
	select stop_name, wheelchair_boarding, the_geom
	from septa_bus_stops
),
bus_neighbours as
(
	select a.name, a.the_geom, b.wheelchair_boarding,
	ST_AREA(a.the_geom) as area_size
	from neighborhood a
	join septa_bus_stops b
	on st_contains(a.the_geom,b.the_geom)
),
bus_neighbours_access as 
(
	select name as neighborhood_name,
	count(*) filter (where wheelchair_boarding = 1) as num_bus_stops_accessible,
	count(*) filter (where wheelchair_boarding = 2) as num_bus_stops_inaccessible,
	area_size
	from bus_neighbours
  group by neighborhood_name,area_size
)
select neighborhood_name, num_bus_stops_accessible,num_bus_stops_inaccessible,
	num_bus_stops_accessible/area_size as accessibility_metric
	from bus_neighbours_access
	order by accessibility_metric asc
	limit 5;
