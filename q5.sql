with bus_stops_accessible as (
     select
        stop_name,
        wheelchair_boarding,
        the_geom
    from septa_bus_stops),
	
	bus_neighbors as (
	 select ph.name, ph.geom, bs.wheelchair_boarding,
	        ST_AREA(ph.geom) as area_size
     from phl_neighborhoods as ph
	 join septa_bus_stops as bs
	 on st_Within(ST_Transform(ph.geom,4326), ST_Transform(bs.the_geom,4326))),
		
	 bus_access as(
	    select name as neighborhood_name,
               count(*) filter(where wheelchair_boarding = 1) as num_bus_stops_accessible,
			   count(*) filter(where wheelchair_boarding = 2) as num_bus_stops_inaccessible,
			   area_size
		  from bus_neighbors
		  group by neighborhood_name, area_size)
		
select neighborhood_name, num_bus_stops_accessible, num_bus_stops_inaccessible,
       num_bus_stops_accessible/area_size as accessibility_metric
	   from bus_access
