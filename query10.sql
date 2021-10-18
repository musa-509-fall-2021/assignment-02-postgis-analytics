/*
  You're tasked with giving more contextual information to rail stops
  to fill the stop_desc field in a GTFS feed. Using any of the data 
  sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), 
  and PostgreSQL string functions, build a description (alias as 
  stop_desc) for each stop. Feel free to supplement with other datasets 
  (must provide link to data used so it's reproducible), and other 
  methods of describing the relationships. PostgreSQL's CASE statements 
  may be helpful for some operations.
*/

/* 
More descriptive data available from SEPTA Open Data portal :
https://septaopendata-septa.opendata.arcgis.com/datasets/SEPTA::septa-regional-rail-stations/about

Using ST_Azimuth, I will also get the compass heading of the stop relative from Suburban Station.

Example:

stop_id stop_name stop_desc
90526	  Ambler	  On the Lansdale Doylestown Line, with a waiting shelter, with 588 parking spaces, 17.2 miles from Suburban Station heading NW
*/

with septarrd as (
  select *,
    degrees(ST_Azimuth(ST_GeomFromText('POINT(-75.16736180199008 39.95419945463934)'), ST_Point(longitude,latitude))) angle
  from septa_rrd
),
septarrd_desc as (
  SELECT Stop_ID,
  case 
    when line_name = 'Joint' then
      'On a trunk line'
    else 'On the ' || line_name
  end
  || ', ' ||
  case
    when passenger_shelter = 'Yes' then
      'with a waiting shelter'
    else 'without a waiting shelter'
  end
  || ', ' ||
  case
    when number_of_daily_parking_spaces != 'N/A' then
      concat('with ',number_of_daily_parking_spaces,' parking spaces')
    else 'with no parking spaces'
  end
  ||
  case
    when station_name != 'Suburban Station' then
      ', ' || mile_post || ' miles from Suburban Station'
    else ''
  end
  ||
  case
      when angle between   0.0 and  22.5 then ' heading N'
      when angle between  22.5 and 112.5 then ' heading NE'
      when angle between 112.5 and 157.5 then ' heading E'
      when angle between 157.5 and 202.5 then ' heading SE'
      when angle between 202.5 and 247.5 then ' heading S'
      when angle between 247.5 and 292.5 then ' heading SW'
      when angle between 292.5 and 337.5 then ' heading W'
      when angle between 337.5 and 360.0 then ' heading NW'
  end stop_desc
  from septarrd
)
select r.stop_id,r.stop_name,d.stop_desc,r.stop_lat,r.stop_lon,r.zone_id,r.stop_url
  from septa_rail_stops r
  join septarrd_desc d
  on (r.stop_id = d.Stop_ID)
