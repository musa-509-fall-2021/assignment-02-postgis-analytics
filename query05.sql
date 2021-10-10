-- 5. Rate neighborhoods by their bus stop accessibility for wheelchairs. 
-- Use Azavea's neighborhood dataset from OpenDataPhilly along with an appropriate dataset from the Septa GTFS bus feed. 
-- Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. 
-- Use some creativity in the metric you devise in rating neighborhoods. Describe your accessibility metric:

--   **Description:**
-- The basic measure of accessibility is the equation  A_i= ∑ O_j  *  d_ij^(-b) (where X_y denotes that y is a subscript of X)
-- The equation describes the accessibility of an individual where the accessibility of the individual, A_i, 
-- is calculated by finding the sum of all quality opportunities (such as jobs),  
-- O_j, multiplied by the separation of those opportunities from the individual’s starting location, 
-- d_ij – which can be measured in distance, time, or a monetary cost, exponentiated by the degree to which accessibility to that opportunity declines with increasing separation.

-- Job opportunities will be substituted for parcels (potential dwellings) -> (O_j)
-- A rule-of-thumb used by transportation planners is that people are generally willing to walk up to 0.5 miles to access transit.
-- Since we are measuring wheelchair accessibility, we will measure the number of opportunities  within 0.2 miles (322 meters) of each wheelchair accessible bus stop -> (d_ij)

-- This index will be aggregated at the neighborhood level, and paired with a count of the wheelchair accessible stops in each neighborhood.

select * from pwd_parcels