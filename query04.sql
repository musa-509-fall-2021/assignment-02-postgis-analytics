/* 
  Using the shapes.txt file from GTFS bus feed, 
  find the two routes with the longest trips. 
  In the final query, give the trip_headsign 
  that corresponds to the shape_id of this route 
  and the length of the trip. 
*/

-- create a geometry column with longitude and latitude for septa_bus_shapes
alter table septa_bus_shapes
    add column if not exists geometry geometry(Point, 4326);

update septa_bus_shapes
  set geometry = ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat), 4326);

-- change data type of the column shape_id of table septa_bus_trips to ensure we can join table successfully
ALTER TABLE septa_bus_trips ALTER COLUMN shape_id TYPE text;

-- create a geometry index
create index if not exists septa_bus_shapes__geometry__32129__idx
    on septa_bus_shapes
    using GiST (ST_Transform(geometry, 32129));

-- make lines based on t.trip_headsign/shape_id, and measure the distance of each line
select 
    t.trip_headsign,
    ST_Length(
        ST_MakeLine(
            ST_Transform(
                s.geometry,
                32129
            )
        )
    ) as trip_length
from septa_bus_shapes as s
join septa_bus_trips as t
on s.shape_id = t.shape_id
group by t.trip_headsign
order by trip_length desc
limit 2;


