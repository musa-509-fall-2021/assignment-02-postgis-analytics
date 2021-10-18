/*
 Using the _shapes.txt_ file from GTFS bus feed, 
 find the **two** routes with the longest trips. 
 In the final query, give:
 1. the `trip_headsign` that corresponds to the `shape_id` of this route and 
 2. the length of the trip.
 */
CREATE INDEX septa_bus_shapes__geometry__32129__idx 
    ON septa_bus_shapes 
    USING GiST (st_transform(the_geom, 32129));

WITH septa_bus_routes AS (
    SELECT
        shape_id,
        ST_MakeLine(
            the_geom
            ORDER BY
                shape_pt_sequence ASC
        ) AS the_geom
    FROM
        septa_bus_shapes
    GROUP BY
        shape_id
)
SELECT
    trips.trip_headsign AS trip_headsign,
    ST_Length(st_transform(routes.the_geom, 32129)) AS trip_length
FROM
    septa_bus_routes AS routes
    JOIN (
        SELECT
            DISTINCT trip_headsign,
            shape_id
        FROM
            septa_bus_trips
    ) AS trips USING (shape_id)
ORDER BY
    trip_length DESC
LIMIT
    2;

/*
 trip_headsign text,  -- Headsign of the trip
 trip_length double precision  -- Length of the trip in meters
 */