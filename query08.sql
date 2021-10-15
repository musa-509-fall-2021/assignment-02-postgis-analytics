/*
  I choose "Philadelphia Universities and Colleges" dataset,
  https://www.opendataphilly.org/dataset/philadelphia-universities-and-colleges/resource/1e37f5f0-6212-4cb4-9d87-261b58ae01c4 
  adding a buffer of 80m and union the polygons. The result census block groups fully contained is 3.
*/

with buffered_school as (
    SELECT st_union(st_buffer(the_geom,80)) g
    from university_phl
    where name='University of Pennsylvania'
)
select count(*) count_block_groups
from buffered_school b
join census_block_groups c
on ST_Contains(b.g,c.the_geom)