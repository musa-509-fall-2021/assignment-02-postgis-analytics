/*
Which bus stop has the smallest population within 800 meters?
*/


create index septa_bus_stops__the_geom__32129__idx
    on septa_bus_stops
    using GiST (st_transform(the_geom, 32129));

with septa_bus_stop_block_groups as (
    select
        s.stop_id,
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
        s.stop_id,
        sum(p.total) as estimated_pop_800m
    from septa_bus_stop_block_groups as s
    join census_population as p 
  	 on s.geo_id = p.id
    group by stop_id
)

select
    s.stop_name,
    b.estimated_pop_800m,
    s.the_geom
from septa_bus_stop_surrounding_population as b
join septa_bus_stops as s 
on s.stop_id = b.stop_id
order by estimated_pop_800m
limit 1
