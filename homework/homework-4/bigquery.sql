-- creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `fleet-furnace-412302.trips_data_all.fhv_taxi_external`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://mage-zoomcamp-rebekam/dbt_datasets/fhv_taxi/fhv_tripdata_2019-*.parquet']
);

-- create a non-partitioned table from external table
CREATE OR REPLACE TABLE `fleet-furnace-412302.trips_data_all.fhv_taxi` AS
SELECT
  pulocationid,
  dolocationid,
  cast(timestamp_micros(cast (pickup_datetime/1000 as INT64)) as date) as pickup_date,
  cast(timestamp_micros(cast (pickup_datetime/1000 as INT64)) as timestamp) as pickup_datetime,
  cast(timestamp_micros(cast (pickup_datetime/1000 as INT64)) as timestamp) as dropoff_datetime,
  dispatching_base_num as dispatching_base_number,
  affiliated_base_number,
  sr_flag
FROM `fleet-furnace-412302.trips_data_all.fhv_taxi_external`
WHERE pulocationid != '' AND dolocationid != '';

-- check monthly counts in `fhv_taxi` table
select DISTINCT
  DATE_TRUNC(pickup_date, MONTH) AS month,
  COUNT(*)
from `fleet-furnace-412302.trips_data_all.fhv_taxi`
GROUP BY 1;

-- check total count in `fact_fhv_trips` table
SELECT COUNT(*)
FROM `fleet-furnace-412302.dbt_rmukherjee.fact_fhv_trips`;

-- check July 2019 counts in `fact_fhv_trips` table (FHV: 290680)
SELECT DATE_TRUNC(pickup_datetime, MONTH) as month, COUNT(*)
FROM `fleet-furnace-412302.dbt_rmukherjee.fact_fhv_trips`
WHERE DATE_TRUNC(pickup_datetime, MONTH) = '2019-07-01'
GROUP BY 1;

-- check July 2019 counts by service in `fact_trips` table (Green: 397683, Yellow: 3244706)
SELECT DATE_TRUNC(pickup_datetime, MONTH) as month, service_type, COUNT(*)
FROM `fleet-furnace-412302.dbt_rmukherjee.fact_trips`
WHERE DATE_TRUNC(pickup_datetime, MONTH) = '2019-07-01'
GROUP BY 1, 2;