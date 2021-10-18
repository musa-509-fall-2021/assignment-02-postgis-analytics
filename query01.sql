/*
 Which bus stop has the largest population within 800 meters? As a rough
 estimation, consider any block group that intersects the buffer as being part
 of the 800 meter buffer.
 */
CREATE INDEX septa_bus_stops__geometry__32129__idx ON septa_bus_stops USING GiST (st_transform(the_geom, 32129));

WITH septa_bus_stop_block_groups AS (
    SELECT
        s.stop_id,
        '1500000US' || bg.geoid10 AS geo_id
    FROM
        septa_bus_stops AS s
        JOIN census_block_groups AS bg ON ST_DWithin(
            st_transform(s.the_geom, 32129),
            st_transform(bg.the_geom, 32129),
            800
        )
),
septa_bus_stop_surrounding_population AS (
    SELECT
        stop_id,
        sum(p.p001001) AS estimated_pop_800m
    FROM
        septa_bus_stop_block_groups AS s
        JOIN census_pop AS p USING (geo_id)
    GROUP BY
        stop_id
)
SELECT
    stop_name,
    estimated_pop_800m,
    st_transform(the_geom, 32129) AS the_geom
FROM
    septa_bus_stop_surrounding_population
    JOIN septa_bus_stops USING (stop_id)
ORDER BY
    estimated_pop_800m DESC
LIMIT
    1;