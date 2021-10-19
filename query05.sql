-- query05
/*
 Rate neighborhoods by their bus stop accessibility for wheelchairs. 
 Use Azavea's neighborhood dataset from OpenDataPhilly 
 along with an appropriate dataset from the Septa GTFS bus feed. 
 Use some creativity in the metric you devise in rating neighborhoods. 
 Describe your accessibility metric:
 */

-- CREATE INDEX phl_hoods__geometry__32129__idx 
--     ON phl_hoods 
--     USING GiST (st_transform(the_geom, 32129));

-- DROP TABLE IF EXISTS phl_hood_accessible_transit;

/*
PROCESS
To rate neighborhoods by their bus stop accessibility for wheelchairs, I formed
an accessibility metric that aggregated point ratings of three metrics:
1. Percent of Accessible Bus Stops where wheelchair boardings were possible (out of 10 points)
    (from the GTFS Google Bus Stops dataset of Philadelphia)
2. Bus Stops per square mile (out of 5)
    (area & aggregate based on OpenPhillyData's Neighborhood polygons)
3. Average Accessible Bus Stops per Square Mile of the neighboring neighborhood (out of 5)

The three metrics rate the accessibility of immediate bus stops and
the transit system at large. However, only on a surface level.

*/



CREATE TABLE phl_hood_accessible_transit AS

-- pull neighborhoods
WITH neighborhoods AS (
    SELECT
        mapname AS neighborhood,
        the_geom
    FROM
        phl_hoods
),
-- spatially join neighborhoods & bus stops
-- count accessible/inaccessible bus stops
-- get neighborhood area
neighborhoods_count AS (
    SELECT
        nb.neighborhood AS neighborhood,
        SUM(
            CASE
                WHEN (bs.wheelchair_boarding = 1) THEN 1
                ELSE 0
            END
        ) AS num_some,
        SUM(
            CASE
                WHEN (bs.wheelchair_boarding = 2) THEN 1
                ELSE 0
            END
        ) AS num_none,
        SUM(
            CASE
                WHEN (bs.wheelchair_boarding = 0) THEN 0
                ELSE 1
            END
        ) AS num_stops,
        st_area(st_transform(nb.the_geom, 32129)) AS area_m,
        st_area(st_transform(nb.the_geom, 2272)) AS area_ft,
        st_area(st_transform(nb.the_geom, 2272)) * 0.00000003587 AS area_mi,
        nb.the_geom AS the_geom
    FROM
        septa_bus_stops AS bs,
        neighborhoods AS nb
    WHERE
        ST_Contains(nb.the_geom, bs.the_geom)
    GROUP BY
        nb.neighborhood,
        nb.the_geom
),
-- combine the raw counts & area into the first two metrics
neighborhood_stats AS(
    SELECT
        ROUND(num_stops / area_mi :: numeric, 0) AS stops_per_mile,
        num_some / area_mi :: numeric AS accessible_per_mile,
        ROUND(num_some / num_stops :: numeric * 100, 2) AS pct_wheelchair_accessible,
        num_stops,
        num_none,
        num_some,
        the_geom,
        neighborhood
    FROM
        neighborhoods_count
    ORDER BY
        stops_per_mile
),
-- find the touching neighbors of each neighborhood
-- then get average the metrics of all the neighborhood's neighbors
neighborhood_neighbors AS(
    SELECT
        nb_main.neighborhood AS neighborhood,
        AVG(nb_neighbors.accessible_per_mile) AS avg_neighbors_accessible_per_mile,
        count(nb_neighbors.*) AS num_neighbors,
        string_agg(nb_neighbors.neighborhood, ', ') AS list_neighbors
    FROM
        neighborhood_stats AS nb_main
        CROSS JOIN LATERAL (
            SELECT
                DISTINCT neighborhood,
                accessible_per_mile
            FROM
                neighborhood_stats AS nb_compare
            WHERE
                ST_Touches(nb_main.the_geom, nb_compare.the_geom) = 'true'
                AND nb_main.neighborhood <> nb_compare.neighborhood
        ) AS nb_neighbors
    GROUP BY
        nb_main.neighborhood
),
-- get the max of the metrics 
-- in order to spread the metrics over a 5/10 point scale of the max
max_pct_wheelchair_accessible AS (
    SELECT
        MAX(pct_wheelchair_accessible)
    FROM
        neighborhood_stats
),
max_stops_per_mile AS (
    SELECT
        MAX(stops_per_mile)
    FROM
        neighborhood_stats
),
max_avg_neighbors_accessible_per_mile AS (
    SELECT
        MAX(avg_neighbors_accessible_per_mile)
    FROM
        neighborhood_neighbors
),
neighborhood_rates AS (
    SELECT
        st.neighborhood AS neighborhood,
        st.num_stops as num_stops,
        st.num_none as num_none,
        st.num_some as num_some,
        ROUND(st.pct_wheelchair_accessible, 0) AS pct_wheelchair_accessible,
        ROUND(
            (st.pct_wheelchair_accessible) * 10 / (
                SELECT
                    *
                FROM
                    max_pct_wheelchair_accessible
            ) :: numeric,
            2
        ) AS accessible_rate,
        st.stops_per_mile AS stops_per_mile,
        ROUND(
            (st.stops_per_mile) * 5 / (
                SELECT
                    *
                FROM
                    max_stops_per_mile
            ) :: numeric,
            2
        ) AS stops_per_mile_rate,
        ROUND(nn.avg_neighbors_accessible_per_mile, 0) AS avg_neighbors_wheelchair_per_mile,
        ROUND(
            (nn.avg_neighbors_accessible_per_mile) * 5 / (
                SELECT
                    *
                FROM
                    max_avg_neighbors_accessible_per_mile
            ) :: numeric,
            2
        ) AS neighbors_rate,
        st.the_geom AS the_geom
    FROM
        neighborhood_stats AS st,
        neighborhood_neighbors AS nn
    WHERE
        st.neighborhood = nn.neighborhood
)

SELECT
    neighborhood as neighborhood_name,
    accessible_rate + stops_per_mile_rate + neighbors_rate AS accessibility_metric,
    RANK () OVER (
        ORDER BY
            accessible_rate + stops_per_mile_rate + neighbors_rate DESC
    ) AS accessibility_rank,
    num_some AS num_bus_stops_accessible,
    num_none AS num_bus_stops_inaccessible,
    the_geom
FROM
    neighborhood_rates
ORDER BY
    accessibility_metric DESC;