/*
 3. Using the Philadelphia Water Department Stormwater Billing 
 Parcels dataset, pair each parcel with its closest bus stop. 
 The final result should give the parcel address, bus stop name, 
 and distance apart in meters. Order by distance (largest on top).
 */
create index phl_pwd_parcels_geo_index 
on phl_pwd_parcels 
using gist (the_geom);

create index septa_bus_stops_geo_index 
on septa_bus_stops
using gist (the_geom);

with parcels as (
    select the_geom geo, address
    from phl_pwd_parcels
),

bus_stations as (
    select stop_name, the_geom geo
    from septa_bus_stops
)

select address,
    stop_name,
    distance_m
from parcels p
    cross join lateral (
        select stop_name,
            p.geo <->b.geo distance_m
        from bus_stations b
        order by 2
        limit 1
    ) nearest_bus_station
order by 3 desc;