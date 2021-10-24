/*
  Using the shapes.txt file from GTFS bus feed, 
  find the two routes with the longest trips. 

  In the final query, give the `trip_headsign` that 
  corresponds to the shape_id of this route 
  and the length of the trip. */



with fulltable as (
SELECT * 
FROM septa_bus_shapes as s
LEFT JOIN trips as t on t.shape_id = s.shape_id
)

select trip_headsign, ST_LENGTH(ST_MAKELINE(geom ORDER BY shape_pt_sequence))*0.3048 as line_length_meters
From fulltable
group by trip_headsign
ORDER BY line_length_meters DESC
limit 3 

/* I'm limiting three b/c the longest trip has a NA headsign? idk why */

