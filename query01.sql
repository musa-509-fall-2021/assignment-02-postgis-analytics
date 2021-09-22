/*
  Which bus stop has the largest population within 800 meters? As a rough
  estimation, consider any block group that intersects the buffer as being part
  of the 800 meter buffer.
*/


create index septa_bus_stops__the_geom__2272__idx
    on septa_bus_stops
    using GiST (ST_Transform(the_geom, 2272));


with septa_bus_stop_block_groups as (
    select
        s.stop_id,
        '1500000US' || bg.geoid10 as geo_id
    from septa_bus_stops as s
    join census_block_groups as bg
        on ST_DWithin(
            ST_Transform(s.the_geom, 2272),
            ST_Transform(bg.the_geom, 2272),
            800 * 3.28084
        )
),

septa_bus_stop_surrounding_population as (
    select
        stop_id,
        sum(population) as estimated_pop_800m
    from septa_bus_stop_block_groups as s
    join census_population as p using (geo_id)
    group by stop_id
)

select
    stop_name,
    estimated_pop_800m,
    the_geom
from septa_bus_stop_surrounding_population
join septa_bus_stops using (stop_id)
order by estimated_pop_800m desc
limit 1
