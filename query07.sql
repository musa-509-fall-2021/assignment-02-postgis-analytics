with neighborhood_acc_count as (
	SELECT p.listname neighborhood_name, p.shape_area,
       count(*) filter(where wheelchair_boarding = 1) as num_bus_stops_accessible,
       count(*) filter(where wheelchair_boarding = 2) as num_bus_stops_inaccessible
    FROM neighborhoods_philadelphia as p
    JOIN septa_bus_stops as s
    ON ST_Contains(ST_transform(p.geom, 32129), s.the_geom)
GROUP BY 1,2)

select neighborhood_name, num_bus_stops_accessible, num_bus_stops_inaccessible,
       (num_bus_stops_accessible/(num_bus_stops_inaccessible+1))/shape_area as accessibility_metric
	   FROM neighborhood_acc_count
	   ORDER BY accessibility_metric 
	   ASC
	   LIMIT 5

/*
  Southwest Schuylkill, 
  Cedar Park, 
  Paschall, 
  Bartram Village, 
  Woodland Terrace
*/