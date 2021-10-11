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
	select * from neighborhoods_philadelphia as n where n."NAME" = 'UNIVERSITY_CITY'
), penn_pwd_parcels as (
	select p."OWNER1" as owner1, p."OWNER2" as owner2, p."geometry" as geometry
	from phl_pwd_parcels as p
	join university_city as c
	on ST_Intersects(ST_Transform(c.geometry, 32129), ST_Transform(p.geometry, 32129))
	where p."OWNER1" LIKE '%PENN%'
), penn_pwd_parcels_union as (
	select ST_Envelope(ST_Union(p.geometry)) as geometry
	from penn_pwd_parcels as p
), uc_block_groups as (
	select b.geoid10 as geoid, b.geometry as geometry
	from census_block_groups as b
	join university_city as c
	on ST_Intersects(ST_Transform(c.geometry, 32129), ST_Transform(b.geometry, 32129))
) 
select COUNT(DISTINCT geoid) as count_block_groups
from uc_block_groups as ucbg
join penn_pwd_parcels_union as pppu
on ST_Intersects(ST_Transform(ucbg.geometry, 32129), ST_Transform(pppu.geometry, 32129))