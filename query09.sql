/*With a query involving PWD parcels and census block groups,
find the geo_id of the block group that contains Meyerson Hall.
 ST_MakePoint() and functions like that are not allowed.*/


    geo_id text

    with meyerson as (
      	select *
  	from pwd_parcel
  	where address = '220-30 S 34TH ST' and owner1 like '%UNIV%'
      )

      select geoid10 as geo_id
      from census_block_group g
  	join meyerson m
      on st_contains(ST_Transform(g.geometry, 32129), ST_Transform(m.geometry, 32129))

421010369001
