/*
With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.
*/


/*
Explanation:
The Philadelphia Water Department Stormwater Billing Parcels' dataset was used to define Penn's main campus by filtering for parcels owned by "TRUSTEES OF THE UNIVERSIT," using a combination of the WHERE and LIKE functions. To count the block groups contained within that defined area, the ST_Contains function was used to identify the block groups that fall within Penn's main campus, which were then added together using the COUNT function.
*/


SELECT COUNT(*) AS count_block_groups
FROM phl_pwd_parcels
JOIN census_block_groups
ON ST_Contains(
    census_block_groups.geometry,
    phl_pwd_parcels.geometry
)
WHERE phl_pwd_parcels."OWNER1" LIKE '%TRUSTEES OF THE UNIVERSIT%'