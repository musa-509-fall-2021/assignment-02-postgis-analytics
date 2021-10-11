/* 9. With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall.
ST_MakePoint() and functions like that are not allowed. 

ANSWER: The geo_id of the block group that contains Meyerson Hall is "421010369001". 
I defined the address of Meyerson Hall as 3400-04 WALNUT ST in phl_pwd_parcels.
*/
with Meyerson as
(SELECT address,geom from phl_pwd_parcels
where address = '3400-04 WALNUT ST')
select geoid10 as geo_id
from census_block_groups a
join Meyerson as b
on ST_Contains(a.geom,b.geom)