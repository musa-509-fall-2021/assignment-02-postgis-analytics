/*
 With a query involving PWD parcels and census block groups, 
 find the `geo_id` of the block group that contains Meyerson Hall. 
 ST_MakePoint() and functions like that are not allowed.
 */
/*
 PROCESS
 I'm filtering the Meyerson Hall from the full PWD Parcel table,
 by its 'Parcel Address' of "220-30 s 34TH ST". -- which is 
 different from a place or building's 'Site' or 'Mailing' Address.
 I was able to located this address with the PWD Parcel Viewer:
 https://stormwater.phila.gov/parcelviewer/map
 */
WITH meyerson_hall AS (
    SELECT
        *
    FROM
        phl_parcels
    WHERE
        address = '220-30 S 34TH ST'
)
SELECT
    bg.geo_id AS geo_id
FROM
    meyerson_hall AS mh,
    census_block_groups AS bg
WHERE
    ST_Intersects(
        st_transform(mh.the_geom, 32129),
        st_transform(bg.the_geom, 32129)
    )
LIMIT
    1
/*
geo_id text
*/