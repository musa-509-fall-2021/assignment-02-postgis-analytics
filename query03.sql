/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset,
  pair each parcel with its closest bus stop. The final result should give the
  parcel address, bus stop name, and distance apart in meters. Order by
  distance (largest on top).
*/
/*create index for*/
/*similar answer https://qa.1r1g.com/sf/ask/3398603561/*/
DROP INDEX IF EXISTS phl_pwd_parcels_the_geom_idx;
CREATE index phl_pwd_parcels_the_geom_idx
	on phl_pwd_parcels
	using GiST(st_transform(the_geom, 32129));

DROP INDEX IF EXISTS septa_bus_stops_the_geom_idx;
create index septa_bus_stops_the_geom_idx
    on septa_bus_stops
    using GiST(st_transform(the_geom, 32129));

     select
     	a.stop_name,
     	dis.address,
     	dis.distance_m
     from septa_bus_stops a
     CROSS JOIN LATERAL
       (SELECT
         address,
         st_transform(a.the_geom,32129) <-> st_transform(b.the_geom,32129) as distance_m
          FROM phl_pwd_parcels as b
          ORDER BY distance_m
        LIMIT 1) AS dis
   	order by distance_m desc;

/*address text,  -- The address of the parcel
    stop_name text,  -- The name of the bus stop
    distance_m double precision  -- The distance apart in meters


sample：
select a.id,closest_pt.id, closest_pt.dist
from tablea a
CROSS JOIN LATERAL
  (SELECT
     id ,
     a.geom <-> b.geom as dist
     FROM tableb b
     ORDER BY a.geom <-> b.geom
   LIMIT 1) AS closest_pt;
*/
