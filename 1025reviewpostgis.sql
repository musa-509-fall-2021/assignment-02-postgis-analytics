-- What are the 5 closest business to the Graduate School of Education building
  --(3700 Walnut St) that aren't owned by the Trustees of UPenn?
select *
from phl_business_licenses
where not (legalname like '%UNIV%' and legalname like '%TRUS%')
order by the_geom <-> st_setsrid(st_makepoint(-75.1972559094429, 39.95324269431504), 4326)
limit 5

--Create a query that returns all of the business in Philadelphia along with
--the name of the neighborhood the business is in.
