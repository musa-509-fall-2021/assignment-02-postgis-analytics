/* 
2. Which bus stop has the smallest population within 800 meters?
Answer: Charter Rd & Norcom Rd has the smallest population with only 2.
*/

with septa_bus_stop_block_groups as (
    select
        s.stop_id,
        '1500000US' || bg.geoid10 as geo_id
    from septa_bus_stops as s
    join census_block_groups as bg
        on ST_DWithin(
            ST_Transform(s.the_geom, 32129),
            ST_Transform(bg.geom, 32129),
            800
        )
	),
	
	septa_bus_stop_surrounding_population as (
		select stop_id,
    	sum(total) as estimated_pop_800m
    	from septa_bus_stop_block_groups as s
    	join census_population as p on geo_id=id
    	group by stop_id
		)
	select
	    stop_name,
	    estimated_pop_800m,
	    the_geom
	from septa_bus_stop_surrounding_population
	join septa_bus_stops using (stop_id)
	order by estimated_pop_800m asc
	limit 1