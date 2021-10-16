/*
Rate neighborhoods by their bus stop accessibility for wheelchairs.
Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed.
Use the [GTFS documentation](https://gtfs.org/reference/static/) for help.
Use some creativity in the metric you devise in rating neighborhoods. Describe your accessibility metric:
*/

/* Metrics Description:
In this qury I used 'neighborhoods_philadelphia' as neighborhood dataset(downloaded from OpenDataPhilly),
                    'septa_bus_stops' as accessibility information about the stop
Fisrt, I calculate the supply-demand ratio (uppose larger the area, more the demands for mobility) Using
1. number(stops)/area(neighborhood)
Then, the propotion of accessible stops(stops with wheelchairs boarding) is also important
2. number(accessible stops)/number(unaccessibel stops)
Since meeting the demands is the foundamatal element for accessibility, here I use the weighted sum of these two indicators above
final rating='1'*0.6+'2'*0.4 --this is an arbitrary distribution. In a more rigorous study, we should use professional statistical methods to determine the weight,
                  for example, AHP, the expert scoring method, etc.
*/

update neighborhoods_philadelphia
	set geom = st_transform(st_setsrid(geom,2272),4326)


with stop_info as(
		select
		sum(wheelchair_boarding) as num_wb,
		count(*) filter(where wheelchair_boarding in (1,2)) as num_bus_stops_accessible,
	    count(*) filter(where wheelchair_boarding = 0) as num_bus_stops_inaccessible,
		name as neighborhood,
		count(*) as num_stop
		from septa_bus_stops s
		join neighborhoods_philadelphia n
		on st_contains(n.geom,s.the_geom)
		group by neighborhood),

	neigh_info as (
		select shape_area,
		name
		from neighborhoods_philadelphia),


	all_info as (select *
		from stop_info s
		join neigh_info n
		on s.neighborhood=n.name)

select
		num_bus_stops_accessible,
		num_bus_stops_inaccessible,
		round((num_stop/shape_area*1000000)*0.6+(100*num_wb/num_stop)*0.4,2) as accessibility_metric,
		neighborhood as neighborhood_name
from all_info
order by accessibility_metric desc


/* according to the rating, Bartram_village has the most accessible bus system(rating:80.57)
Pennypack_woods needs to improve the accessibility of their bus system(rating:32.89)

However, other metrics still need to be considered, for example: the spatial distribution of the bus stop,
do they cluster in space?(indicate that they are not evenly distribute, certain of the neighborhood may have more accessibility compare to others),
and this spatial character should be negatively correlated with the rating.
