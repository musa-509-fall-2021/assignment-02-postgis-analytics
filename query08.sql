/* query 08
Find out how many census block groups Penn's main campus fully contains. 
Discuss which dataset you chose for defining Penn's campus.
*/
WITH penn_campus AS (
  SELECT ST_ConvexHull(geom) as penncampus
  FROM upenn_shape
)
SELECT COUNT(DISTINCT blkgrpce10) AS count_block_groups
  FROM penn_campus AS pc
  JOIN census_block_groups AS cbg
  ON ST_Contains(pc.penncampus, cbg.the_geom)
  
/*
I filtered the Philadelphia university data set to have only upenn parcels, and created a convex hull around all upenn parcels
counted distinct block groups within the penn campus 2 block groups are fully contained within penn's campus
*/