/*
  Which bus stop has the largest population within 800 meters? As a rough
  estimation, consider any block group that intersects the buffer as being part
  of the 800 meter buffer.
*/

-- create index septa_bus_stops__geometry__32129__idx
--     on septa_bus_stops
--     using GiST (st_transform(geometry,32129));


with septa_bus_stop_block_groups as (
    select
        s.stop_id,
        '1500000US' || bg.geoid10 as geo_id
    from septa_bus_stops as s
    join census_block_groups as bg
        on ST_DWithin(
            st_transform(s.geometry,32129),
            st_transform(bg.geometry,32129),
            800
        )
),

septa_bus_stop_surrounding_population as (
    select
        stop_id,
        sum(p.p001001) as estimated_pop_800m
    from septa_bus_stop_block_groups as s
    join census_pop as p using (geo_id)
    group by stop_id
)

select
    stop_name,
    estimated_pop_800m,
    st_transform(geometry,32129) as geometry
from septa_bus_stop_surrounding_population
join septa_bus_stops using (stop_id)
order by estimated_pop_800m asc
limit 1;