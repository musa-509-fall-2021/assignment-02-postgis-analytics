/*
You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. PostgreSQL's CASE statements may be helpful for some operations.

As an example, your stop_desc for a station stop may be something like "37 meters NE of 1234 Market St" (that's only an example, feel free to be creative, silly, descriptive, etc.)

Tip when experimenting: Use subqueries to limit your query to just a few rows to keep query times faster. Once your query is giving you answers you want, scale it up. E.g., instead of FROM tablename, use FROM (SELECT * FROM tablename limit 10) as t.
*/


/*
Stop Description:
Distance to nearest Wawa

Explanation:
Perform a lateral join between septa_rail_stops and Wawa locations dataset (available online and uploaded to this repo) to determine the distance from each rail stop to the nearest Wawa location.
*/

WITH nearest_wawa AS (
    SELECT
        septa_rail_stops.*,
        ST_Distance(geography(wawalocations_2017.geometry), geography(septa_rail_stops.the_geom)) AS distance
    FROM
      septa_rail_stops
    CROSS JOIN LATERAL
      (SELECT geometry
       FROM wawalocations_2017
       ORDER BY
         septa_rail_stops.the_geom <-> wawalocations_2017.geometry
       LIMIT 1) AS wawalocations_2017)

SELECT
    stop_id,
    stop_name,
    distance AS stop_desc,
    stop_lon,
    stop_lat
FROM nearest_wawa