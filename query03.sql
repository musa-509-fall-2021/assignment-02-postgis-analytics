/* query 03
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. 
The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).
*/

SELECT
      p.address,
      c.stop_name,
      c.distance * 111000 AS distance_m
	FROM phl_pwd_parcels AS p
CROSS JOIN LATERAL(
  SELECT stop_name,
         the_geom,
         p.the_geom <->s.the_geom AS distance
  FROM septa_bus_stops s
  ORDER BY distance
  LIMIT 1) c
    ORDER BY distance_m DESC