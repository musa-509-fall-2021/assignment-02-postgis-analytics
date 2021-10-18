/* 
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
  pair each parcel with its closest bus stop. The final result should give 
  the parcel address, bus stop name, and distance apart in meters. Order by 
  distance (largest on top) 
*/

-- create a geometry column with longitude and latitude for septa_bus_stops
alter table septa_bus_stops
    add column if not exists geometry geometry(Point, 4326);

update septa_bus_stops
  set geometry = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);
  
-- create 2 geometry indexes
create index if not exists septa_bus_stops__the_geom__32129__idx
    on septa_bus_stops
    using GiST (ST_Transform(geometry, 32129));

create index if not exists phl_pwd_parcels_geometry_32129_idx
    on phl_pwd_parcels
    using GiST (ST_Transform(geometry, 32129));

-- create subquery of closest bus stop of each parcel
with phl_pwd_parcels_closest_distance as(
    SELECT
        p.address,
        min(
            ST_Distance(
                ST_Transform(p.geometry, 32129),
                ST_Transform(s.geometry, 32129)
            )
        )as distance_m
    FROM phl_pwd_parcels as p
    CROSS JOIN septa_bus_stops as s
    GROUP BY p.address
),
-- create subquery of distance between each bus stop and each parcel
phl_pwd_parcels_distance as(
    SELECT
        p.address,
        s.stop_name,
        ST_Distance(
            ST_Transform(p.geometry, 32129),
            ST_Transform(s.geometry, 32129)
        )as distance_m
    FROM phl_pwd_parcels as p
    CROSS JOIN septa_bus_stops as s
)
-- final result combining stop names to addresses with closest distance
select distinct
    cd.address,
    d.stop_name,
    cd.distance_m
from
    phl_pwd_parcels_distance as d
JOIN
    phl_pwd_parcels_closest_distance as cd
ON d.distance_m = cd.distance_m;


