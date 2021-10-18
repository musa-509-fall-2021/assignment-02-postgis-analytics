--septa_bus_stops

ALTER TABLE septa_bus_stops
ADD COLUMN the_geom geometry(Point, 4326);

UPDATE septa_bus_stops
SET the_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);

--phl_pwd_parcels

ALTER TABLE phl_pwd_parcels
ADD COLUMN the_geom geometry(Point, 4326);

UPDATE septa_bus_stops
SET the_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);

--septa_rail_stops

ALTER TABLE septa_rail_stops
ADD COLUMN the_geom geometry(Point, 4326);

UPDATE septa_rail_stops
SET the_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);

--septa_bus_shapes

ALTER TABLE septa_bus_shapes
ADD COLUMN the_geom geometry(Point, 4326);

UPDATE septa_bus_shapes
SET the_geom = ST_SetSRID(ST_MakePoint(shape_pt_long, shape_pt_lat), 4326);