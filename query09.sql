with meyerson_hall_parcel as (
    SELECT the_geom meyerson_hall_parcel_geo 
    FROM public.phl_pwd_parcels
    where address like '3406-46 WALNUT ST'
)
SELECT geoid10 geo_id
from census_block_groups,meyerson_hall_parcel
where st_contains(the_geom,meyerson_hall_parcel_geo)