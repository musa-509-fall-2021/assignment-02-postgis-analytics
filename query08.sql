with buffered_school as (
    SELECT st_union(st_buffer(the_geom,80)) g
    from university_phl
    where name='University of Pennsylvania'
)
select count(*) count_block_groups
from buffered_school b
join census_block_groups c
on ST_Contains(b.g,c.the_geom)