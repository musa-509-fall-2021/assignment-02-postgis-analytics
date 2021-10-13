select owner1, address, parcelid, geom
   from phl_pwd_parcels
   where owner1 like '%UNIV OF PENN'
   order by address asc

/*
  By checking the address and parcelid,
  the Meyerson Hall is 220-30 S 34TH ST,
  with parcel_id = 265222
*/

with meyerson as(
  select
       address, parcelid, geom
       from phl_pwd_parcels
       where address='220-30 S 34TH ST')

SELECT m.address, c.geoid10 as geo_id
    FROM census_block_groups as c
    JOIN meyerson as m
    ON ST_Contains(c.geom, m.geom)
	
/*
  geo_id = 421010369001
*/