/*
data source: https://opendataphilly.org/dataset/philadelphia-universities-and-colleges

*/


with upenn as (
	select *
	from university 
	where NAME = 'University of Pennsylvania')
	, joined as (
	select c.geoid10,c.geom
	from upenn as u
	join census_block_groups as c
		on st_contains(st_setsrid(c.geom,4326),u.geom)
	)

select count(*)
from joined
