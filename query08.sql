/*
data source: https://opendataphilly.org/dataset/philadelphia-universities-and-colleges
query8: With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.
*/

create index university__the_geom__32129__idx
    on university
    using GiST (st_transform(geom, 32129))

with main_campus as(select st_union(st_buffer(st_transform(geom,32129),200)) as geom
from university
where name = 'University of Pennsylvania')

select count(*) as count_block_groups
from (
	select c.geoid10,c.geom
	from (
		select *
		from main_campus) as m
	join census_block_groups as c
		on st_contains(st_transform(m.geom,4326),st_setsrid(c.geom,4326))
	) as joined

/*
count_block_groups
9
*/
