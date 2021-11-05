/*Rate neighborhoods by their bus stop accessibility for wheelchairs.
 Use Azavea's neighborhood dataset from OpenDataPhilly along with an
 appropriate dataset from the Septa GTFS bus feed.
 Use the GTFS documentation for help. Use some creativity
 in the metric you devise in rating neighborhoods.
 Describe your accessibility metric:*/


 From my opinion, I create a variable calculating the density of wheelchair
 boarding in each neighborhood.
 There are three steps.
step1. group the stops by the neighborhood block,select all the bus stops contain in the neighborhood..
step2. sum up the wheelchair_boarding in each neighborhood block.
step3. divided the sum results by the area of each neighborhood, I can
        get the density of wheelchair boarding.


        with
        bus_neighbours as
        (
        	select a."NAME" as name, a.the_geom, b.wheelchair_boarding,
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
