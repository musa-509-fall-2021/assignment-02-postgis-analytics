/* 
  With a query, find out how many census block groups Penn's 
  main campus fully contains. Discuss which dataset you chose 
  for defining Penn's campus.
 */

-- create 2 geometry indexes
create index if not exists census_block_groups__geometry__idx
    on census_block_groups
    using GiST (geometry);

create index if not exists universities_colleges__geometry__idx
    on universities_colleges
    using GiST (geometry);

-- creat a boxing limit to trim within main campus (There are many UPenn buildings out of the main campus)
with main_campus_boxing as (
  select st_setsrid(
    st_makepolygon(
      ST_GeomFromText('LINESTRING(-75.18730911869268 39.960649063055286, -75.21136578537576 39.959328781392465, -75.21231365265601 39.94123637041499, -75.19711981216236 39.94023670765296, -75.17528781693402 39.952589260645354, -75.18730911869268 39.960649063055286)')
    ),
    4326
  ) as geometry
),
-- select buildings belong to Upenn, trim into main campus and make a boundary of Upenn main campus
penn as (
  select ST_Envelope(
    ST_Union(uc.geometry)
  ) as boundary
  from universities_colleges as uc
  join main_campus_boxing as cb
  on ST_Intersects(uc.geometry, cb.geometry)
  where name like 'University of Pennsylvania'
)
-- count census block groups that are fully contained by Upenn main campus boundary
select count(*)::integer as count_block_groups
from penn as p
join census_block_groups as bg
on ST_Contains(p.boundary,bg.geometry);

