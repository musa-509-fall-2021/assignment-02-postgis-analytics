/*
10.You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed.
Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), 
and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. 
Feel free to supplement with other datasets (must provide link to data used so it's reproducible), 
and other methods of describing the relationships. PostgreSQL's CASE statements may be helpful for some operations.
As an example, your stop_desc for a station stop may be something like "37 meters NE of 1234 Market St" (that's only an example, feel free to be creative, silly, descriptive, etc.)
*/

alter table septa_bus_stops
    add column geom_32129 geometry(Point, 32129);
update septa_bus_stops
    set geom_32129 = ST_Transform(ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326), 32129);


alter table universities
    add column geom_32129 geometry(MultiPolygon, 32129);
update universities
    set geom_32129 = ST_Transform(the_geom, 32129);

create index septa_bus_stops__geom_32129__idx
    on septa_bus_stops
    using gist (geom_32129);
create index universities__geom_32129__idx
    on universities
    using gist (geom_32129);

with
stop_infos as (
    select
        s.*,
        closest_university_area.address,
        closest_university_area.direction_r,
        closest_university_area.distance_m,
        ST_SetSRID(ST_MakePoint(s.stop_lon, s.stop_lat), 4326) as stop_geom,
        closest_university_area .the_geom as university_geom
    from septa_bus_stops as s
    cross join lateral (
        select
            address,
            st_azimuth(st_centroid(u.geom_32129), s.geom_32129) as direction_r,
            st_distance(u.geom_32129, s.geom_32129) as distance_m,
            the_geom
        from universities as u
        order by u.geom_32129 <-> s.geom_32129
        limit 1
    ) as closest_university_area  
)

select
    stop_id,
    stop_name,
    'You can find stop #' || stop_id || ' a distance of ' || round(distance_m::numeric, 2) || ' meters to the ' || case
        when direction_r < pi() / 8 then 'east'
        when direction_r < 3 * pi() / 8 then 'north-east'
        when direction_r < 5 * pi() / 8 then 'north'
        when direction_r < 7 * pi() / 8 then 'north-west'
        when direction_r < 9 * pi() / 8 then 'west'
        when direction_r < 11 * pi() / 8 then 'south-west'
        when direction_r < 13 * pi() / 8 then 'south'
        when direction_r < 15 * pi() / 8 then 'south-east'
        else 'east'
    end || ' of ' || address as stop_desc,
    stop_lon,
    stop_lat
from stop_infos