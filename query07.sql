/*
What are the bottom five neighborhoods according to your accessibility metric?
*/


WITH septa_bus_stop_neighborhoods AS (
    SELECT
        septa_bus_stops.stop_id,
        septa_bus_stops.wheelchair_boarding,
        neighborhoods_philadelphia."NAME" AS neighborhood_name
    FROM septa_bus_stops
    JOIN neighborhoods_philadelphia
    ON ST_Contains(
        neighborhoods_philadelphia.geometry,
        septa_bus_stops.the_geom
        )
)

SELECT 
    neighborhood_name,
    COUNT(CASE WHEN wheelchair_boarding = 1 then 1 end) / (COUNT(*)) AS accessibility_metric,
    COUNT(CASE WHEN wheelchair_boarding = 1 then 1 end) AS num_bus_stops_accessible,
    COUNT(CASE WHEN wheelchair_boarding = 2 then 1 end) AS num_bus_stops_inaccessible
FROM septa_bus_stop_neighborhoods
GROUP BY neighborhood_name
ORDER BY accessibility_metric ASC
LIMIT 5