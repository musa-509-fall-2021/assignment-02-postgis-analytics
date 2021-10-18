/*
Using the shapes.txt file from GTFS bus feed, find the two routes with the longest trips. In the final query, give the trip_headsign that corresponds to the shape_id of this route and the length of the trip.
*/


/*
Explanation:

My original approach, which I believe to be the correct approach, was to measure the distance between the first and last stops for each route by using ST_Distance between the MAX shape_pt_sequence and MIN shape_pt_sequence for each shape_id. After several attempts, however, I could not determine how to isolate the rows containing the MAX and MIN shape_pt_sequence for each shape_id.

Instead, I opted for an alternative method below, which may or may not be accurate. For each shape_id, I summed the total number of stops by using COUNT on the shape_pt_sequences. The underlying logic is that the longest trips are those with the most stops. To determine the corresponding trip_headsign, I performed a join with the septa_bus_trips dataset.
*/

WITH headsign_shapes AS (
    SELECT DISTINCT
        septa_bus_shapes.shape_id,
        septa_bus_shapes.shape_pt_sequence,
        septa_bus_trips.trip_headsign
    FROM septa_bus_shapes
    JOIN septa_bus_trips ON septa_bus_shapes.shape_id=septa_bus_trips.shape_id
)

SELECT shape_id, trip_headsign
FROM headsign_shapes
GROUP BY shape_id, trip_headsign
ORDER BY COUNT(shape_pt_sequence) DESC
LIMIT 2