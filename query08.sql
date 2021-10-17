/* 8. With a query, find out how many census block groups Penn's main 
campus fully contains. Discuss which dataset you chose for defining 
Penn's campus.

I chose to use the file from Open Data Philly because it was easy to find. 
I tried searching across UPenn's website but I couldn't find anything. I did 
find a (sadly inactive) GIS club hosted out of one of the libraries, which cool to see. 
But it wasn't easy to get this information from the school and frankly, that shouldn't be the case.
 */


with upenn as (
SELECT *, geom as penngeom
FROM universities
WHERE name = 'University of Pennsylvania'
)

SELECT count(DISTINCT geoid10) as count_block_groups
FROM census_block_groups as c
Join upenn as p 
on st_contains(c.the_geom, p.penngeom)

/* RESULT: 23 */