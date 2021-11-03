/*With a query, find out how many census block groups Penn's main campus
fully contains. Discuss which dataset you chose for defining Penn's campus.*/

/*I choose the shpfile of university in philadelphia from OpenDataPhilly and filter out
Upenn to define Penn's campus.*/

alter table university
	add column the_geom geometry(Geometry, 32129);

update university
	set the_geom = ST_Transform(geometry,32129);

select *
	FROM university
	where name LIKE '%of Penn%'


with penn as(
  select *
  	FROM university
  	where name LIKE '%of Penn%'
  	),

whole_campus as(
  	select st_ConvexHull(st_union(ST_Transform(penn.the_geom, 32129))) as the_geom
  	from penn
  )

select count (*) as count_block_groups
  	from census_block_groups a
  	join whole_campus b
  	on st_contains(b.the_geom,ST_Transform(a.the_geom, 32129))
