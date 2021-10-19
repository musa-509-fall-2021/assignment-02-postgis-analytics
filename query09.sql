/* 
  With a query involving PWD parcels and census block groups, find 
  the geo_id of the block group that contains Meyerson Hall. 
  ST_MakePoint() and functions like that are not allowed. 
*/

-- query with the address of the building just beside Meyerson Hall
SELECT c.geoid10 as geo_id
from phl_pwd_parcels as p
join census_block_groups as c
on ST_Contains(c.geometry,p.geometry)
where address like '220-30 S 34TH ST'
