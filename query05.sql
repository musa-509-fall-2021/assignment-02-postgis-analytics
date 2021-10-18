/*
Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods. Describe your accessibility metric:
*/


/*
Accessibility metric:
Percentage of bus stations that have elevator accessibility in a neighborhood.

Explanation:
1. Perform a spatial join of Azavea's neighborhoods dataset and SEPTA GTFS bus stations dataset.
2. For each neighborhood, sum the total number of stations and the number of wheelchair-accessible stations according to 'wheelchair_boarding' column.
3. Divide number of wheelchair-accessible stations by total number of stations in the neighborhood.

Issues:
For some unknown reason, the query (as well as the standalone subquery contained in the CTE) returns no data. Perhaps it is something to do with my machine and the query works when executed elsewhere.
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