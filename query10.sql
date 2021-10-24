/* 10. You're tasked with giving more contextual information to rail 
stops to fill the stop_desc field in a GTFS feed. Using any of the 
data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.),
 and PostgreSQL string functions, build a description (alias as stop_desc)
  for each stop. Feel free to supplement with other datasets (must provide 
  link to data used so it's reproducible), and other methods of describing 
  the relationships. PostgreSQL's CASE statements may be helpful for some
   operations.*/
/* 
USING these data: 

- Neighborhood Resources: https://www.opendataphilly.org/dataset/neighborhood-resources
- Street Trees: https://opendataphilly.org/dataset/philadelphia-street-tree-inventory/resource/457a95a6-c412-4d9e-a9ce-0988fee42d8d

#############################  My Plan  ############################

   ##Get Stop Characteristics##
   X find hca within mile 
   X find nac within mile
   X find engergyhelp within mil
   X find trees within 50 m

   ##Join Everything##
   X join  the hca table left with rail stops 
   X then union with full version of rail stops
   then join the nac table left with rail stops
   then union with full version of rail stop 
   join left treestops
   union full rail
   join left energyhelp
   union full rail

   ##Add Descriptions##
   at the end do case when hca
   then append to desc with case when nac
   then append to desc with case when treestops
   then append to desc with case when energy help/*


/*################  neighborhood resources  ###################*/

   /*HCA TABLE*/
      with rail as(

      SELECT st_setsrid(st_makepoint(stop_lon, stop_lat),4326) as the_geom, stop_name, stop_id, stop_desc
      FROM septa_rail_stops
      ), 


      housinghelp as (
      SELECT * 
      FROM neighborhoodresources
      WHERE hca IS NOT NULL
      ),

      onemile as (

      SELECT r.stop_name, r.stop_id, r.stop_desc, n.hca,  n.gid, n.agency, n.pre_purcha, n.foreclosur, r.the_geom, n.geom
      FROM rail as r
      JOIN housinghelp as n 
      on st_dwithin(st_transform(r.the_geom, 32129), st_transform(n.geom,32129), 1609)
      ),

      onemile_distance as (

      SELECT *, st_distance(st_transform(the_geom, 32129), st_transform(geom,32129))*0.000621371 as distanceMI
      FROM onemile

      )

      SELECT * 
      INTO onemile_distance
      FROM  onemile_distance;

   /*NAC TABLE */

      with rail as(

      SELECT st_setsrid(st_makepoint(stop_lon, stop_lat),4326) as the_geom, stop_name, stop_id, stop_desc
      FROM septa_rail_stops
      ), 


      NeighborhoodAdvisoryCommittee  as (
      SELECT * 
      FROM neighborhoodresources
      WHERE nac IS NOT NULL
      ),

      onemile as (

      SELECT r.stop_name, r.stop_id, r.stop_desc, n.hca,  n.gid, n.agency, n.pre_purcha, n.foreclosur, r.the_geom, n.geom
      FROM rail as r
      JOIN NeighborhoodAdvisoryCommittee as n 
      on st_dwithin(st_transform(r.the_geom, 32129), st_transform(n.geom,32129), 1609)
      ),

      onemile_distance as (

      SELECT *, st_distance(st_transform(the_geom, 32129), st_transform(geom,32129))*0.000621371 as distanceMI
      FROM onemile

      )

      SELECT * 
      INTO onemile_distance_nac
      FROM  onemile_distance;




   






   /*TREESTOPS TABLE*/ 

      with rail as(

      SELECT st_setsrid(st_makepoint(stop_lon, stop_lat),4326) as the_geom, stop_name, stop_id, stop_desc
      FROM septa_rail_stops
      ),

      treestops as (
      SELECT r.stop_id, count(t.gid) as num_trees_50m
      FROM rail as r
      LEFT JOIN strees as t 
      on st_dwithin(st_transform(r.the_geom, 32129), st_transform(t.geom,32129), 50)
      group by stop_id
      )


      SELECT * 
      INTO TREE_STOPS
      FROM  treestops;
      
   
   /*NEC TABLE*/
      with rail as(

      SELECT st_setsrid(st_makepoint(stop_lon, stop_lat),4326) as the_geom, stop_name, stop_id, stop_desc
      FROM septa_rail_stops
      ), 


      housinghelp as (
      SELECT * 
      FROM neighborhoodresources
      WHERE nec IS NOT NULL
      ),

      onemile as (

      SELECT r.stop_name, r.stop_id, r.stop_desc, n.nec,  n.gid, n.agency, r.the_geom, n.geom
      FROM rail as r
      JOIN housinghelp as n 
      on st_dwithin(st_transform(r.the_geom, 32129), st_transform(n.geom,32129), 1609)
      ),

      onemile_distance as (

      SELECT *, st_distance(st_transform(the_geom, 32129), st_transform(geom,32129))*0.000621371 as distanceMI
      FROM onemile

      )

      SELECT * 
      INTO onemile_distance_nec
      FROM  onemile_distance;


/* ########### joining and unioning with septa rail stops ########*/
   /* Prepping Septa_rail_stops */
      ALTER TABLE septa_rail_stops
      ADD COLUMN hca_distancemi double precision,
      ADD COLUMN nac_distancemi double precision,
      ADD COLUMN nec_distancemi double precision,
      ADD COLUMN num_trees_50m bigint;
   
   /* Joining each table and unioning back to all 
   rail stops one at a time, b/c I'm a scaredy cat */
   with hca_rail as (
      SELECT r.stop_id, r.stop_name, r.stop_desc,
         r.stop_lon, r.stop_lat, h.distancemi as hca_distancemi
      FROM septa_rail_stops as r
      LEFT JOIN onemile_distance as h
      USING (stop_id)
      ),

   hca_rail_union as (
      SELECT * 
      FROM hca_rail
      UNION 
      SELECT stop_id, stop_name, stop_desc, stop_lon, stop_lat, hca_distancemi
      FROM septa_rail_stops
      ),
   /*joining nac stops with hec stops*/
   nac_rail as (
      SELECT c.stop_id, c.stop_name, c.stop_desc, c.stop_lon, c.stop_lat, c.hca_distancemi, n.distancemi as nac_distancemi
      FROM hca_rail as c
      JOIN onemile_distance_nac as n
      USING (stop_id)
         ),
   /*union nac stops with all rail stops*/
   nac_hca_rail_union as (
      SELECT *
      FROM nac_rail
      UNION
      SELECT stop_id, stop_name, stop_desc, stop_lon, stop_lat, hca_distancemi, nac_distancemi
      FROM septa_rail_stops 
         ),

   nec_rail as (
   /*joining nec stops with nac and hec stops*/
      SELECT b.stop_id, b.stop_name, b.stop_desc, b.stop_lon, b.stop_lat, b.hca_distancemi, b.nac_distancemi, d.distancemi as nec_distancemi
      FROM nac_hca_rail_union as b
      JOIN onemile_distance_nec as d
      USING (stop_id)
      ),

   nec_nac_hca_rail_union as (
   /*union nec stops with all rail stops*/
      SELECT *
      FROM nec_rail
      UNION
      SELECT stop_id, stop_name, stop_desc, stop_lon, stop_lat, hca_distancemi, nac_distancemi, nec_distancemi
      FROM septa_rail_stops 
      ),
   trees_rail as (
   /*joining trees stops with nac and hec stops*/
      SELECT e.stop_id, e.stop_name, e.stop_desc, e.stop_lon, e.stop_lat, e.hca_distancemi, e.nac_distancemi, e.nec_distancemi, f.num_trees_50m
      FROM nec_nac_hca_rail_union as e
      JOIN tree_stops as f
      USING (stop_id)
      ),

   trees_nec_nac_hca_rail_union as(
   /*union tree stops with all rail stops*/
      SELECT *
      FROM trees_rail
      UNION
      SELECT stop_id, stop_name, stop_desc, stop_lon, stop_lat, hca_distancemi, nac_distancemi, nec_distancemi, num_trees_50m
      FROM septa_rail_stops 
      )
   /*saving into table */
   SELECT * 
   INTO septa_rail_desc
   FROM  trees_nec_nac_hca_rail_union;

/* ##### ADDING DSCRIPTIONS ###### */

   /*first update goes straight into desc*/
      /* HCA CASE WHEN*/
      UPDATE septa_rail_desc
      SET stop_desc = (case
               when hca_distancemi >0.5 AND hca_distancemi  < 1 then 'Housing Help within a mile'
               when hca_distancemi < 0.5 AND hca_distancemi  > 0.25 then 'Housing Help within half a mile'
               when hca_distancemi < 0.25 then 'Housing Help within half a mile'
               else NULL 
      end);
   /* following desc have to be concated into the stop_desc field, so
      as not to write over any other description in there. */

      /*NAC CASE WHEN*/
      UPDATE septa_rail_desc
      SET stop_desc = CONCAT (stop_desc, (case
                     when nac_distancemi >0.5 AND nac_distancemi  < 1 then ', Neighborhood Advisory Committee within a mile'
                     when nac_distancemi < 0.5 AND nac_distancemi  > 0.25 then ', Neighborhood Advisory Committee within half a mile'
                     when nac_distancemi < 0.25 then ', Neighborhood Advisory Committee within half a mile'
                     else ' '
      end)); 

      /*NEC CASE WHEN*/
      UPDATE septa_rail_desc
      SET stop_desc = CONCAT (stop_desc, (case
                     when nec_distancemi >0.5 AND nec_distancemi  < 1 then ', Energy Bill Help within a mile'
                     when nec_distancemi < 0.5 AND nec_distancemi  > 0.25 then ', Energy Bill Help  within half a mile'
                     when nec_distancemi < 0.25 then ', Energy Bill Help within half a mile'
                     else ' '
      end));

      /*TREESTOPS CASE WHEN*/ 
      UPDATE septa_rail_desc
      SET stop_desc = CONCAT ((case
                     when num_trees_50m > 5  then 'Decently Shady '
                     when num_trees_50m < 5 AND num_trees_50m  > 0 then 'Kind of Shady '
                     else 'Not Shady '
      end), stop_desc);

/* PRESENTING WITH SELECT */

SELECT stop_id, stop_name, stop_desc, stop_lon, stop_lat
FROM septa_rail_desc