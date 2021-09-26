-- EPSG:32129
-- NAD83 / Pennsylvania South / meter

-- csepta_bus_stops
ALTER TABLE septa_bus_stops
ADD COLUMN the_geom geometry;

update septa_bus_stops
set the_geom = 
    st_transform(
        st_setsrid(
            st_point(stop_lon,stop_lat),4326
        ),32129
    );

SELECT *
from septa_bus_stops
limit 10;

-- census_block_groups 
ALTER TABLE census_block_groups
ADD COLUMN the_geom geometry;

update census_block_groups
set the_geom = st_transform(geometry,32129);

select * from census_population
limit 10;

-- phl_pwd_parcels
ALTER TABLE phl_pwd_parcels
ADD COLUMN the_geom geometry;

update phl_pwd_parcels
set the_geom = st_transform(geometry,32129);

-- septa_bus_shapes
ALTER TABLE septa_bus_shapes
ADD COLUMN the_geom geometry;

update septa_bus_shapes
set the_geom = st_transform(
    st_setsrid(
        st_point(shape_pt_lon,shape_pt_lat),4326
    ),32129);

select st_astext(the_geom) from septa_bus_shapes
limit 10;

-- septa_bus_shapes
ALTER TABLE neighborhood
ADD COLUMN the_geom geometry;

update neighborhood
set the_geom = st_transform(geometry,32129);

select st_astext(the_geom) from neighborhood
limit 10;