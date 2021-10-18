with meyerson as(
  select
       address, geom
       from pwd_parcels
       where address='3400-04 WALNUT ST')

SELECT m.address, cb.geoid10 as geo_id
    FROM census_block_groups as cb
    JOIN meyerson as m
    ON ST_Contains(cb.geom, m.geom)

/* 
"3400-04 WALNUT ST"	"421010369001"
*/
