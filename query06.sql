/* query 06
What are the top five neighborhoods according to your accessibility metric?
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
               COUNT(*) FILTER(WHERE wheelchair_boarding = 1) AS num_bus_stops_accessible,
			   COUNT(*) FILTER(WHERE wheelchair_boarding = 2) AS num_bus_stops_inaccessible,
			   shape_area
		  FROM neighborhood_stops
		  GROUP BY neighborhood_name, shape_area)

SELECT neighborhood_name, 
	   num_bus_stops_accessible, 
	   num_bus_stops_inaccessible,
       (num_bus_stops_accessible/shape_area) AS accessibility_metric
FROM accessible_count
LIMIT 5;
