/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
  pair each parcel with its closest bus stop. The final result should give 
  the parcel address, bus stop name, and distance apart in meters. 
  Order by distance (largest on top).

*/

create index if not exists septa_bus_stops__the_geom__32129__idx
    on septa_bus_stops
    using GiST (ST_Transform(the_geom, 32129));

alter table phl_pwd_parcels
  add column if not exists the_geom geometry(MultiPolygon,4326);

update phl_pwd_parcels
  set the_geom = ST_GeomFromWKB(wkb_geometry, 4326);

create index if not exists phl_pwd_parcels__the_geom__32129__idx
    on phl_pwd_parcels
    using GiST (ST_Transform(the_geom, 32129));

select pwd.address, cs.stop_name, cs.dist_m
  from phl_pwd_parcels as pwd
  cross join lateral (
      select s.stop_name, pwd.the_geom<->s.the_geom dist_m
      from septa_bus_stops as s
      order by dist_m
      limit 1
  ) as cs
order by dist_m desc
 