-- create an external table using the green taxi trip records data for 2022
CREATE OR REPLACE EXTERNAL TABLE `fleet-furnace-412302.ny_taxi.external_green_taxi_2022`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://mage-zoomcamp-rebekam/green_taxi_2022/green_tripdata_2022-*.parquet']
);


-- create a table in BQ using the green taxi trip records data for 2022 (do not partition or cluster this table)
CREATE OR REPLACE TABLE `fleet-furnace-412302.ny_taxi.green_taxi_2022_non_partitoned` AS
SELECT *
FROM `fleet-furnace-412302.ny_taxi.external_green_taxi_2022`;


-- what is the count of records in 2022 green taxi trip records data?
-- answer = 840402
SELECT COUNT(*) FROM `fleet-furnace-412302.ny_taxi.green_taxi_2022_non_partitoned`;


-- write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables. what is the estimated amount of data that will be read when this query is executed on the external table and the materialized table?
-- answer = 0 MB for the external table and 6.41 MB for the materialized table
SELECT COUNT(DISTINCT PULocationID) FROM `fleet-furnace-412302.ny_taxi.external_green_taxi_2022`;

SELECT COUNT(DISTINCT PULocationID) FROM `fleet-furnace-412302.ny_taxi.green_taxi_2022_non_partitoned`;


-- how many records have a fare_amount of 0?
-- answer = 1622
SELECT COUNT(*)
FROM `fleet-furnace-412302.ny_taxi.green_taxi_2022_non_partitoned`
WHERE fare_amount = 0;


-- create a table from external table to partition by lpep_pickup_datetime and cluster on PUlocationID
CREATE OR REPLACE TABLE `fleet-furnace-412302.ny_taxi.green_taxi_2022_partitoned_clustered`
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY PUlocationID AS
SELECT *
FROM `fleet-furnace-412302.ny_taxi.external_green_taxi_2022`;


-- write a query to retrieve the distinct PULocationID between lpep_pickup_datetime 06/01/2022 and 06/30/2022 (inclusive) using the non-partitioned table and the partitioned table
-- answer = 12.82 MB for non-partitioned table and 1.12 MB for the partitioned table
SELECT COUNT(DISTINCT PULocationID)
FROM `fleet-furnace-412302.ny_taxi.green_taxi_2022_non_partitoned`
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';

SELECT COUNT(DISTINCT PULocationID)
FROM `fleet-furnace-412302.ny_taxi.green_taxi_2022_partitoned_clustered`
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';


-- Write a SELECT count(*) query FROM the materialized table you created. how many bytes does it estimate will be read? why?
-- answer = 0 B, this is because BigQuery does not scan the actual data at all and rather uses metadata to get the count of rows
SELECT COUNT(*) FROM `fleet-furnace-412302.ny_taxi.green_taxi_2022_non_partitoned`;