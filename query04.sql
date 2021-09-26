select shape_id trip_headsign,
    st_length(
        st_makeline(
            the_geom
            order by shape_pt_sequence
        )
    ) trip_length
from septa_bus_shapes
group by shape_id
limit 5