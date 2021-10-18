/*
 With a query, find out how many census block groups 
 Penn's main campus fully contains. 
 Discuss which dataset you chose for defining Penn's campus.
 */
/*
 DATA
 I used OpenPhillyData's "Philadelphia Universities & Colleges" dataset:
 https://opendataphilly.org/dataset/philadelphia-universities-and-colleges
 This 'phl_uni' dataset is a filtered & re-labeled version of the PWD/DOR Parcels.
 I filtered by school name and the building description's land use (i.e. "SCHOOL").
 
 SIDE NOTE
 I tried filtering UPenn based on PWD Parcel's owner1 fields but the owner label is inconsistent.
 The difficultly is that fields are indexed & updated during the land assessment & taxation process;
 However, public or non-profit owned parcels are typically tax-exempt; 
 resulting in public/non-profit parcel fields being unstandardized and inconsistently entered.
 */
WITH upenn_main_campus AS (
    SELECT
        *
    FROM
        phl_uni
    WHERE
        phl_uni.name = 'University of Pennsylvania'
        AND phl_uni.building_description LIKE 'SCHOOL %'
)
SELECT
    count(*) AS upenn_count_block_groups
FROM
    census_block_groups AS bg,
    upenn_main_campus AS upenn
WHERE
    ST_Intersects(
        st_transform(upenn.the_geom, 32129),
        st_transform(bg.the_geom, 32129)
    )
/*
count_block_groups integer
*/