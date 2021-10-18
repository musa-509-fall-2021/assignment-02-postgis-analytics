/*
  Using the shapes.txt file from GTFS bus feed, find the two routes with the longest trips.
  In the final query, give the trip_headsign that corresponds to the shape_id of this route
  and the length of the trip.

route_id  trip_headsign                   trip_length
130	      Bucks County Community College	47.118764819148645	
128	      Oxford Valley Mall	            44.22999400386279	

*/

with bus_lines as (
  select shape_id,
  ST_MakeLine(ST_Transform(ST_SetSRID(ST_MakePoint(shape_pt_lon,shape_pt_lat),4326),32139)
  order by shape_pt_sequence) as line_geom
  from septa_bus_shapes
  group by shape_id
),

bus_headsigns as (
  select distinct shape_id, route_id, trip_headsign
  from septa_bus_trips
)

-- length in kilometers
select h.route_id, h.trip_headsign, ST_Length(l.line_geom)/1000 as trip_length
  from bus_lines l
  left join bus_headsigns h
  using (shape_id)
  order by trip_length desc
  limit 2
