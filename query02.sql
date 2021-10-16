/*
  Which bus stop has the smallest population within 800 meters?

*/
-- connect the population with groups


with stops_block_800m as (
    select c.geoid10,
           s.stop_name,
           s.stop_id,
           s.the_geom
    from septa_bus_stops as s
    join
    census_block_groups as c
    on st_dwithin(ST_Transform(s.the_geom,2272),ST_Transform(c.the_geom,2272),800)
),

      POP_DATA as (
      select ss.geoid10 as geo_id,
             ss.stop_name,
             d.total as population,
             ss.the_geom
      from stops_block_800m as ss
      join
      census_population as d
      on cast(ss.geoid10 as text) = substring(d.id,10)
)

select stop_name,
       sum(population)as estimated_pop_800m,
       the_geom
from POP_DATA
group by stop_name, the_geom
order by estimated_pop_800m
limit 1

/*Charter Rd& Norcom Rd
*/
