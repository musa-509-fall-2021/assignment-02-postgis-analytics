/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop.
The final result should give the parcel address, bus stop name, and distance apart in meters.
Order by distance (largest on top).
*/

select stop_name,
address,
min(st_distance(s.the_geom, p.the_geom) as distance
from pwd_parcels as p
cross join
  septa_bus_stops as s
