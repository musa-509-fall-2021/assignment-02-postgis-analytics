/* With a query, find out how many census block groups 
Penn's main campus fully contains. Discuss which 
dataset you chose for defining Penn's campus.
*/

/*
The dataset is the properties owned by as defined by OpenDataPhilly dataset,
clipped by a University City bounding box, unionized together,
then transformed using the convex hull function.
There are 3 tracts fully contained within the campus.
*/

alter table uniphl
    add column if not exists the_geom geometry(MultiPolygon, 4326);

update uniphl
  set the_geom = ST_Multi(ST_GeomFromEWKB(wkb_geometry));

with penn_properties as (
  SELECT the_geom from uniphl as u
  join ST_SetSRID(ST_GeomFromText('POLYGON((-75.20631097406593 39.95762627319954,-75.20736266538619 39.94965534909787,-75.20694643439153 39.946934540569714,-75.20399571156507 39.944440932191185,-75.19817815743048 39.94401654933708,-75.193251323284 39.94242646452281,-75.18963753480327 39.9453053567411,-75.1827381744444 39.94999710874933,-75.17982384046026 39.95517578837672,-75.20600373034293 39.95881534639412,-75.20631097406593 39.95762627319954))'),4326) as bbox
  on ST_Within(u.the_geom,bbox)
  where name = 'University of Pennsylvania'
), penn_campus as (
  select ST_ConvexHull(ST_Union(the_geom)) as hull
  from penn_properties
)
select count(*) as count_block_groups
  from penn_campus as p
  join census_block_groups as c
  on ST_Contains(p.hull, c.the_geom)
