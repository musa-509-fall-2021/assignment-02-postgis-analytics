/* query 02
Which bus stop has the smallest population within 800 meters?
*/

WITH septa_bus_stop_block_groups AS (
    SELECT
        s.stop_id,
        '1500000US' || bg.geoid10 AS geo_id
    FROM septa_bus_stops AS s
    JOIN census_block_groups AS bg
        ON ST_DWithin(
           ST_Transform(s.the_geom, 32129),
            ST_Transform(bg.the_geom, 32129),
			800 )
),
septa_bus_stop_surrounding_population AS (
    SELECT
        stop_id,
        SUM(total) AS estimated_pop_800m
    FROM septa_bus_stop_block_groups AS s
    JOIN census_population AS p ON s.geo_id = p.id
    GROUP BY stop_id
)
SELECT 
    stop_name,
    estimated_pop_800m,
    the_geom
FROM septa_bus_stop_surrounding_population
JOIN septa_bus_stops USING (stop_id)
ORDER BY estimated_pop_800m ASC
LIMIT 1