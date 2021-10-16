/*
With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus
*/

/* I downloaded 'Universities_Colleges-shp' from OpenDataPhilly.
The first step of this query is making dataset that I use contains only information of Upenn
*/

update university
	set geom = st_transform(st_setsrid(geom,2272),4326)

select count(*) as count_block_groups
from (
	select geoid10
  from (
		select *
		from university
		where name = 'University of Pennsylvania'
			) as u
	join census_block_groups c
	on st_within(u.geom,c.geom)
	group by geoid10
    ) as d

/* 23
*/
