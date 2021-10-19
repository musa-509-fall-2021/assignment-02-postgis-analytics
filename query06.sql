-- query06
/*
What are the _top five_ neighborhoods according to
your accessibility metric?
 */
-- CREATE INDEX phl_hood_accessible_transit__geometry__32129__idx 
--     ON phl_hood_accessible_transit 
--     USING GiST (st_transform(the_geom, 32129));
SELECT
    accessibility_rank,
    neighborhood_name,
    accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM
    phl_hood_accessible_transit
ORDER BY
    accessibility_rank ASC
LIMIT
    5