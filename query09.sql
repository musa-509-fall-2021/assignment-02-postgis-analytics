/*
With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.
*/


/*
Explanation:
1. Perform a spatial join, using "ON ST_Contains" of Penn's campus dataset and Census block groups dataset.
2. Identify geoid using two WHERE conditions: (1) owner is 'TRUSTEES OF THE UNIVERSIT' and (2) address is 3400-04 Walnut Street (i.e. address of Weitzman School in orientation to Walnut).
*/

SELECT "GEOID10" AS geo_id
FROM phl_pwd_parcels
JOIN census_block_groups
ON ST_Contains(
    census_block_groups.geometry,
    phl_pwd_parcels.geometry
)
WHERE 
    phl_pwd_parcels."OWNER1" LIKE '%TRUSTEES OF THE UNIVERSIT%' AND
    phl_pwd_parcels."ADDRESS" LIKE '%3400-04 WALNUT ST%'