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

[1. Which bus stop has the largest population within 800 meters?](query01.sql)
As a rough estimation, consider any block group that intersects the buffer as being part of the 800 meter buffer.

|stop_name|Population|the_geom|
|:---:|:---:|:---:|
|"Passyunk Av & 15th St"|50867|"0101000020E6100000B1C398F4F7CA52C0D0807A336AF64340"|

[2. Which bus stop has the smallest population within 800 meters?](query02.sql)

  **The queries to #1 & #2 should generate relations with a single row, with the following structure:**

  ```sql
  (
      stop_name text, -- The name of the station
      estimated_pop_800m integer, -- The population within 800 meters
      the_geom geometry(Point, 4326) -- The geometry of the bus stop
  )
  ```
|stop_name|Population|the_geom|
|:---:|:---:|:---:|
|"Charter Rd & Norcom Rd"|2|"0101000020E6100000C896E5EB32C052C0DF3312A1110C4440"|

[3. Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters.](query0.sql)
Order by distance (largest on top).

  **Structure:**
  ```sql
  (
      address text,  -- The address of the parcel
      stop_name text,  -- The name of the bus stop
      distance_m double precision  -- The distance apart in meters
  )
  ```
|address|stop_name|distance_m|
|:---:|:---:|:---:|
|"170 SPRING LN"|"Ridge Av & Ivins Rd"|1658.7873935682778|
|"150 SPRING LN"|"Ridge Av & Ivins Rd"|1620.287986054119|
|"130 SPRING LN"|"Ridge Av & Ivins Rd"|1610.9941677070408|
|"190 SPRING LN"|"Ridge Av & Ivins Rd"|1490.0758681771356|
|"630 ST ANDREW RD"|"Germantown Av & Springfield Av"|1418.391081836291|
|...|...|...|

[4. Using the _shapes.txt_ file from GTFS bus feed, find the **two** routes with the longest trips.](query04.sql)
In the final query, give the `trip_headsign` that corresponds to the `shape_id` of this route and the length of the trip.

  **Structure:**
  ```sql
  (
      trip_headsign text,  -- Headsign of the trip
      trip_length double precision  -- Length of the trip in meters
  )
  ```
|trip_headsign|trip_length|
|:---:|:---:|
|"Bucks County Community College"|46504.13530588818|
|NULL: no trip_headsign for 266697|45331.46753203432|

[5. Rate neighborhoods by their bus stop accessibility for wheelchairs.](query05.sql)
Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the metric you devise in rating neighborhoods. Describe your accessibility metric:

  **Description:**
    The basic measure of accessibility is the equation  A_i= ∑ O_j  *  d_ij^(-b) (where X_y denotes that y is a subscript of X)
    The equation describes the accessibility of an individual where the accessibility of the individual, A_i, 
    is calculated by finding the sum of all quality opportunities (such as jobs),  
    O_j, multiplied by the separation of those opportunities from the individual’s starting location, 
    d_ij – which can be measured in distance, time, or a monetary cost, exponentiated by the degree to which accessibility to that opportunity declines with increasing separation.

    Job opportunities will be substituted for parcels (potential dwellings) -> (O_j)
    A rule-of-thumb used by transportation planners is that people are generally willing to walk up to 0.5 miles to access transit.
    Since we are measuring wheelchair accessibility, we will measure the number of opportunities  within 500 feet (152.5 meters) of each wheelchair accessible bus stop -> (d_ij)

    This index will be aggregated at the neighborhood level, and paired with a count of the wheelchair accessible stops in each neighborhood.

[6. What are the _top five_ neighborhoods according to your accessibility metric?](query06.sql)
[Screenshot of answer - queries take 45 minutes to run](A2_Q6_queryResults.PNG)
|neighborhood_name|accessibility_metric|num_bus_stops_accessible|num_bus_stops_inaccessible|
|:---:|:---:|:---:|:---:|
|COBBS_CREEK|10282|123|10|
|POINT_BREEZE|8943|83|0|
|OLNEY|8960|172|0|
|RICHMOND|8359|116|0|
|WEST_OAK_LANE|7889|124|0|

[7. What are the _bottom five_ neighborhoods according to your accessibility metric?](query07.sql)
[Screenshot of answer - queries take 45 minutes to run](A2_Q7_results.PNG)
  **Both #6 and #7 should have the structure:**
  ```sql
  (
    neighborhood_name text,  -- The name of the neighborhood
    accessibility_metric ...,  -- Your accessibility metric value
    num_bus_stops_accessible integer,
    num_bus_stops_inaccessible integer
  )
  ```
|neighborhood_name|accessibility_metric|num_bus_stops_accessible|num_bus_stops_inaccessible|
|:---:|:---:|:---:|:---:|
|"WEST_PARK"|0|28|0|
|"BARTRAM_VILLAGE"|0|0|14|
|"PENNYPACK_PARK"|0|22|0|
|"MECHANICSVILLE"|0|0|0|
|"WEST_TORRESDALE"|2|1|0|

[8. With a query, find out how many census block groups Penn's main campus fully contains.](query08.sql)
Discuss which dataset you chose for defining Penn's campus.

  **Structure (should be a single value):**
  ```sql
  (
      count_block_groups integer
  )
  ```
|count_block_groups|
|:---:|
|1|

[9. With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall.](query09.sql) 
 ST_MakePoint() and functions like that are not allowed.

  **Structure (should be a single value):**
  ```sql
  (
      geo_id text
  )
  ```
|geo_id|
|:---:|
|421010369001|

[10. You're tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed.](query10.sql) 
 Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), and PostgreSQL string functions, build a description (alias as `stop_desc`) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. PostgreSQL's `CASE` statements may be helpful for some operations.
 As an example, your `stop_desc` for a station stop may be something like "37 meters NE of 1234 Market St" (that's only an example, feel free to be creative, silly, descriptive, etc.)
 **Tip when experimenting:** Use subqueries to limit your query to just a few rows to keep query times faster. Once your query is giving you answers you want, scale it up. E.g., instead of `FROM tablename`, use `FROM (SELECT * FROM tablename limit 10) as t`.

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
I decided to list the closest bus station to the rail station and which bus routes that station serves. This method is flawed in that 
it accounts for multiple bus routes that service the same bus stop.

|stop_id|stop_name|stop_desc|stop_lon|stop_lat|
|:---:|:---:|:---:|:---:|:---:|
|91004|"30th St Lower Level"|"The closest bus stop is 33rd St & Race St and is 84.56 meters away. It is serviced by the City Hall to 76th-City route."|-75.1883333|39.9591667|
|90004|"30th Street Station"|"The closest bus stop is  and is 168.65 meters away. It is serviced by the  route."|-75.1816667|39.9566667|
|90314|"49th Street"|"The closest bus stop is 49th St & Chester Av - FS and is 46.76 meters away. It is serviced by the 50th-Parkside to Pier 70 route."|-75.2166667|39.9436111|
|90539|"9TH Street Lansdale"|"The closest bus stop is Broad St & Hatfield St - FS and is 259.03 meters away. It is serviced by the Telford to Montgomery Mall route."|-75.2791667|40.25|
|90404|"Airport Terminal A"|"The closest bus stop is  and is 142.09 meters away. It is serviced by the  route."|-75.2452778|39.8761111|
|...|...|...|...|...|
