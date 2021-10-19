/* 
  What are the top five neighborhoods according to your accessibility metric? 
*/

-- create a geometry column with longitude and latitude for septa_bus_stops
alter table septa_bus_stops
    add column if not exists geometry geometry(Point, 4326);

update septa_bus_stops
  set geometry = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);

-- create geometry indexes
create index if not exists septa_bus_stops__the_geom__32129__idx
    on septa_bus_stops
    using GiST (ST_Transform(geometry, 32129));

create index if not exists neighborhoods_philadelphia__geometry__32129__idx
    on neighborhoods_philadelphia
    using GiST (ST_Transform(geometry, 32129));
    
-- define any stops that intersects the neighborhood 500m buffer contribute to that beighborgood
-- count all the stops within 200m of each neighborhood
with septa_bus_stop_neighborhoods_200m as (
    select
        n.name,
        count(*)::float as stops_200m
    from septa_bus_stops as s
    join neighborhoods_philadelphia as n
        on ST_DWithin(
            ST_Transform(n.geometry, 32129),
            ST_Transform(s.geometry, 32129),
            200
        )
    group by n.name
),
-- count stops with wheelchair boarding within 200m of each neighborhood
bus_stop_with_wheelchair_boarding_neighborhoodsas as (
    select
        n.name,
        count(*)::float as stops_with_wheelchair_boarding_200m
    from septa_bus_stops as s
    join neighborhoods_philadelphia as n
        on ST_DWithin(
            ST_Transform(n.geometry, 32129),
            ST_Transform(s.geometry, 32129),
            200
        )
    where wheelchair_boarding = 1
    group by n.name
)

-- accessibility_metric, num_bus_stops_accessible and num_bus_stops_inaccessible
select 
    a.name as neighborhood_name,
    a.stops_with_wheelchair_boarding_200m / b.stops_200m * 100 as accessibility_metric,
    a.stops_with_wheelchair_boarding_200m::integer as num_bus_stops_accessible,
    (b.stops_200m - a.stops_with_wheelchair_boarding_200m)::integer as num_bus_stops_inaccessible
from bus_stop_with_wheelchair_boarding_neighborhoodsas as a
join septa_bus_stop_neighborhoods_200m as b
on a.name = b.name
-- order by accessibility_metric first, and the by num_bus_stops_accessible
order by 
    accessibility_metric desc,
    num_bus_stops_accessible desc
limit 5;