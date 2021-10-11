/*
3.Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. 
The final result should give the parcel address, bus stop name, and distance apart in meters. Order by distance (largest on top)

ANSWER: the largest on the top is 903 FRANKLIN MILLS CIR and the distance is 75798.57
	*/
UPDATE phl_pwd_parcels
SET
  geom = ST_transform(ST_SetSRID(
		geom,
		4326),32129);
		
create index phl_pwd_parcels__the_geom__32129__idx
    on phl_pwd_parcels
    using GiST (geom);
		
with parcels as 
(
select 
	address,geom 
from phl_pwd_parcels
),
bus_stops as (
	  select stop_name, the_geom
	    from septa_bus_stops
	)
	
SELECT
  A.address,
	distance
FROM parcels as A
CROSS JOIN lateral (
  SELECT stop_name, A.geom <-> B.the_geom as distance
  FROM bus_stops as B
  ORDER BY distance DESC
  LIMIT 1
) B
order by distance desc;