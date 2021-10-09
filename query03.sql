/**
3. Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with 
its closest bus stop.  The final result should give the parcel address, bus stop name, 
and distance apart in
meters. Order by distance (largest on top).

  **Structure:**
  ```sql
  (
      address text,  -- The address of the parcel
      stop_name text,  -- The name of the bus stop
      distance_m double precision  -- The distance apart in meters
  )
  ```
**/


-- take the parcels geometry and join it to the bus stop data
-- using ST_Nearest to find the nearest bus stop
-- Then use ST_Distance to calculate the distance between the parcels
-- center and the bus stop X, Y
-- then order by distance descending