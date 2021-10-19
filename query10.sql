/*
 You're tasked with giving more contextual information to rail stops 
 to fill the `stop_desc` field in a GTFS feed. Using any of the data sets above, 
 PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), and PostgreSQL string functions, 
 build a description (alias as `stop_desc`) for each stop. 
 Feel free to supplement with other datasets (must provide link to data used so it's reproducible), 
 and other methods of describing the relationships. PostgreSQL's `CASE` statements may be helpful for some operations.
 */
WITH rail_stops AS (
    SELECT
        stop_id,
        stop_name,
        stop_desc,
        stop_lon,
        stop_lat,
        ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326) AS the_geom
    FROM
        septa_rail_stops
),
parcel_stops AS (
    SELECT
        stop_id,
        stop_name,
        CONCAT('Located at ', initcap(phl_parcels.address)) AS stop_desc,
        stop_lon,
        stop_lat
    FROM
        phl_parcels,
        rail_stops
    WHERE
        st_contains(phl_parcels.the_geom, rail_stops.the_geom)
)
SELECT
    *
FROM
    parcel_stops

-- kind of got down to the wire with this question . . .