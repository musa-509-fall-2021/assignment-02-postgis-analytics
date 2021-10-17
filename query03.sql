/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top).
*/

WITH nearest_bus_stop AS (
    SELECT
        phl_pwd_parcels."ADDRESS" AS address,
        phl_pwd_parcels.geometry,
        septa_bus_stops.stop_name,
        ST_Distance(geography(septa_bus_stops.the_geom), geography(phl_pwd_parcels.geometry)) AS distance_m
    FROM
        phl_pwd_parcels
    CROSS JOIN LATERAL
        (SELECT the_geom, stop_name
        FROM septa_bus_stops
        ORDER BY
            phl_pwd_parcels.geometry <-> septa_bus_stops.the_geom
        LIMIT 1) AS septa_bus_stops)

SELECT
    address,
    stop_name,
    distance_m
FROM nearest_bus_stop
ORDER BY distance_m DESC