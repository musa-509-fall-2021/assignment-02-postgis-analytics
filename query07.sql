-- query07
/*
 What are the _bottom five_ neighborhoods according 
 to your accessibility metric?
 */

SELECT
    accessibility_rank,
    neighborhood_name,
    accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM
    phl_hood_accessible_transit
ORDER BY
    accessibility_rank DESC
LIMIT
    5