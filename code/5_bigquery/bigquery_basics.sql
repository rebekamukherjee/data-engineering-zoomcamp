-- querying publicly available data
SELECT station_id, name
FROM `bigquery-public-data.new_york_citibike.citibike_stations`
LIMIT 100;


-- creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `fleet-furnace-412302.ny_taxi.external_yellow_tripdata`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://mage-zoomcamp-rebekam/nyc_taxi_data/tpep_pickup_date=2021-*/7e7ee24868404f349eea3e7bbe9bf16c-0.parquet']
);


-- check yellow trip data
SELECT * FROM `fleet-furnace-412302.ny_taxi.external_yellow_tripdata` limit 10;


-- create a non-partitioned table from external table
CREATE OR REPLACE TABLE `fleet-furnace-412302.ny_taxi.yellow_tripdata_non_partitoned` AS
SELECT *,
DATE(TIMESTAMP_MICROS(CAST (tpep_pickup_datetime/1000 AS INT64))) AS tpep_pickup_date
FROM `fleet-furnace-412302.ny_taxi.external_yellow_tripdata`;


-- create a partitioned table from external table
CREATE OR REPLACE TABLE `fleet-furnace-412302.ny_taxi.yellow_tripdata_partitoned`
PARTITION BY
  tpep_pickup_date AS
SELECT *,
DATE(TIMESTAMP_MICROS(CAST (tpep_pickup_datetime/1000 AS INT64))) AS tpep_pickup_date
FROM `fleet-furnace-412302.ny_taxi.external_yellow_tripdata`;


-- impact of partitioning
-- 18.99 MB
SELECT DISTINCT(VendorID)
FROM `fleet-furnace-412302.ny_taxi.yellow_tripdata_non_partitoned`
WHERE tpep_pickup_date BETWEEN '2021-01-01' AND '2021-01-30';

-- 18.55 MB
SELECT DISTINCT(VendorID)
FROM `fleet-furnace-412302.ny_taxi.yellow_tripdata_partitoned`
WHERE tpep_pickup_date BETWEEN '2021-01-01' AND '2021-01-30';


-- take a closer look into the partitons
SELECT table_name, partition_id, total_rows
FROM `ny_taxi.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'yellow_tripdata_partitoned'
ORDER BY total_rows DESC;


-- create a partition and cluster table from external table
CREATE OR REPLACE TABLE `fleet-furnace-412302.ny_taxi.yellow_tripdata_partitoned_clustered`
PARTITION BY tpep_pickup_date
CLUSTER BY VendorID AS
SELECT *,
DATE(TIMESTAMP_MICROS(CAST (tpep_pickup_datetime/1000 AS INT64))) AS tpep_pickup_date
FROM `fleet-furnace-412302.ny_taxi.external_yellow_tripdata`;


-- impact of clustering
-- 18.55 MB
SELECT count(*) as trips
FROM `fleet-furnace-412302.ny_taxi.yellow_tripdata_partitoned`
WHERE tpep_pickup_date BETWEEN '2021-01-01' AND '2021-01-30'
  AND VendorID=1;

-- 17.75 MB
SELECT count(*) as trips
FROM `fleet-furnace-412302.ny_taxi.yellow_tripdata_partitoned_clustered`
WHERE tpep_pickup_date BETWEEN '2021-01-01' AND '2021-01-30'
  AND VendorID=1;