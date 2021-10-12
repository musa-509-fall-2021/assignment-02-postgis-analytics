/*
  The UPenn campus shapefile was from Open Data Philly
  https://www.opendataphilly.org/dataset/philadelphia-universities-and-colleges/resource/7881a754-64f9-455f-861c-bc007e53427a
  That lists all colleges and universities in PHL, so I have to sort UPenn first
*/

with up as (select *
 from phl_universities
 where name = 'University of Pennsylvania'),

upcensus as (SELECT c.geoid10,
       u.name
FROM census_block_groups AS c
JOIN up AS u
ON ST_contains(c.geom, u.geom)
ORDER BY geoid10)

SELECT 
  COUNT ( DISTINCT geoid10 ) AS "num_of_tracts"
FROM upcensus

/*
  returned with 23
*/