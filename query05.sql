/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs. 
  Use Azavea's neighborhood dataset from OpenDataPhilly along with an 
  appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation 
  for help. Use some creativity in the metric you devise in rating neighborhoods. 
*/


/* 
First metric is percentage of wheelchair-accessible stops as defined through GTFS.

Second metric is percentage walkability to transit, averaged from census tracts, as
defined by DVRPC Equity through Access study
DVRPC Equity Through Access Dataset:
https://dvrpc-dvrpcgis.opendata.arcgis.com/datasets/dvrpcgis::greater-philadelphia-equity-through-access-priority-score/about

Third metric is geographic density of 311 complaints related to dangerous
sidewalks or construction site hazards. This is subtracted from the product
of the other two metrics as a penalty, up to around 25 percentage points
311 complaint API call:
https://phl.carto.com/api/v2/sql?q=SELECT%20*%20FROM%20public_cases_fc%20WHERE%20service_name%20IN%20
(%27Dangerous%20Sidewalk%27,%20%27Construction%20Complaints%27,%20%27Construction%20Site%20Task%20Force%27,%20%27Right%20of%20Way%20Unit%27)

*/

alter table phl_nbhds
    add column if not exists the_geom geometry(MultiPolygon, 4326);

update phl_nbhds
  set the_geom = ST_Multi(ST_GeomFromEWKB(wkb_geometry));

alter table complaints
    add column if not exists geom geometry(Point, 4326);

update complaints
  set geom = ST_SetSRID(ST_MakePoint(lon, lat), 4326);

alter table dvrpc_eta
    add column if not exists the_geom geometry(MultiPolygon, 4326);

update dvrpc_eta
  set the_geom = ST_Multi(ST_GeomFromEWKB(wkb_geometry));

create table if not exists septa_stop_access as (
with wb as (
  select n.name as neighborhood_name, n.the_geom,
    sum(case wheelchair_boarding when 1 then 1 else 0 end) as num_bus_stops_accessible,
    sum(case when wheelchair_boarding in (null,0,2) then 1 else 0 end) as num_bus_stops_inaccessible,
    cast(sum(case wheelchair_boarding when 1 then 1 else 0 end) as float) /
    cast(count(*) as float) as pct_wb
    from phl_nbhds n
    join septa_bus_stops b
    on st_within(b.the_geom,n.the_geom)
    group by 1,2
),
wb_complaint as (
  select w.neighborhood_name, w.the_geom, w.num_bus_stops_accessible, w.num_bus_stops_inaccessible, w.pct_wb,
    cast(count(*) as int) / ST_Area(ST_Transform(w.the_geom,32129)) * 1e6 as denscomplaint
    from wb w
    join complaints c
    on st_within(c.geom,w.the_geom)
    group by 1,2,3,4,5
),
wb_eta as (
  select w.neighborhood_name, w.the_geom, w.num_bus_stops_accessible, w.num_bus_stops_inaccessible, w.pct_wb, w.denscomplaint, avg(ta_walk) as ta_walk
    from wb_complaint w
    join dvrpc_eta d
    on st_within(d.the_geom,w.the_geom)
    group by 1,2,3,4,5,6
)
select neighborhood_name, num_bus_stops_accessible, num_bus_stops_inaccessible,
  pct_wb * ta_walk - denscomplaint/1200*25 as accessibility_metric
  from wb_eta
)

select * from septa_stop_access
