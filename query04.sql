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
	select shape_id, ST_MakeLine(ST_Transform(ST_SetSRID(ST_Point(shape_pt_lon,shape_pt_lat),4326),32129) order by shape_pt_sequence) as line_geom
	from septa_bus_shapes as bus
	group by shape_id
),
septa_headsigns as (
  select distinct shape_id, trip_headsign
  from septa_bus_trips
)
select h.trip_headsign, ST_Length(l.line_geom) as trip_length
from septa_bus_lines as l
join septa_headsigns as h using (shape_id)
order by trip_length desc
limit 2