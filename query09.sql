/* 9. With a query involving PWD parcels and census block groups, 
find the geo_id of the block group that contains Meyerson Hall. 
ST_MakePoint() and functions like that are not allowed. */

with meyerson as (
SELECT *
FROM pwd_parcels
WHERE address LIKE '%30 S 34%'
	), 
	
census as (
SELECT geoid10 , ST_transform(the_geom, 32129) as cengeom
FROM census_block_groups
)
SELECT geoid10
FROM census as c
JOIN meyerson as m 
on St_intersects (c.cengeom, m.geom)

/* RESULT: "421010369001" */