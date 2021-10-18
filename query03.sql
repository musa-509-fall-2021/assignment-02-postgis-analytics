/*
 Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
 pair each parcel with its closest bus stop. The final result should give the:
 1. parcel address, 
 2. bus stop name, and 
 3. distance apart in meters. 
 Order by distance (largest on top).
 */
CREATE INDEX phl_parcels__geometry__32129__idx 
  ON phl_parcels 
  USING GiST (st_transform(the_geom, 32129));

SELECT
  parcels.address AS address,
  bus_stops.stop_name AS stop_name,
  -- get distance in meters by transforming to SRID 32129 
  ST_Distance(
    st_transform(bus_stops.the_geom, 32129),
    st_transform(parcels.the_geom, 32129)
  ) AS distance_m
FROM
  phl_parcels AS parcels 
  -- cycles each parcel row (LATERAL) over all bus_stops (CROSS JOIN)
  -- sorts the cross joined parcel row and all bus stops by distance (<->)
  -- only returns the closest distance (LIMIT 1) that is on the top
  CROSS JOIN LATERAL (
    SELECT
      stop_id,
      the_geom,
      stop_name
    FROM
      septa_bus_stops
    ORDER BY
      st_transform(parcels.the_geom, 32129) < -> st_transform(septa_bus_stops.the_geom, 32129)
    LIMIT
      1
  ) AS bus_stops;

-- based my query off of Carto's Nearest Neighbor tutorial
-- https://carto.com/blog/lateral-joins/

-- address text,  -- The address of the parcel
-- stop_name text,  -- The name of the bus stop
-- distance_m double precision  -- The distance apart in meters