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


with POP_DATA as (
  select c.geoid10 as geo_id,
c.namelsad10 as block_groups,
d.total as population,
st_setsrid(st_makepoint(c.intptlon10,c.intptlat10),4326)::geometry as the_geom
from census_block_groups_2010 as c
join
decennialsf12010_p1_data_with_overlays_2021_09_09t131935 as d
on cast(c.geoid10 as text) = substring(d.id,10)
),

stops as (
  select st_setsrid(st_makepoint(stop_lon,stop_lat),4326)::geometry as the_geom,
  stop_name,
  stop_id
  from stops_cvs
)

select s.stop_name, s.stop_id,
 sum(p.population)as estimated_pop_800m,
 s.the_geom
from POP_DATA as p
join
stops as s
on st_dwithin(ST_Transform(s.the_geom,2272),ST_Transform(p.the_geom,2272),800)
group by s.stop_name, s.stop_id,s.the_geom
order by estimated_pop_800m desc
limit 1
