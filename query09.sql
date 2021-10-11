/**
9. With a query involving PWD parcels and census block groups, find the `geo_id` of the block 
group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.

  **Structure (should be a single value):**
  ```sql
  (
      geo_id text
  )
  ```
**/

with university_city as (
	SELECT * FROM neighborhoods_philadelphia AS n WHERE n."NAME" = 'UNIVERSITY_CITY'
), penn_pwd_parcels as (
	SELECT p."ADDRESS" as address, p."OWNER1" as owner1, p."OWNER2" as owner2, p."geometry" as geometry
	FROM phl_pwd_parcels as p
	JOIN university_city as c
	ON ST_Intersects(ST_Transform(c.geometry, 32129), ST_Transform(p.geometry, 32129))
	WHERE p."OWNER1" LIKE '%PENN%'
), uc_block_groups as (
	SELECT b.geoid10 as geoid, b.geometry as geometry
	FROM census_block_groups as b
	JOIN university_city as c
	ON ST_Intersects(ST_Transform(c.geometry, 32129), ST_Transform(b.geometry, 32129))
) SELECT geoid AS geo_id
FROM penn_pwd_parcels AS p
JOIN uc_block_groups AS b
ON ST_Intersects(ST_Transform(p.geometry, 32129), ST_Transform(b.geometry, 32129))
WHERE p.address LIKE '%221 S 34TH ST%'

/*

I could not find 210 S 34TH ST IN THE PARCELS DATABASE BUT I DID FIND

 > 176647,240564,8847000221,221 S 34TH ST,TRS UNIV OF PENN,,VC0,SCHOOL 3STY MASONRY,773588500,1,6,134212,21242.921875,615.733890598117

This is really close to Meyerson but in a different block group (421010369001) which is what the query returns.
CHECKING VIA CARTO, MEYERSON IS ACTUALLY IN THE `421010087012` BLOCK GROUP
`
