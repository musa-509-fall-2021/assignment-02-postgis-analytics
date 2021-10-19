/* 
  You're tasked with giving more contextual information to rail stops 
  to fill the stop_desc field in a GTFS feed. Using any of the data 
  sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), 
  and PostgreSQL string functions, build a description (alias as stop_desc) 
  for each stop. Feel free to supplement with other datasets (must provide 
  link to data used so it's reproducible), and other methods of describing 
  the relationships. PostgreSQL's CASE statements may be helpful for some 
  operations. 
*/

-- create a geometry column with longitude and latitude for septa_rail_stops
alter table septa_rail_stops
    add column if not exists geometry geometry(Point, 4326);

update septa_rail_stops
  set geometry = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);

-- Add indexes on both 32129 geometry fields
create index if not exists septa_rail_stops__geometry_32129__idx
    on septa_rail_stops
    using gist (ST_Transform(geometry, 32129));

create index if not exists phl_pwd_parcels__geometry_32129__idx
    on phl_pwd_parcels
    using gist (ST_Transform(geometry, 32129));

create index if not exists neighborhoods_philadelphia__geometry_32129__idx
    on neighborhoods_philadelphia
    using gist (ST_Transform(ST_Centroid(geometry), 32129));


-- query stops' info of closet parcels
with stop_desc as (
    select
        s.*,
        closest_parcels.address,
        closest_parcels.direction,
        closest_parcels.distance,
        s.geometry as stop_geom,
        closest_parcels.geometry as parcel_geom
    from septa_rail_stops as s
    cross join lateral (
        select
            address,
            st_azimuth(
                ST_Transform(ST_Centroid(p.geometry),32129), 
                ST_Transform(s.geometry,32129)
            ) as direction,
            st_distance(
                ST_Transform(p.geometry,32129), 
                ST_Transform(s.geometry,32129)
            ) as distance,
            geometry
        from phl_pwd_parcels as p
        order by ST_Transform(p.geometry,32129) <-> ST_Transform(s.geometry,32129)
        limit 1
    ) as closest_parcels
),
-- query stops' info of scope of services
stop_desc2 as(
    select 
        s.stop_id,
        count(*) as num_neighborhood
    from septa_rail_stops as s
    join neighborhoods_philadelphia as n
    on ST_DWithin(
            ST_Transform(s.geometry, 32129),
            ST_Transform(
                ST_Centroid(n.geometry), 
                32129
            ),
            800
        )
    group by s.stop_id
)

-- conbine infos together and make an output 
select
    a.stop_id::integer,
    a.stop_name,
    'You can find stop #' || a.stop_id || ' a distance of ' || round(a.distance::numeric, 2) || ' meters to the ' || case
        when a.direction < pi() / 8 then 'east'
        when a.direction < 3 * pi() / 8 then 'north-east'
        when a.direction < 5 * pi() / 8 then 'north'
        when a.direction < 7 * pi() / 8 then 'north-west'
        when a.direction < 9 * pi() / 8 then 'west'
        when a.direction < 11 * pi() / 8 then 'south-west'
        when a.direction < 13 * pi() / 8 then 'south'
        when a.direction < 15 * pi() / 8 then 'south-east'
        else 'east'
    end || ' of ' || a.address || '. And it serves ' || b.num_neighborhood || ' neighborhoods with a 800m service scope.' as stop_desc,
    a.stop_lon,
    a.stop_lat
from stop_desc as a
join stop_desc2 as b
on a.stop_id = b.stop_id
