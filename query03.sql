/*
  Using the Philadelphia Water Department Stormwater 
  Billing Parcels dataset, 
  pair each parcel with its closest bus stop. 
  The final result should give the parcel address, 
  bus stop name, and distance apart in meters. 
  Order by distance (largest on top).   */

  
--------this is what I went wiht ------
ALTER TABLE pwd_parcels
	ALTER COLUMN geom
	TYPE Geometry(MultiPolygon, 32129) 
	USING ST_Transform(geom, 32129);
	
	
create index philly_waterparcel_geom_32129_idx
    on pwd_parcels
    using GiST (geom);

ALTER TABLE septa_bus_stops
	ALTER COLUMN the_geom
	TYPE Geometry(Point, 32129) 
	USING ST_Transform(the_geom, 32129);
	
	
create index septa_bus_stops_geom_32129_idx
    on septa_bus_stops
    using GiST (the_geom);


SELECT w.parcelid, w.address, test, distancem
FROM pwd_parcels as w
cross join lateral (
	SELECT the_geom, stop_name, w.geom<->s.the_geom as distancem
	FROM septa_bus_stops as s 
	ORDER BY distancem ASC
) as test
