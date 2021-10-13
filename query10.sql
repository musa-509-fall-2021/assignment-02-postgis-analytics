/*
  I will fill the stop_desc by the neighborhood the station is located in
  from https://opendataphilly.org/dataset/philadelphia-neighborhoods
*/

alter table septa_rail_stops
    add column the_geom geometry(Geometry, 32129);

update septa_rail_stops
    set the_geom = ST_Transform(ST_SetSRID(st_makepoint(
	               stop_lon, stop_lat),4326),32129);
				   
SELECT s.stop_id, s.stop_name, p.listname stop_desc, s.stop_lon, s.stop_lat
    FROM neighborhoods_philadelphia as p
    JOIN septa_rail_stops as s
    ON ST_Contains(ST_transform(p.geom, 32129), s.the_geom)