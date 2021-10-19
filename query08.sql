-- 8. With a query, find out how many census block groups Penn's main campus fully contains. 
-- Discuss which dataset you chose for defining Penn's campus.

--   **Structure (should be a single value):**
--   ```sql
--   (
--       count_block_groups integer
--   )
--   ```
-- While rather arduous, I chose to identify Penn's campus through the parcel dataset.
-- Specifically, I subsetted the data by identifying parcels owned by the university 
-- and then further subsetted those parcels that were on streets associated with the main campus.
-- This method does include some smaller parcels, presumably houses owned by the college.
-- However I made the decision to include them because they were close enough to the core of campus.

with upennProp as (
	select *
	from pwd_parcels
	where ((owner1 LIKE '%TRUSTEES OF%' AND (owner2 LIKE '%PENN%' OR owner2 LIKE '%PA%')) 
			 OR owner1 LIKE 'TRUSTEES OF THE UNIV%'
			 OR owner1 LIKE 'TRS UNIV OF PENN' OR owner1 LIKE 'TRS UNIV PENN'
			 OR owner1 LIKE '%UNIVERSITY OF PEN%'
			 OR owner1 LIKE '%U OF P%'
			 AND owner1 NOT LIKE '%STATE%'
		)
	 AND (address LIKE '%MARKET%' OR address LIKE '%WALNUT%'
		  OR address LIKE '%CHESTNUT%' OR address LIKE '%LOCUST%'
		  OR address LIKE '%SPRUCE%' OR address LIKE '%UNIVERSITY%'
		  OR address LIKE '%PINE%' OR address LIKE '%DELANCEY%'
		  OR address LIKE '%BALTIMORE%'
		  OR address LIKE '%30TH%' OR address LIKE '%32ND%'
		  OR address LIKE '%33RD%' OR address LIKE '%34TH%'
		  OR address LIKE '%39TH%' OR address LIKE '40TH%'
		 )
	-- remove outlying parcels
	AND (address NOT LIKE '4114 SPRUCE%' AND address NOT LIKE '4431 SPRUCE%' 
		 AND address NOT LIKE '4625 SPRUCE%' AND address NOT LIKE '127-29%'
		)
), upennGeneralizedCampus as (
	select st_ConvexHull(st_union(up.the_geom)) as the_geom
	from upennProp up
), campusDividedBG as (
	select bg.geoid10, st_intersection(bg.the_geom, upgc.the_geom) as the_geom
	from census_block_groups bg, upennGeneralizedCampus upgc
)

select count(distinct(bg.the_geom)) as count_block_groups
from census_block_groups bg
join campusDividedBG cdbg
on st_contains(bg.the_geom, cdbg.the_geom)

