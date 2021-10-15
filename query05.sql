-- data: stops.txt - wheelchair_boarding - 0(ukn/inherit),1(yes),2(no)

create index phl_neighborhood_geo_index 
on neighborhood 
using gist (the_geom);


with bus as (
    select wheelchair_boarding, 
        the_geom, stop_id
    from septa_bus_stops
),

neighborhood_bus_grouped as (
    select name,
        sum(case wheelchair_boarding when 2 then 1 else 0 end) wb_num,
        count(*) total_num,
        st_area(n.the_geom)/1e6 area  -- m^2 to km^2
    from neighborhood n
    join bus b on st_within(b.the_geom, n.the_geom)
    group by 1, n.the_geom
)

select name,
    wb_num ^ 2 / area / total_num score 
from neighborhood_bus_grouped
order by 2 desc