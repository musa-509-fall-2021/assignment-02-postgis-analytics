/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs. Use Azavea's neighborhood dataset from
  OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for
  help. Use some creativity in the metric you devise in rating neighborhoods. Describe your accessibility metric:
*/


/*Answer: Sum all the 1 of "wheelchair_boarding" column in "septa_bus_stops" table of each neighborhood.