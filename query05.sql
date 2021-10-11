/**
5. Rate neighborhoods by their bus stop accessibility for wheelchairs. 
Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset 
from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) 
for help. Use some creativity in the metric you devise in rating neighborhoods. Describe your 
accessibility metric:

  **Description:**

I started by download neighborhoods_philadelphia from OpenDataPhilly
and used python to import into postgis and created a `neighborhoods_philadelphia` table.

My accessibility metric is going to be composed of two measures:
1) the percentage of bus stops within a neighborhood that are wheelchair accessible 
2) the density of bus stops within the neighborhood (eg. 0.8 stops / 100m^2).

This second measure is important to include given that most neighborhoods
have near 100% wheelchair accessible bus stops. The theory is that if a a neighborhood
is dense with bus stops then they are easier to travel to and use by people.

The score is calculated by multiplying these two values together, and then multiplying
this by a factor of 10 to get a human-friendly score.


--

Example: Rittenhouse (Accessibility score of 67.71)
1) 96.1% – 103 bus stops of which 99 are wheelchair accessible
2) .000007 - 103 bus stops across 14,620,958 square meters (about 5.65 square miles)

**/


