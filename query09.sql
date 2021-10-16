/*
With a query involving PWD parcels and census block groups,
find the `geo_id` of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.
*/


/* first, I looked up the address of Meyerson Hall in Google map(210 S 34th St), then compared this address with address column in 'PWD parcels' dataset,
even though I cannot match the exactly same address, I found the closest one.
Using the query below to find the most appropriate address:

select *
from pwd_parcels
where address like '% S 34TH ST%'

returned with '220 S 34TH ST'
*/

select geoid10 as geo_id
from (
	select geom
	from pwd_parcels
	where address = '220-30 S 34TH ST'
) m
join census_block_groups c
on st_contains(c.geom, m.geom)

/*421010369001
*/
