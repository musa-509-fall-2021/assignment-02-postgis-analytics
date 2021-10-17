/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop.
The final result should give the parcel address, bus stop name, and distance apart in meters.
Order by distance (largest on top).
*/

/* 03-10 using PostgreSQL*/


select address,
       stop_name,
       distance_m*111000 as distance_m
from phl_pwd_parcels p
    cross join lateral (
        select stop_name,
        p.geom<-> b.the_geomgeo distance_m
        from septa_bus_stops b
        order by distance_m
        limit 1
    ) a
order by distance_m desc
