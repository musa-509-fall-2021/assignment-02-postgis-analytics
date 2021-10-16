-- 2. Which bus stop has the smallest population within 800 meters?

--   **The queries to #1 & #2 should generate relations with a single row, with the following structure:**

--   ```sql
--   (
--       stop_name text, -- The name of the station
--       estimated_pop_800m integer, -- The population within 800 meters
--       the_geom geometry(Point, 4326) -- The geometry of the bus stop
--   )
--   ```
-- Answer: 
-- stop_name               Population      the_geom                                  --
-- "Charter Rd & Norcom Rd"	2	"0101000020E6100000C896E5EB32C052C0DF3312A1110C4440" --


with septa_bus_stop_block_groups as (
    select
        s.stop_id,
		-- Concatenate block group prefix & suffix to make proper Fkey --
        '1500000US' || bg.geoid10 as geo_id
    from septa_bus_stops as s
    join census_block_groups as bg
        on ST_DWithin(
            ST_Transform(s.the_geom, 32129),
            ST_Transform(bg.the_geom, 32129),
            800
        )
),
septa_bus_stop_surrounding_population as (
    select
        stop_id,
        sum(total) as estimated_pop_800m
    from septa_bus_stop_block_groups as s
    join population as p on s.geo_id = p.id
    group by stop_id
)
select
    stop_name,
    estimated_pop_800m,
    the_geom
from septa_bus_stop_surrounding_population
join septa_bus_stops using (stop_id)
order by estimated_pop_800m asc
limit 1