/** 
7. What are the _bottom five_ neighborhoods according to your accessibility metric?

  **Both #6 and #7 should have the structure:**
  ```sql
  (
    neighborhood_name text,  -- The name of the neighborhood
    accessibility_metric ...,  -- Your accessibility metric value
    num_bus_stops_accessible integer,
    num_bus_stops_inaccessible integer
  )
  ```
**/

with bus_stop_geom as (		
select stop_id, stop_name, wheelchair_boarding, ST_SetSRID(ST_Point(stop_lon, stop_lat),4326) AS geometry
	from septa_bus_stops
),
bus_stop_neighborhoods as (
select *
	from neighborhoods_philadelphia as n
	join bus_stop_geom as b on
	ST_Within(
		ST_Transform(b.geometry, 32129),
		ST_Transform(n.geometry, 32129)
	)
),
total_stops_per_neighborhood as (
	select n."NAME", COUNT(n.stop_id) as total_count
	from bus_stop_neighborhoods as n
	group by n."NAME"
),
wheelchair_stops_per_neighborhood as (
	select n."NAME", COUNT(n.stop_id) as accessible_count
	from bus_stop_neighborhoods as n
	where n.wheelchair_boarding = 1
	group by n."NAME"
),
base_metrics as (
	select n."NAME", wheelchair.accessible_count as num_bus_stops_accessible, (total.total_count - wheelchair.accessible_count) as num_bus_stops_inaccessible, (wheelchair.accessible_count/(total.total_count*1.0)) as percent_accessible, (total.total_count/n."Shape_Area")*100000 as stop_density
	from neighborhoods_philadelphia as n
	join total_stops_per_neighborhood as total using("NAME")
	join wheelchair_stops_per_neighborhood as wheelchair using("NAME")
)
select b."NAME" as neighborhood_name, (stop_density*percent_accessible)*100 as accessibility_metric, num_bus_stops_accessible, num_bus_stops_inaccessible
from base_metrics as b
order by accessibility_metric asc
limit 5