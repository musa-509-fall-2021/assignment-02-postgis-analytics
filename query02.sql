
alter table septa_bus_stops
    add column if not exists the_geom geometry(Point, 4326);


update septa_bus_stops
  set the_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);


create index if not exists septa_bus_stops__the_geom__32129__idx
    on septa_bus_stops
    using GiST (ST_Transform(the_geom, 32129));
