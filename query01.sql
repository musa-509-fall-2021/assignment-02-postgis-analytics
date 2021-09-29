/*
  Which bus stop has the largest population within 800 meters? As a rough
  estimation, consider any block group that intersects the buffer as being part
  of the 800 meter buffer.
*/


create index septa_bus_stops__the_geom__32129__idx
    on septa_bus_stops
    using GiST (ST_Transform(ST_SetSRID(ST_Makepoint(stop_lon,stop_lat),4326), 32129));


with septa_bus_stop_block_groups as (
    select
        s.stop_id,
        '1500000US' || bg.geoid10 as geo_id
    from septa_bus_stops as s
    join census_block_groups as bg
        on ST_DWithin(
            ST_Transform(ST_SetSRID(ST_Makepoint(s.stop_lon,s.stop_lat),4326), 32129),
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
    ST_Setsrid(ST_makepoint(s.stop_lon,s.stop_lat),4326) as the_geom
from septa_bus_stop_surrounding_population as b
join septa_bus_stops as s 
on s.stop_id = b.stop_id
order by estimated_pop_800m desc
limit 1
