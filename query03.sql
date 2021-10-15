/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop.
The final result should give the parcel address, bus stop name, and distance apart in meters.
Order by distance (largest on top).
*/


create index phl_pwd_parcels_idx
  on phl_pwd_parcels
  using gist (geom);

create index septa_bus_stops_idx
  on septa_bus_stops
  using gist (the_geom);

select
      p.address,
      a.stop_name,
      a.distance * 111000 as distance_m
from
      phl_pwd_parcels as p
cross join lateral(
  select stop_name,
         the_geom,
         p.geom <->s.the_geom as distance
  from septa_bus_stops s
  order by distance
  limit 1) a
    order by distance_m desc
