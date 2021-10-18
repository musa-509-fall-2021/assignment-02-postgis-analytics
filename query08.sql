/*
  With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset
  you chose for defining Penn's campus.
*/

with upenn as(
	select name, st_buffer(st_transform(st_setsrid(st_union(the_geom),4326),32129),100) as the_geom
	from university
	where name='University of Pennsylvania' 
	group by name
)

select count(*) as count_block_groups
from census_block_groups as b
join upenn as u
on st_within(b.the_geom, st_transform(u.the_geom, 4326))

/*Result: 3
The UPenn's dataset is a shapefile from OpenDataPhilly called "Philadelphia Universities and Colleges".