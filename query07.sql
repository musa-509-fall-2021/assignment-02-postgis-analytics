with stops as (
    select stop_id, wheelchair_boarding, the_geom
    from septa_bus_stops
),
nbh_with_wcb_stops as(
    select listname neighborhood_name, 
        wheelchair_boarding,
        n.the_geom
    from neighborhood n 
    join stops s
    on st_contains(n.the_geom, s.the_geom)
),
nbh_grouped as (
    select neighborhood_name,
        count(*) filter (where wheelchair_boarding = 1) num_bus_stops_accessible,
        count(*) filter (where wheelchair_boarding = 2) num_bus_stops_inaccessible,
        st_area(the_geom) area_m2
    from nbh_with_wcb_stops
    group by neighborhood_name,the_geom
)
select neighborhood_name,
    num_bus_stops_accessible/area_m2 accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
from nbh_grouped
order by accessibility_metric limit 5;