# Assignment 02: PostGIS Analytics

**Due: Oct 17, 2021 by 11:59pm ET**

## Questions

1. Which bus stop has the largest population within 800 meters? As a rough estimation, consider any block group that intersects the buffer as being part of the 800 meter buffer.

|stop_name             |estimated_pop_800m|geometry                                      |
|----------------------|-----------------:|--------------------------------------------------|
|Passyunk Av & 15th St |             50,867|*Point*|

2. Which bus stop has the smallest population within 800 meters?

  **The queries to #1 & #2 should generate relations with a single row, with the following structure:**


|stop_name             |estimated_pop_800m|geometry                                      |
|----------------------|-----------------:|--------------------------------------------------|
|Charter Rd & Norcom Rd|                 2|*Point*|

3. Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).

| # |address              |stop_name                      |distance_m|
|---|---------------------|-------------------------------|---------:|
|1  |1431 W SOMERSET ST   |Broad St & Somerset St         |77.09|
|2  |1437 W SOMERSET ST   |Broad St & Somerset St         |91.72|
|3  |9101 FRANKFORD AVE   |Frankford Av & Tolbut St       |144.85|
|4  |193 W WINGOHOCKING ST|Wingohocking St & Rising Sun Av|63.58|
|5  |186 W ANNSBURY ST    |Wingohocking St & Rising Sun Av|80.13|


4. Using the _shapes.txt_ file from GTFS bus feed, find the **two** routes with the longest trips. In the final query, give the `trip_headsign` that corresponds to the `shape_id` of this route and the length of the trip.

|trip_headsign                 |trip_length       |
|------------------------------|-----------------:|
|Bucks County Community College| 46,504|
|Oxford Valley Mall            |43,658|

5. Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the metric you devise in rating neighborhoods. Describe your accessibility metric:

  **Description:**

6. What are the _top five_ neighborhoods according to your accessibility metric?

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

8. With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.

|upenn_count_block_groups      |
|------------------------------|
|36                            |

9. With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.

|geo_id                        |
|------------------------------|
|421010369001                  |


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
