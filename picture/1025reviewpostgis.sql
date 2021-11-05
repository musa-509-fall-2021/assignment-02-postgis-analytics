-- What are the 5 closest business to the Graduate School of Education building
  --(3700 Walnut St) that aren't owned by the Trustees of UPenn?
select *
from phl_business_licenses
where not (legalname like '%UNIV%' and legalname like '%TRUS%')
order by the_geom <-> st_setsrid(st_makepoint(-75.1972559094429, 39.95324269431504), 4326)
limit 5

--Create a query that returns all of the business in Philadelphia along with
--the name of the neighborhood the business is in.

 classical examples:
 with phl_business_licenses_by_neighborhood as (
  select
    n.name,
    count(*) as num_business_licenses
  from phl_business_licenses b
  join neighborhoods_philadelphia n
  on st_contains(n.the_geom, b.the_geom)
  group by n.name
)

select n.*, b.num_business_licenses
from phl_business_licenses_by_neighborhood b
join neighborhoods_philadelphia n
on n.name = b.name


with station_demand as (
  select
    start_station as id,
    count(*) as number_of_trips_started
  from indego_trips_2021_q1
  group by start_station
)

select
  s.cartodb_id,
  s.the_geom,
  s.the_geom_webmercator,
  s.id,
  s.name,
  d.number_of_trips_started
from station_demand d
join indego_station_statuses s on d.id = s.id
