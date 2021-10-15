# Assignment 02: PostGIS Analytics

**Due: Oct 11, 2021 by 11:59pm ET**

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

A: "Passyunk Av & 15th St" has the largest population of 50867.

2. Which bus stop has the smallest population within 800 meters?

  **The queries to #1 & #2 should generate relations with a single row, with the following structure:**

  ```sql
  (
      stop_name text, -- The name of the station
      estimated_pop_800m integer, -- The population within 800 meters
      the_geom geometry(Point, 4326) -- The geometry of the bus stop
  )
  ```

  A: "Charter Rd & Norcom Rd" has the smallest population of 2.

3. Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).

  **Structure:**
  ```sql
  (
      address text,  -- The address of the parcel
      stop_name text,  -- The name of the bus stop
      distance_m double precision  -- The distance apart in meters
  )
  ```
| address          | stop_name                      | distance_m         |
| ---------------- | ------------------------------ | ------------------ |
| 170 SPRING LN    | Ridge Av & Ivins Rd            | 1658.7873935685589 |
| 150 SPRING LN    | Ridge Av & Ivins Rd            | 1620.287986054119  |
| 130 SPRING LN    | Ridge Av & Ivins Rd            | 1610.9941677070408 |
| 190 SPRING LN    | Ridge Av & Ivins Rd            | 1490.0758681774478 |
| 630 ST ANDREW RD | Germantown Av & Springfield Av | 1418.391081837042  |
| ...              | ...                            | ...                |



4. Using the _shapes.txt_ file from GTFS bus feed, find the **two** routes with the longest trips. In the final query, give the `trip_headsign` that corresponds to the `shape_id` of this route and the length of the trip.

  **Structure:**
  ```sql
  (
      trip_headsign text,  -- Headsign of the trip
      trip_length double precision  -- Length of the trip in meters
  )
  ```
  
| trip_headsign | trip_length        |
| ------------- | ------------------ |
| 266311        | 15445.022598532600 |
| 266312        | 10044.302723522300 |
| 266313        | 15445.022598532600 |
| 266314        | 11149.195550009400 |
| 266315        | 10982.949704948900 |


5. Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the metric you devise in rating neighborhoods. Describe your accessibility metric:

  **Description:**

  $$Score = WheelchairDensity * WheelchairPct =\frac{N}{S} * \frac{N}{N'}$$

  > $N$: Number of stops with wheelchairs boarding
  >
  > $N'$: Number of all stops
  >
  > $S$: Area of the neighborhood($km^2$)
  >
  > \* Not known is considered as false.


6. What are the _top five_ neighborhoods according to your accessibility metric?

| **neighborhood_name**      | **accessibility_metric** | **num_bus_stops_accessible** | **num_bus_stops_inaccessible** |
| -------------------------- | ------------------------ | ---------------------------- | ------------------------------ |
| **Washington Square West** | 0.00008472025565149550   | 72                           | 2                              |
| **Newbold**                | 0.00008254186446362420   | 45                           | 4                              |
| **Spring Garden**          | 0.00007627525758323820   | 48                           | 2                              |
| **Hawthorne**              | 0.00007601551498445400   | 30                           | 0                              |
| **Francisville**           | 0.00007487622621403220   | 41                           | 0                              |



7. What are the _bottom five_ neighborhoods according to your accessibility metric?

  **Both #6 and #7 should have the structure:**
  ```sql
  (
    neighborhood_name text,  -- The name of the neighborhood
    accessibility_metric ...,  -- Your accessibility metric value
    num_bus_stops_accessible integer,
    num_bus_stops_inaccessible integer
  )
  ```

- 

| **neighborhood_name** | **accessibility_metric** | **num_bus_stops_accessible** | **num_bus_stops_inaccessible** |
| --------------------- | ------------------------ | ---------------------------- | ------------------------------ |
| **Bartram Village**   | 0                        | 0                            | 14                             |
| **Port Richmond**     | 0.000001263189033554710  | 2                            | 0                              |
| **West Torresdale**   | 0.0000018492499673526600 | 1                            | 0                              |
| **Navy Yard**         | 0.0000018794112591801200 | 14                           | 0                              |
| **Airport**           | 0.0000021422035439600800 | 20                           | 0                              |

  

8. With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.

  **Structure (should be a single value):**
  ```sql
  (
      count_block_groups integer
  )
  ```
  I choose ["Philadelphia Universities and Colleges"](https://www.opendataphilly.org/dataset/philadelphia-universities-and-colleges/resource/1e37f5f0-6212-4cb4-9d87-261b58ae01c4) dataset, adding a buffer of 80m and union the polygons. The result census block groups fully contained is 3.


9. With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.

  **Structure (should be a single value):**
  ```sql
  (
      geo_id text
  )
  ```

  |**geo_id**|
  |---|
  |421010369001|


10. You're tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), and PostgreSQL string functions, build a description (alias as `stop_desc`) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. PostgreSQL's `CASE` statements may be helpful for some operations.

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

  As an example, your `stop_desc` for a station stop may be something like "37 meters NE of 1234 Market St" (that's only an example, feel free to be creative, silly, descriptive, etc.)
  
  
  
  I decided to find and list parks around the bus stops as a guide to people who want to go to park by bus. The point data of Philly is from [HERE](https://www.pasda.psu.edu/uci/DataSummary.aspx?dataset=7021). Below is the final result of `stop_desc`.
  
  > There are 6 park(s) within 1.5km of this stop, at the 33th percentile among the park number of all stops. And here are 3 of them which is/are the closest. :) 
  > 1. Nicetown Park at 4369-71 GERMANTOWN AVE which is 847m N (10 mins walk) of the stop.
  > 2. Fernhill Park at 4600 MORRIS ST which is 1128m W (14 mins walk) of the stop.
  > 3. Hunting Park at 1101 W HUNTING PARK AVE which is 1237m NE (15 mins walk) of the stop.

  **Tip when experimenting:** Use subqueries to limit your query to just a few rows to keep query times faster. Once your query is giving you answers you want, scale it up. E.g., instead of `FROM tablename`, use `FROM (SELECT * FROM tablename limit 10) as t`.
