/*
  With a query involving PWD parcels and census block groups,
  find the geo_id of the block group that contains Meyerson Hall.
  ST_MakePoint() and functions like that are not allowed.

geoid: 42101039001

*/

with meyerson as (
  select the_geom
    from phl_pwd_parcels
    where address = '220-30 S 34TH ST'
)
select geoid10
  from census_block_groups c
  join meyerson m
  on ST_Within(m.the_geom,c.the_geom)
