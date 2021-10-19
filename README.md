# Assignment 02: PostGIS Analytics

**Due: Oct 18, 2021 by 11:59pm ET**

## Submission Instructions

1. Fork this repository to your GitHub account.

2. Write a query to answer each of the questions below. Your queries should produce results in the format specified. Write your query in a SQL file corresponding to the question number (e.g. a file named _query06.sql_ for the answer to question #6). Each SQL file should contain a single `SELECT` query (though it may include other queries before the select if you need to do things like create indexes or update columns). Some questions include a request for you to discuss your methods. Update this README file with your answers in the appropriate place.

3. There are several datasets that are prescribed for you to use in this assignment. Your datasets should be named:
  * septa_bus_stops ([SEPTA GTFS](http://www3.septa.org/developer/))
  * septa_bus_shapes ([SEPTA GTFS](http://www3.septa.org/developer/))
  * septa_rail_stops ([SEPTA GTFS](http://www3.septa.org/developer/))
  * phl_pwd_parcels ([OpenDataPhilly](https://opendataphilly.org/dataset/pwd-stormwater-billing-parcels))
  * census_block_groups ([OpenDataPhilly](https://opendataphilly.org/dataset/census-block-groups))
  * census_population ([Census Explorer](https://data.census.gov/cedsci/table?t=Populations%20and%20People&g=0500000US42101%241500000&y=2010&d=DEC%20Summary%20File%201&tid=DECENNIALSF12010.P1))

4. Submit a pull request with your answers. You can continue to push changes to your repository up until the due date, and those changes will be visible in your pull request.

**Note, I take logic for solving problems into account when grading. When in doubt, write your thinking for solving the problem even if you aren't able to get a full response.**

## Questions

1. Which bus stop has the largest population within 800 meters? As a rough estimation, consider any block group that intersects the buffer as being part of the 800 meter buffer.

Passyunk & 15th Ave

with septa_bus_stop_block_groups as (
   select
       s.stop_id,
       '1500000US' || bg.geoid10 as geo_id
   from septa_bus_stops as s
   join census_block_groups_2010 as bg
       on ST_DWithin(
           ST_Transform(s.geom, 32129),
           ST_Transform(bg.geom, 32129),
           800
       )
),

septa_bus_stop_surrounding_population as (

   select
       stop_id,
       sum(p001001) as estimated_pop_800m
   from septa_bus_stop_block_groups as s
   join census_population as p using (geo_id)
   group by stop_id
)

select
   stop_name,
   estimated_pop_800m,
   geom
from septa_bus_stop_surrounding_population
join septa_bus_stops using (stop_id)
order by estimated_pop_800m desc
limit 1;

2. Which bus stop has the smallest population within 800 meters?

Charter & Norcom

with septa_bus_stop_block_groups as (
   select
       s.stop_id,
       '1500000US' || bg.geoid10 as geo_id
   from septa_bus_stops as s
   join census_block_groups_2010 as bg
       on ST_DWithin(
           ST_Transform(s.geom, 32129),
           ST_Transform(bg.geom, 32129),
           800
       )
),

septa_bus_stop_surrounding_population as (

   select
       stop_id,
       sum(p001001) as estimated_pop_800m
   from septa_bus_stop_block_groups as s
   join census_population as p using (geo_id)
   group by stop_id
)

select
   stop_name,
   estimated_pop_800m,
   geom
from septa_bus_stop_surrounding_population
join septa_bus_stops using (stop_id)
order by estimated_pop_800m asc
limit 1;

3. Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).

Logic:
- This one I'm less clear on, but would be most inclied to start by making centroids of each parcel
- Next, I would see if a nearest neighbor function exists in SQL to join the centroid to its nearest neighbor
- I would want my query to select the parcel address, bus stop name, and distance apart in meters and be in descending order

4. Using the _shapes.txt_ file from GTFS bus feed, find the **two** routes with the longest trips. In the final query, give the `trip_headsign` that corresponds to the `shape_id` of this route and the length of the trip.

 Logic:
 - First would use ST_Makeline to make lines based off of the endpoints of the route
 - Next I would measure the length of those lines
 - Finally, I would sort the resulting list in descending orden and limit by two 

**5. Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the metric you devise in rating neighborhoods. Describe your accessibility metric:

SELECT
  count(*) AS stop_count,
  count(*) filter(where stops.wheelchair_boarding = 1) AS accessible_stops,
  neighborhoods.name AS neighborhood_name
FROM neighborhoods_philadelphia AS neighborhoods
LEFT JOIN septa_bus_stops AS stops
ON ST_Contains(ST_Transform(ST_Setsrid(neighborhoods.geom, 2272), 4326), stops.geom)
GROUP BY neighborhood_name
ORDER BY accessible_stops desc;

  **Description:**

**6. What are the _top five_ neighborhoods according to your accessibility metric?

SELECT
  count(*) AS stop_count,
  count(*) filter(where stops.wheelchair_boarding = 1) AS accessible_stops,
  neighborhoods.name AS neighborhood_name
FROM neighborhoods_philadelphia AS neighborhoods
LEFT JOIN septa_bus_stops AS stops
ON ST_Contains(ST_Transform(ST_Setsrid(neighborhoods.geom, 2272), 4326), stops.geom)
GROUP BY neighborhood_name
ORDER BY accessible_stops desc
LIMIT 5;

**7. What are the _bottom five_ neighborhoods according to your accessibility metric?

SELECT
  count(*) AS stop_count,
  count(*) filter(where stops.wheelchair_boarding = 1) AS accessible_stops,
  neighborhoods.name AS neighborhood_name
FROM neighborhoods_philadelphia AS neighborhoods
LEFT JOIN septa_bus_stops AS stops
ON ST_Contains(ST_Transform(ST_Setsrid(neighborhoods.geom, 2272), 4326), stops.geom)
GROUP BY neighborhood_name
ORDER BY accessible_stops asc
LIMIT 5;


8. With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.

Logic:
- First would use parcel data to define Penn's campus via ownership 
- Next, would use ST_Contains to determine how many of the block groups are within the areas defined as campus
- Finally I would want my select statement to count * (and would possibly need to GROUP BY ownership so that the count works)
  ```

**9. With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.

SELECT p.address, bg.geoid10
FROM pwd_parcels AS p
JOIN census_block_groups_2010 AS bg
ON ST_Contains(bg.geom, ST_SetSRID(p.geom, 4326))
WHERE p.address = '220-30 S 34TH ST';

421010369001
  ```

10. You're tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), and PostgreSQL string functions, build a description (alias as `stop_desc`) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. PostgreSQL's `CASE` statements may be helpful for some operations.


  ```

  As an example, your `stop_desc` for a station stop may be something like "37 meters NE of 1234 Market St" (that's only an example, feel free to be creative, silly, descriptive, etc.)

  **Tip when experimenting:** Use subqueries to limit your query to just a few rows to keep query times faster. Once your query is giving you answers you want, scale it up. E.g., instead of `FROM tablename`, use `FROM (SELECT * FROM tablename limit 10) as t`.
