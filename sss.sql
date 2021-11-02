
​
-- Septa Bus Routes --
​
-- Add geometry field to bus routes data --

​
-- Edit block group shp geom column name & set its crs --

​

​
--ALTER TABLE neighborhoods_philadelphia RENAME COLUMN geom to the_geom;
UPDATE neighborhoods_philadelphia SET the_geom = ST_Transform(ST_SetSRID(the_geom, 4326),32129);
​
-- Create spatial indices --
