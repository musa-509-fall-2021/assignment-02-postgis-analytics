with joined as (select s.stop_id,
		s.stop_name,
		s.the_geom,
		i.id,
		i.name,
		i.geom
	from septa_rail_stops as s
	cross join indego_station as i)
	
, all_distance as (select stop_name,
						name,
				   		geom,
				        the_geom,
					st_distance(st_transform(geom,32129),st_transform(the_geom,32129)) as distance
					from joined)
				
, min_distance as (
	select stop_name, 
	min(st_distance(st_transform(geom,32129),st_transform(the_geom,32129))) as distance_m
	from joined
	group by 1)
	
, indego_rail as (
	select m.stop_name,
			m.distance_m,
			a.name,
			a.geom,
			a.the_geom
	from min_distance as m
	join all_distance as a
		on m.stop_name = a.stop_name and m.distance_m = a.distance )

, deg_all as (
	SELECT *,degrees(ST_Azimuth(the_geom, geom)) AS deg
	from indego_rail)

select if(deg > 0 and deg < 90,'Northeast', 
			   if(deg > 90 and deg < 180,'Southeast',
				 if(deg > 180 and deg < 270,'Southwest','Northwest')))
from deg_all
