/*query 09
With a query involving PWD parcels and census block groups, find the geo_id of the block group 
that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.
*/

SELECT cbg.geoid10 AS geo_id
FROM phl_pwd_parcels AS pwd
JOIN census_block_groups as cbg
ON ST_Contains(cbg.geom,pwd.the_geom)
WHERE address LIKE '220-30 S 34TH ST'

--geo_id = 421010369001