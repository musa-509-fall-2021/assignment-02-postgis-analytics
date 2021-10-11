/**
8. With a query, find out how many census block groups Penn's main campus fully contains. 
Discuss which dataset you chose for defining Penn's campus.

  **Structure (should be a single value):**
  ```sql
  (
      count_block_groups integer
  )
  ```
**/

CREATE INDEX parcels_adr_idx ON phl_pwd_parcels("ADDRESS");
CREATE INDEX parcels_ownr1_idx ON phl_pwd_parcels("OWNER1");
CREATE INDEX parcels_ownr2_idx ON phl_pwd_parcels("OWNER2");

with university_city as (
	SELECT * FROM neighborhoods_philadelphia AS n WHERE n."NAME" = 'UNIVERSITY_CITY'
), penn_pwd_parcels as (
	SELECT p."OWNER1" as owner1, p."OWNER2" as owner2, p."geometry" as geometry
	FROM phl_pwd_parcels as p
	JOIN university_city as c
	ON ST_Intersects(ST_Transform(c.geometry, 32129), ST_Transform(p.geometry, 32129))
	WHERE p."OWNER1" LIKE '%PENN%'
), uc_block_groups as (
	SELECT b.geoid10 as geoid, b.geometry as geometry
	FROM census_block_groups as b
	JOIN university_city as c
	ON ST_Intersects(ST_Transform(c.geometry, 32129), ST_Transform(b.geometry, 32129))
)
SELECT COUNT(DISTINCT geoid) as count_block_groups
FROM uc_block_groups as ucbg
JOIN penn_pwd_parcels as ppp
ON ST_Intersects(ST_Transform(ucbg.geometry, 32129), ST_Transform(ppp.geometry, 32129))
