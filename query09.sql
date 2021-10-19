/*
	With a query involving PWD parcels and census block groups, 
	find the geo_id of the block group that contains Meyerson Hall. 
	ST_MakePoint() and functions like that are not allowed.
	
	Structure:
	
	(
    geo_id text
	)
*/
with parcel_in_blocks as(
	select p.parcelid, p.address, p.geom, bg.geoid10
	from phl_pwd_parcels as p
	join census_block_groups as bg
	on ST_within(ST_Transform(p.geom, 32129),
            	 ST_Transform(bg.geom, 32129))
)
select geoid10
from parcel_in_blocks
where address = '220-30 S 34TH ST'

/*
Query Result:
421010369001
*/