/*
In the stop_desc column, I provide the ditance and orientation of the nearest indego bike station. It can help transit riders to find the nearest indego bike station after getting off the railway, solving the problem of 'a last mile'. 
*/



create index septa_rail_stops__the_geom__32129__idx
    on septa_rail_stops
    using GiST (st_transform(the_geom, 32129));

with joined as (select s.stop_id,
		s.stop_name,
		s.the_geom,
		i.id,
		i.name,
		i.geom
	from septa_rail_stops as s
	cross join indego_station as i)
	
, all_distance as (select stop_name,
				   		id,
						name,
				   		geom,
				        the_geom,
					st_distance(st_transform(geom,32129),st_transform(the_geom,32129))as distance
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
			a.id,
			a.geom,
			a.the_geom,
			degrees(ST_Azimuth(a.geom, a.the_geom)) as deg
	from min_distance as m
	join all_distance as a
		on m.stop_name = a.stop_name and m.distance_m = a.distance )


, deg_desc as(select *,
			case  when deg > 0 and deg < 90 then 'northeast'
				  when deg > 90 and deg < 180 then 'southeast'
				  when deg > 180 and deg < 270 then 'southwest'
				  else 'northwest'
			end as deg_desc
	from indego_rail)
	
select  s.stop_id,
		d.stop_name,
		(round(cast(d.distance_m as numeric)))::text||' meters '||d.deg_desc||' of '||d.name||d.id as stop_desc,
		s.stop_lon,
		s.stop_lat
from deg_desc as d
join septa_rail_stops as s 
	on d.stop_name = s.stop_name
	

/*
example result
stop_id   stop_name        stop_desc                                      stop_lon    stop_lat
90009     Wayne Junction   3836 meters northeast of 29th & Dauphin3096    -75.16      40.022
*/
