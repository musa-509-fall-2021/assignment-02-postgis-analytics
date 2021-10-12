-- 9. With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall. 
-- ST_MakePoint() and functions like that are not allowed.

--   **Structure (should be a single value):**
--   ```sql
--   (
--       geo_id text
--   )
--   ```
with meyerson as (
	select *
	from pwd_parcels
	where address = '220-30 S 34TH ST' and owner1 like '%UNIV%'
)

select geoid10 as geo_id
from census_block_groups bg, meyerson
where st_contains(bg.the_geom, meyerson.the_geom)
	
