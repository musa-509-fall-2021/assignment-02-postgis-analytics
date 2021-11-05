/*What are the top five neighborhoods according to your accessibility metric?
(
  neighborhood_name text,  -- The name of the neighborhood
  accessibility_metric ...,  -- Your accessibility metric value
  num_bus_stops_accessible integer,
  num_bus_stops_inaccessible integer
)
*/

--add the_geom and match the coordinate system.
alter table neighborhoods
	add column the_geom geometry(Geometry, 32129);

update neighborhoods
	set the_geom = ST_Transform(geometry,32129);

with
bus_neighbours as
(
	select
	a."NAME" as name,
	b.wheelchair_boarding,
	a."Shape_Area" as area
	from neighborhoods a
	join septa_bus_stops b
	on st_contains(ST_Transform(a.the_geom, 32129),ST_Transform(b.the_geom, 32129))
),
bus_access as
(
	select name as neighborhood_name,
	count(*) filter (where wheelchair_boarding in (1,2)) as num_bus_stops_accessible,
	count(*) filter (where wheelchair_boarding = 0) as num_bus_stops_inaccessible,
	area
	from bus_neighbours
  group by neighborhood_name,area
)
select neighborhood_name, num_bus_stops_accessible,num_bus_stops_inaccessible,
	num_bus_stops_accessible/area as accessibility_metric
	from bus_access
  order by accessibility_metric desc
	limit 5
