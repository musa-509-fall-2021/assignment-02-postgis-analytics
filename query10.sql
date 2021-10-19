/*
	You're tasked with giving more contextual information to rail stops to fill the stop_desc field 
	in a GTFS feed. 
	Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), 
	and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. 
	Feel free to supplement with other datasets (must provide link to data used so it's reproducible), 
	and other methods of describing the relationships. 
	PostgreSQL's CASE statements may be helpful for some operations.

	Structure:
	
	(
    stop_id integer,
    stop_name text,
    stop_desc text,
    stop_lon double precision,
    stop_lat double precision
	)
*/

/*
	I selected shooting data and police station data from OpenDataPhilly.
	These data are used to evaluate the safety level of each rail station.
	The more shooting victioms are, the more dangerous a station is.
	The more police stations are in a reachable distance, the safer a station is.
*/

ALTER TABLE shootings_2020
ADD the_geom geometry;
UPDATE shootings_2020
set the_geom = st_transform(st_setsrid(st_makepoint(point_x, point_y), 4326),32129);

with shooting_numbers as (
	select  rs.stop_name, count(sh.gid) as shooting_nums
	from shootings_2020 as sh
	join septa_rail_stops as rs
	on st_dwithin(st_transform(sh.the_geom, 32129), st_transform(rs.geom, 32129), 1000)
	group by rs.stop_name
),
police_numbers as (
	select rs.stop_name, count(pl.gid) as police_nums
	from police_stations as pl
	join septa_rail_stops as rs
	on st_dwithin(st_transform(pl.geom, 32129), st_transform(rs.geom, 32129), 5000)
	group by rs.stop_name
),
stops_with_numbers as (
	select sn.*, pn.police_nums
	from shooting_numbers as sn
	join police_numbers as pn
	on pn.stop_name = sn.stop_name
)

select rs.stop_id, sn.stop_name, rs.stop_lon, rs.stop_lat, 
case
	when sn.shooting_nums is null or sn.shooting_nums = 0 then 'very safe'
	when sn.shooting_nums>0 and sn.shooting_nums<20 and sn.police_nums>0 then 'safe'
	when sn.shooting_nums>0 and sn.shooting_nums<20 and sn.police_nums=0 then 'medium-safe'
	when sn.shooting_nums>=20 and sn.shooting_nums<100 and sn.police_nums>0 then 'medium-dangerous'
	when sn.shooting_nums>=20 and sn.shooting_nums<100 and sn.police_nums=0 then 'dangerous'
	when sn.shooting_nums>=100 then 'very dangerdous'
end as stop_desc
from stops_with_numbers as sn
right join septa_rail_stops as rs
on rs.stop_name = sn.stop_name




