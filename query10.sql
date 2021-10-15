/* 
data source: https://www.pasda.psu.edu/uci/DataSummary.aspx?dataset=7021

stop_desc demo: 
There are 6 park(s) within 1.5km of this stop, at the 33th percentile among the park number of all stops. And here are 3 of them which is/are the closest. :) 

1. Nicetown Park at 4369-71 GERMANTOWN AVE which is 847m N (10 mins walk) of the stop.
2. Fernhill Park at 4600 MORRIS ST which is 1128m W (14 mins walk) of the stop.
3. Hunting Park at 1101 W HUNTING PARK AVE which is 1237m NE (15 mins walk) of the stop.
*/

CREATE index park_geom_index
on park_phl
using gist(the_geom);

with stops as (
    SELECT stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        the_geom
    from septa_bus_stops 
),

crossjoined_nearest_parks as (
    SELECT stop_id joined_stop_id,
        park,
        address,
        round(distance) distance,
        count(*) over (PARTITION by stop_id) park_num,
        -- getting the orientation of the park
        case 
            when angle between   0.0 and  22.5 then 'N'
            when angle between  22.5 and 112.5 then 'NE'
            when angle between 112.5 and 157.5 then 'E'
            when angle between 157.5 and 202.5 then 'SE'
            when angle between 202.5 and 247.5 then 'S'
            when angle between 247.5 and 292.5 then 'SW'
            when angle between 292.5 and 337.5 then 'W'
            when angle between 337.5 and 360.0 then 'NN'
        end orientation
    from stops s
    cross join LATERAL(
        select name park,
            address,
            s.the_geom<->p.the_geom distance,
            degrees(ST_Azimuth(s.the_geom,p.the_geom)) angle
        from park_phl p
        where s.the_geom<->p.the_geom < 1500
        order by 3
        --limit 3
    ) nearest_parks
),

processed_parks as(
    select stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        c.*,
        case when park_num is not null then
            round(PERCENT_RANK() OVER (order by park_num)*100)
        end percentile,
        NTH_VALUE(park, 1) OVER w park1,
        NTH_VALUE(distance, 1) OVER w distance1,
        NTH_VALUE(address, 1) OVER w address1,
        NTH_VALUE(orientation, 1) OVER w orientation1,

        NTH_VALUE(park, 2) OVER w park2,
        NTH_VALUE(distance, 2) OVER w distance2,
        NTH_VALUE(address, 2) OVER w address2,
        NTH_VALUE(orientation, 2) OVER w orientation2,

        NTH_VALUE(park, 3) OVER w park3,
        NTH_VALUE(distance, 3) OVER w distance3,
        NTH_VALUE(address, 3) OVER w address3,
        NTH_VALUE(orientation, 3) OVER w orientation3
    from stops
    left join crossjoined_nearest_parks c
        on stop_id = joined_stop_id
    WINDOW w AS (partition by stop_id order by distance 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
)

select distinct on (stop_id)
    stop_id,
    stop_name,
    stop_lon,
    stop_lat,
    case 
        when park_num is null then
            'There are no parks within 1.5km of this stop, at the 0th percentile among the park number of all stops. :('
        else
            Format('There are %s park(s) within 1.5km of this stop, at the %sth percentile among the park number of all stops. And here are %s of them which is/are the closest. :) \n', park_num, percentile,least(3,park_num)) 
            || 
            -- the nearest park (if exists)
            case 
                when park_num >= 1 THEN
                    Format('1. %s at %s which is %sm %s (%s mins walk) of the stop.\n',park1,address1,distance1,orientation1,round(distance1/83))
                else ''
            end
            || 
            -- the 2nd nearest park (if exists)
            case 
                when park_num >= 2 THEN
                    Format('2. %s at %s which is %sm %s (%s mins walk) of the stop.\n',park2,address2,distance2,orientation2,round(distance2/83))
                else ''
            end
            || 
            -- the 3rd nearest park (if exists)
            case 
                when park_num >= 3 THEN
                    Format('3. %s at %s which is %sm %s (%s mins walk) of the stop.',park3,address3,distance3,orientation3,round(distance3/83))
                else ''
            end
    end stop_desc
from processed_parks;