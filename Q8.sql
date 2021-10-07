/*8. With a query,
find out how many census block groups Penn's main campus fully contains. 
Discuss which dataset you chose for defining Penn's campus.

ANSWER:I choose Philadelphia Universities and Colleges (shp) from OpenDataPhilly and set 50m buffer around UPenn. 
There is one census block groups Penn's main campus fully contains.
*/
ALTER TABLE universities
ADD COLUMN the_geom geometry;

update universities
set the_geom = st_transform(geometry,32129);

with upenn_buffer as
(
	select st_union(st_buffer(the_geom,50)) as union
	from universities
	where name='University of Pennsylvania'
)

select count(*) as count_block_groups
from census_block_groups a 
join upenn_buffer b  
on st_contains(b.union, a.geom)

