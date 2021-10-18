/*
  You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed.
  Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string
  functions, build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets
  (must provide link to data used so it's reproducible), and other methods of describing the relationships.
  PostgreSQL's CASE statements may be helpful for some operations.
*/

alter table septa_rail_stops
	add column the_geom geometry(Geometry, 32129);

UPDATE septa_rail_stops
    set the_geom = st_transform(st_setsrid(st_makepoint(stop_lon, stop_lat), 4326), 32129);

create index septa_rail_stops__the_geom__32129__idx
    on septa_rail_stops
    using GiST (ST_Transform(the_geom, 32129));

with septa_rail_stops_crime as (
    select
        r.stop_id,
        count(cr.gid) as crime_number
    from septa_rail_stops as r
    join crime as cr
        on ST_DWithin(
            ST_Transform(r.the_geom, 32129),
            ST_Transform(st_setsrid(cr.the_geom,4326), 32129),
            500
        )
	group by r.stop_id
),

septa_rail_stop_crime_number as (
    select
        r.stop_id,
		rc.crime_number,
		r.stop_name,
        cast(r.stop_desc as text),
		r.stop_lon,
		r.stop_lat
    from septa_rail_stops as r
    left join septa_rail_stops_crime as rc using (stop_id)
)

select
    stop_id,
	stop_name,
	stop_lon,
	stop_lat,
		case 
		when crime_number is NULL then 'The stop is very safe'
		when crime_number<=300 then 'The stop is safe'
		when crime_number>300 and crime_number<=1200 then 'The stop is a bit unsafe'
		when crime_number>1200 then 'The stop is very unsafe'
		end as stop_desc
from septa_rail_stop_crime_number

/*Result: Crime data is from OpenDataPhilly https://opendataphilly.org/dataset/crime-incidents/resource/3a3fa82b-634d-464c-ad4c-7d6f0d23657d.
stop_id    stop_name                 stop_lon           stop_lat          stop_desc
90001      "Cynwyd"	                 -75.2316667	    40.0066667	      "The stop is very safe"
90002	   "Bala"	                 -75.2277778	    40.0011111	      "The stop is safe"
90003	   "Wynnefield Avenue"	     -75.2255556	    39.99	          "The stop is safe"
90004	   "30th Street Station"	 -75.1816667	    39.9566667	      "The stop is safe"
90005	   "Suburban Station"	     -75.1677778	    39.9538889        "The stop is very unsafe"
...        ...                       ...                ...               ...
...        ...                       ...                ...               ...
...        ...                       ...                ...               ...
