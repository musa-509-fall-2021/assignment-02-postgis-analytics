/*
	With a query, find out how many census block groups Penn's main campus fully contains. 
	Discuss which dataset you chose for defining Penn's campus.
	
	Structure:
	
	(
    count_block_groups integer
	)
*/
/* 
Penn campus data from OpenDataPhilly (https://www.opendataphilly.org/dataset/philadelphia-universities-and-colleges)
Imported as .shp
Table name: universities
*/

with penn_campus as (
	select st_buffer(st_union(st_transform(geom, 32129)), 100) as penn
	from universities
	where name = 'University of Pennsylvania'
)

select count(bg.geoid10) as count_block_groups
from census_block_groups as bg
join penn_campus
on st_within(ST_Transform(bg.geom, 32129), ST_Transform(penn_campus.penn, 32129))

/*
count_block_groups	3
*/