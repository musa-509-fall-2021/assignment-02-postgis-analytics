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
	select * from neighborhoods_philadelphia as n where n."NAME" = 'UNIVERSITY_CITY'
), penn_pwd_parcels as (
	select p."ADDRESS" as address, p."OWNER1" as owner1, p."OWNER2" as owner2, p."geometry" as geometry
	from phl_pwd_parcels as p
	join university_city as c
	on ST_Intersects(ST_Transform(c.geometry, 32129), ST_Transform(p.geometry, 32129))
	where p."OWNER1" LIKE '%PENN%'
), uc_block_groups as (
	select b.geoid10 as geoid, b.geometry as geometry
	from census_block_groups as b
	join university_city as c
	on ST_Intersects(ST_Transform(c.geometry, 32129), ST_Transform(b.geometry, 32129))
)
select geoid as geo_id
from penn_pwd_parcels as p
join uc_block_groups as b
on ST_Intersects(ST_Transform(p.geometry, 32129), ST_Transform(b.geometry, 32129))
where p.address like '%221 S 34TH ST%'

/*

I could not find 210 S 34TH ST IN THE PARCELS DATABASE BUT I DID FIND

 > 176647,240564,8847000221,221 S 34TH ST,TRS UNIV OF PENN,,VC0,SCHOOL 3STY MASONRY,773588500,1,6,134212,21242.921875,615.733890598117

This is really close to Meyerson but in a different block group (421010369001) which is what the query returns.
CHECKING VIA CARTO, MEYERSON IS ACTUALLY IN THE `421010087012` BLOCK GROUP
`
