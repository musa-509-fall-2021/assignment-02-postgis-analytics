/* 5.Rate neighborhoods by their bus stop accessibility for wheelchairs. 
Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. 
Use the GTFS documentation for help. 
Use some creativity in the metric you devise in rating neighborhoods. Describe your accessibility metric: 
I calculated the accessibility by divding the sum of bus stops where wheelchair_boarding = 1 (also defined as accessible bus stops) by the county area size.
*/

ALTER TABLE neighborhood
ADD COLUMN the_geom geometry;

update neighborhood
set the_geom = st_transform(geometry,32129);

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