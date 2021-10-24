/*query 04
Using the shapes.txt file from GTFS bus feed, find the two routes with the longest trips. 
In the final query, give the trip_headsign that corresponds to the shape_id of this route and the length of the trip.
*/

WITH headsign AS (
	SELECT shape_id,
	       trip_headsign
	FROM septa_bus_trips
GROUP BY shape_id,trip_headsign),

trip_duration AS (
	SELECT shape_id,
       st_length(st_makeline(the_geom))*111000 AS trip_length
FROM septa_bus_shapes
GROUP BY shape_id
ORDER BY trip_length DESC)

SELECT h.trip_headsign,
       td.trip_length
FROM trip_duration td
LEFT JOIN headsign h
ON td.shape_id = h.shape_id
WHERE trip_headsign IS NOT NULL
ORDER BY trip_length DESC
LIMIT 2