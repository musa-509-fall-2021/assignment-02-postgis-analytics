/*
  Which bus stop has the smallest population within 800 meters?

  **The queries to #1 & #2 should generate relations with a single row, with the following structure:**

  ```sql
  (
      stop_name text, -- The name of the station
      estimated_pop_800m integer, -- The population within 800 meters
      the_geom geometry(Point, 4326) -- The geometry of the bus stop
  )
  ```
*/
-- connect the population with groups

UPDATE census_block_groups
    set the_geom = st_setsrid(st_makepoint(intptlon10, intptlon10), 4326);

UPDATE septa_bus_stops
      set the_geom = st_setsrid(st_makepoint(stop_lon, stop_lat), 4326);

create index stops__the_geom__2272__idx
          on septa_bus_stops
          using GiST (ST_Transform(the_geom, 2272));

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
order by estimated_pop_800m desc
limit 1
