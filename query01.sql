/*
  Which bus stop has the largest population within 800 meters? As a rough
  estimation, consider any block group that intersects the buffer as being part
  of the 800 meter buffer.
*/


/*
  postgres database file :
  https://drive.google.com/file/d/1knvX-PO8a8pzZiRyL8IFDi8xCgjGCOpJ/view?usp=sharing
  setup file:
  ./setup.sql
*/

create index septa_bus_stops__the_geom__32129__idx
    on septa_bus_stops
    using GiST (ST_Transform(the_geom, 32129));


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
        stop_id,
        sum(total) as estimated_pop_800m
    from septa_bus_stop_block_groups as s
<<<<<<< HEAD
    join census_population as p on geo_id=id
=======
    join census_population as p on (s.geo_id = p.id)
>>>>>>> c4d4dee05f6ae426e14c12241245e80ac79d9109
    group by stop_id
)

select
    stop_name,
    estimated_pop_800m,
    st_transform (the_geom,4326) the_geom
from septa_bus_stop_surrounding_population
join septa_bus_stops using (stop_id)
order by estimated_pop_800m desc
limit 1
