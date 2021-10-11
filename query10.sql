/**
10. You're tasked with giving more contextual information to rail stops 
to fill the `stop_desc` field in a GTFS feed. Using any of the data sets above, 
PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), and PostgreSQL string functions, 
build a description (alias as `stop_desc`) for each stop. Feel free to supplement with other 
datasets (must provide link to data used so it's reproducible), and other methods of describing 
the relationships. PostgreSQL's `CASE` statements may be helpful for some operations.

  **Structure:**
  ```sql
  (
      stop_id integer,
      stop_name text,
      stop_desc text,
      stop_lon double precision,
      stop_lat double precision
  )
  ```

  As an example, your `stop_desc` for a station stop may be something like "37 meters NE 
  of 1234 Market St" (that's only an example, feel free to be creative, silly, descriptive, etc.)
**/

/** 
    I imported Philadelphia Trees data and I am going to 
    create a description for each rail stop by describing how many
    trees are within 400m from the stop!
**/

with septa_rail_stops_geom as (
	select stop_id, stop_name, stop_lat, stop_lon, ST_SetSRID(ST_Point(stop_lon, stop_lat),4326) AS geometry
	from septa_rail_stops
) 
select stop_id, stop_name, CONCAT('There are ', count(t."OBJECTID"), ' trees near this station') AS stop_desc, stop_lon, stop_lat
from phl_trees as t
right join septa_rail_stops_geom as r
on ST_DWithin(ST_Transform(r.geometry,32129), ST_Transform(t.geometry,32129),400)
group by stop_id, stop_name, stop_lat, stop_lon