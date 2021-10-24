/* 6. What are the top five neighborhoods according to your accessibility metric?

This query provides not only the four neighborhoods that have 'Poor' wheelchair accessibility rating, 
but it also provides the neighborhood rated "Fair" that has theleast number of stops. 
Though this doesn't take into account the geographic size of each neighborhood,
it begins to account for SETPA's limited determination of 'wheelchair accesbility' as outlined in Query 05.
 */

SELECT name as neighborhood_name, 
accessibility_rating, 
percent_stops_accesible, 
num_bus_stops_accesible,
num_bus_stops_inaccesible
FROM access_rating
WHERE accessibility_rating = 'Poor' OR accessibility_rating ='Fair'
ORDER BY accessibility_rating DESC, num_bus_stops_accesible ASC
LIMIT 5
/* RESULT: 
bartram-village
woodland-terrace
southwest-schuykill
paschall
haverford-north
*/