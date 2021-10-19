alter table septa_bus_stops
    add column geom_32129 geometry(Point, 32129);
update septa_bus_stops
    set geom_32129 = ST_Transform(ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326), 32129);

-- Add a column on phl_pwd_parcels for the geometry transformed into 32129; the
-- geometry field in my parcels table is named "the_geom"
alter table universities
    add column geom_32129 geometry(MultiPolygon, 32129);
update universities
    set geom_32129 = ST_Transform(geom, 32129);

-- Add indexes on both 32129 geometry fields
create index septa_bus_stops__geom_32129__idx
    on septa_bus_stops
    using gist (geom_32129);
create index universities__geom_32129__idx
    on universities
    using gist (geom_32129);
	
with stop_infos as (
    select
        s.*,
        closest_university.address,
        closest_university.direction_r,
        closest_university.distance_m,
        ST_SetSRID(ST_MakePoint(s.stop_lon, s.stop_lat), 4326) as stop_geom,
        closest_university.the_geom as university_geom
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
    ) as closest_university  
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

/*
returned with 
  stop_id     stop_name                           stop_desc
1 39	"20th St & Johnston St "	"You can find stop #39 a distance of 1035.48 meters to the south-west of 2301 S BROAD ST"
2 40	"20th St & Johnston St"	        "You can find stop #40 a distance of 1029.98 meters to the south-west of 2301 S BROAD ST"
3 41	"16th St & Snyder Av"	        "You can find stop #41 a distance of 413.02 meters to the south-east of 2301 S BROAD ST"
4 42	"16th St & Washington Av"	"You can find stop #42 a distance of 352.40 meters to the south-east of 1212-14 S BROAD ST"
5 43	"16th St & Pine St "	        "You can find stop #43 a distance of 109.42 meters to the south of 1500-02 PINE ST"
6 ...
...
*/
