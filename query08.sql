/*
data source: https://opendataphilly.org/dataset/philadelphia-universities-and-colleges
query9: With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.
*/


select count(*) as count_block_groups
from (
	select c.geoid10,c.geom
	from (
		select *
		from university 
		where NAME = 'University of Pennsylvania') as u
	join census_block_groups as c
		on st_contains(st_setsrid(c.geom,4326),u.geom)
	) as joined


/*
count_block_groups
191
*/
