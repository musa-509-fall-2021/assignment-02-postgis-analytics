/*
  3. Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
  pair each parcel with its closest bus stop. 
  The final result should give the parcel address, bus stop name, 
  and distance apart in meters. Order by distance (largest on top).
*/

ALTER TABLE phl_pwd_parcels
  ALTER COLUMN geom TYPE geometry(geometry, 0)
    USING ST_SetSRID(geom,32129);
	
SELECT
  p.address,
  s.stop_name,
  ST_Distance(geometry(s.the_geom), geometry(p.geom)) AS distance_m
FROM
  phl_pwd_parcels AS p
CROSS JOIN LATERAL
  (SELECT stop_name, the_geom
   FROM septa_bus_stops
   ORDER BY p.geom 
   LIMIT 1) AS s
   desc