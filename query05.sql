/*
 Rate neighborhoods by their bus stop accessibility for wheelchairs. 
 Use Azavea's neighborhood dataset from OpenDataPhilly 
 along with an appropriate dataset from the Septa GTFS bus feed. 
 Use the GTFS documentation for help. Use some creativity in the 
 metric you devise in rating neighborhoods. Describe your accessibility 
 metric: */

ALTER TABLE neighborhoods_philadelphia
	ALTER COLUMN geom
	TYPE Geometry(MultiPolygon, 32129) 
	USING ST_Transform(geom, 32129);

UPDATE septa_bus_stops
SET wheelchair_boarding = (case 
							when wheelchair_boarding = 1 then 1
                            else 0
                            end);


with access_stats as (
SELECT s.stop_name, s.wheelchair_boarding, n.name
FROM septa_bus_stops as s
JOIN neighborhoods_philadelphia as n
on ST_Contains(n.geom, s.the_geom)
),

access_stats_rating as(
SELECT name, 
COUNT (wheelchair_boarding) as number_of_stops,
SUM (wheelchair_boarding) as num_bus_stops_accesible,
(AVG (wheelchair_boarding))*100 as percent_stops_accesible
FROM access_stats
group by name
order by percent_stops_accesible DESC
)


SELECT * 
INTO access_rating
FROM  access_stats_rating;

ALTER TABLE access_rating
ADD COLUMN accessibility_rating text,
ADD COLUMN num_bus_stops_inaccesible numeric;

UPDATE access_rating
SET num_bus_stops_inaccesible = (number_of_stops - num_bus_stops_accesible );

UPDATE access_rating
SET accessibility_rating= (case 
							when percent_stops_accesible > 99 then 'Good'
							when percent_stops_accesible < 75 AND > 49 then 'Fair'
              when perecent_stops_accesible < 50 AND > 0 then 'Fair'
                            else 'Not Accesible'
                            end);

				
SELECT name as neighborhood_name, 
accessibility_rating, 
percent_stops_accesible, 
num_bus_stops_accesible,
num_bus_stops_inaccesible
FROM access_rating


--------------------------------------
/* Good = 100% of stops have a wheelchair boarding code of 1, meaning in very limited terms that 
the stop is accesible. 

Here's what SEPTA says counts as accesible: 

        "For parentless stops:
        0 or empty - No accessibility information for the stop.
        1 - Some vehicles at this stop can be boarded by a rider in a wheelchair.
        2 - Wheelchair boarding is not possible at this stop.

        For child stops:
        0 or empty - Stop will inherit its wheelchair_boarding behavior from the parent station, if specified in the parent.
        1 - There exists some accessible path from outside the station to the specific stop/platform.
        2 - There exists no accessible path from outside the station to the specific stop/platform."

Fair = anywhere between 50% to 75% of stops in the neighborhood have a wheelchair boarding code of 1. 
Poor = Less than 50%, more than 0 of stops in a neighborhood have a wheelchair boarding code of 1. 
Not Accesible = no stops in the neighborhood are wheelchair accesible

This rating system is not great, and is limited by SEPTA's description of what is 'wheelchair accesible'. 
For example, if only some vehicles at a stop are accesible to wheelchair, how would you plan for that if 
you needed that feature?
The rating system also does not take into account other accessibility concerns both mobile and other, 
such as design of directional signs -- whether they're offered in different languages or are accesible
to riders who are blind or low vision.

---------------------------------------

