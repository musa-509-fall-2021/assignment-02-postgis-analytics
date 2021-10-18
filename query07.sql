/*
  What are the bottom five neighborhoods according to your accessibility metric?
*/

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
order by metric asc
limit 5

/*Result: 
name              metric
BARTRAM_VILLAGE   0
CRESTMONT_FARMS   1
WEST_TORRESDALE   1
PORT_RICHMOND     2
WISSAHICKON_HILLS 2