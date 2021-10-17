/*4. Using the shapes.txt file from GTFS bus feed, find the two routes with the longest trips. 
In the final query, give the trip_headsign that corresponds to the shape_id of this route and the length of the trip. 

ANSWER: The trip headsign of two routes with the longest trips are 201007 and 007201 and the trip length are both 66568.43m.
*/
ALTER TABLE shapes 
ADD COLUMN 
the_geom geometry(Geometry,32129);

UPDATE shapes 
SET
  the_geom = ST_transform(ST_SetSRID(
		st_makepoint
		(shape_pt_lon, shape_pt_lat),
		4326),32129);
		
 select shape_id as trip_headsign, 
 st_length(
	  st_makeline
	  (the_geom order by shape_pt_sequence) 
  )
  as trip_length
  from shapes
	group by shape_id
	order by trip_length desc
	limit 2
