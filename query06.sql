/* 6. What are the top five neighborhoods according to your accessibility metric?

This query provides not only neighborhoods that have 'Good' wheelchair accessibility rating, 
but also have the most stops in them. Though this doesn't take into account the geographic size of each neighborhood,
it begins to account for SETPA's limited determination of 'wheelchair accesbility' as outlined in Query 05.
 */

SELECT name as neighborhood_name, 
accessibility_rating, 
percent_stops_accesible, 
num_bus_stops_accesible,
num_bus_stops_inaccesible
FROM access_rating
WHERE accessibility_rating = 'Good'
ORDER BY num_bus_stops_accesible DESC
LIMIT 5

/* RESULT: 
olney
bustleton
somerton
mayfair
oxford-circle
*/