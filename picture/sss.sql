
​
-- Septa Bus Routes --
​
-- Add geometry field to bus routes data --

​
-- Edit block group shp geom column name & set its crs --

​table new as(
  select column_name,
  column_name_from_b/sum(columnname) as new_column_name
  from table_a as a
  join table_b as b
  on (a.columnx=b.columny)
  group by column_name
)



​
--ALTER TABLE neighborhoods_philadelphia RENAME COLUMN geom to the_geom;
UPDATE neighborhoods_philadelphia SET the_geom = ST_Transform(ST_SetSRID(the_geom, 4326),32129);
​
-- Create spatial indices --
