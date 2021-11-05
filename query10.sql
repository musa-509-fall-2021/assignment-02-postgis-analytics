/*
You're tasked with giving more contextual information to rail stops to fill the
stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS
functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions,
build a description (alias as stop_desc) for each stop. Feel free to supplement
with other datasets (must provide link to data used so it's reproducible), and
other methods of describing the relationships. PostgreSQL's CASE statements
may be helpful for some operations.
*/


   stop_id integer,
   stop_name text,
   stop_desc text,
   stop_lon double precision,
   stop_lat double precision

/*I use the neighborhoods in shp file in query 06.and describing the stop_desc with
the neighborhood the bus stop located in */
   select stop_id,stop_name,"NAME" as stop_desc,stop_lon,stop_lat
   from septa_rail_stops a
   join neighborhoods b
   	on st_contains(ST_Transform(b.the_geom, 32129),ST_Transform(a.the_geom, 32129))
