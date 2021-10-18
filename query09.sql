/*
  With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains
  Meyerson Hall. ST_MakePoint() and functions like that are not allowed.
*/

with nearest_meyerson as(
	select *
	from phl_pwd_parcels
	where address like '2__ S 34TH ST%'
)

select b.geoid10 as geoid
from nearest_meyerson as nm
join census_block_groups as b
on st_within(nm.the_geom, st_transform(b.the_geom, 32129))

/*Result: 421010369001