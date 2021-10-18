/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus
  stop. The final result should give the parcel address, bus stop name, and distance apart in meters. Order by
  distance (largest on top).
*/

create index phl_pwd_parcels__idx
    on phl_pwd_parcels
    using GiST (ST_Transform(the_geom, 32129));

UPDATE phl_pwd_parcels
    set the_geom = st_transform(st_setsrid(the_geom,4326), 32129);

with pwd_stop_distance as(
	select
		s.stop_name,
		pwd.address,
		pwd.distance
	from septa_bus_stops as s
	join lateral(
		select 
			pp.address, 
			pp.the_geom as pwd_the_geom, 
			s.the_geom<->pp.the_geom as distance
		from  phl_pwd_parcels as pp 
		order by s.the_geom<->pp.the_geom
		limit 1
	) as pwd on TRUE
)

select * 
from pwd_stop_distance
order by distance desc
/*Result: 
stop_name                         address              distance
"Hope Av & Charles St"   	      "7800 CITY AVE"	   47362.37687688479
"Madison St & Strode Av"	      "7800 CITY AVE"	   47038.080340494904
"Strode Av & Charles St"	      "7800 CITY AVE"	   47018.427253536276
"Lincoln Hwy & Church St - FS"	  "7800 CITY AVE"	   46915.283171669565
"Lincoln Av & Church St"	      "7800 CITY AVE"	   46911.05468754834
...                               ...                  ...
...                               ...                  ...
...                               ...                  ...
