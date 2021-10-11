/*
With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.
*/


select 
	c.geoid10 as geo_id
from 
	(select st_setsrid(geom,4326) AS par_geom
	 from phl_pwd_parcels
	 where address = '220-30 S 34TH ST') as m
left join census_block_groups as c
	on st_contains(st_setsrid(c.geom,4326),m.par_geom)
  
  
  /*
geo_id
421010369001
*/

