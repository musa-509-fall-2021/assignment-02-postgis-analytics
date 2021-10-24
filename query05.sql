/* query 05
Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an 
appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in 
rating neighborhoods. Describe your accessibility metric:

My accessibility metric is the ratio of number of bus stops with wheelchair accessibility to neighborhood area.

I couldn't get the spatial join to work, so the query comes up empty

*/


CREATE INDEX IF NOT EXISTS wheelchair_boarding__idx
    ON septa_bus_stops
    USING HASH (wheelchair_boarding);

CREATE INDEX IF NOT EXISTS neighborhood_idx
    ON septa_bus_stops
    USING HASH (wheelchair_boarding);

WITH neighborhood_stops AS (
	 SELECT p.name, p.geom, b.wheelchair_boarding, p.shape_area
     FROM neighborhoods_philadelphia AS p
	 JOIN septa_bus_stops AS b
	 ON ST_Within(ST_Transform(p.geom,4326), 
				  ST_Transform(b.the_geom,4326))),
				  
	 accessible_count AS(
	    SELECT name AS neighborhood_name,
               COUNT(*) FILTER(WHERE wheelchair_boarding = 1) 
		 					AS num_bus_stops_accessible,
			   COUNT(*) FILTER(WHERE wheelchair_boarding = 2) 
		 					AS num_bus_stops_inaccessible,
			   shape_area
		  FROM neighborhood_stops
		  GROUP BY neighborhood_name, shape_area)

SELECT neighborhood_name, 
	   num_bus_stops_accessible, 
	   num_bus_stops_inaccessible,
       (num_bus_stops_accessible/shape_area) AS accessibility_metric
FROM accessible_count;

