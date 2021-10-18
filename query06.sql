/*
  What are the top five neighborhoods according to your accessibility metric?
*/

create index neighborhoods__the_geom__32129__idx
    on neighborhoods
    using GiST (ST_Transform(st_setsrid(n.the_geom,2272), 32129));


with septa_bus_stop_wheelchair as(
	select the_geom, cast(wheelchair_boarding=
		case
		when wheelchair_boarding=0 then 0
		when wheelchair_boarding=1 then 1
		when wheelchair_boarding=2 then 0
		end as int) as wc
	from septa_bus_stops
)

select
	n.name,
    sum(s.wc) as metric
from septa_bus_stop_wheelchair as s
join neighborhoods as n
on st_within(s.the_geom,st_transform(st_setsrid(n.the_geom,2272), 32129)) 
group by name
order by metric desc
limit 5

/*Result: 
name       metric
OVERBROOK  177
OLNEY      172
BUSTLETON  155
SOMERTON   151
MAYFAIR    138