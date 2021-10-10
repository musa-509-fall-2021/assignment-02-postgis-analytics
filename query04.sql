/**
4. Using the _shapes.txt_ file from GTFS bus feed, find the **two**
routes with the longest trips. In the final query, give the `trip_headsign` 
that corresponds to the `shape_id` of this route and the length of the trip.

  **Structure:**
  ```sql
  (
      trip_headsign text,  -- Headsign of the trip
      trip_length double precision  -- Length of the trip in meters
  )
  ```
**/

with septa_bus_lines as (
	SELECT shape_id, ST_MakeLine(ST_Transform(ST_SetSRID(ST_Point(shape_pt_lon,shape_pt_lat),4326),32129) ORDER BY shape_pt_sequence) As line_geom
	FROM septa_bus_shapes As bus
	GROUP BY shape_id
),
septa_headsigns as (
  SELECT DISTINCT shape_id, trip_headsign
  FROM septa_bus_trips
)
SELECT h.trip_headsign, ST_Length(l.line_geom) as trip_length
FROM septa_bus_lines AS l
JOIN septa_headsigns as h USING (shape_id)
ORDER BY trip_length desc
LIMIT 2