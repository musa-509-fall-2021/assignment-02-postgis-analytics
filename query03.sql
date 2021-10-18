/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
  pair each parcel with its closest bus stop. The final result should give 
  the parcel address, bus stop name, and distance apart in meters. 
  Order by distance (largest on top).

*/

alter table phl_pwd_parcels
  add column if not exists the_geom geometry(MultiPolygon,4326);

update phl_pwd_parcels
  set the_geom = ST_GeomFromWKB(wkb_geometry, 4326);

create index if not exists phl_pwd_parcels__the_geom__32129__idx
    on phl_pwd_parcels
    using GiST (ST_Transform(the_geom, 32129));

select distinct on (pwd.address) pwd.address,
  s.stop_name, ST_Distance(pwd.the_geom,s.the_geom) as dist
  from phl_pwd_parcels as pwd
  join septa_bus_stops as s
    on ST_DWithin(
      ST_Transform(pwd.the_geom, 32129),
      ST_Transform(s.the_geom, 32129),
      1000
    )
 