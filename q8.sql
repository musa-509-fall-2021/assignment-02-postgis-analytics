/*
I find Universities and Colleges (SHP) from OpenDataPhilly website.
*/

with upenn as (
	select * from universities
	where name = 'University of Pennsylvania'
),

upenn_census as (
	select cb.geoid10,u.name
	from census_block_groups as cb
	join upenn as u
	on ST_Contains(ST_SetSRID(cb.geom,4326),u.geom))

select count(*) as num_census
from upenn_census