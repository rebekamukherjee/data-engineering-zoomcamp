# Homework 3: Data Warehouse

**Homework submission link**: https://courses.datatalks.club/de-zoomcamp-2024/homework/hw3

**Deadline**: 14 February 2024

## BigQuery

For this homework we will be using the 2022 Green Taxi Trip Record Parquet Files from the New York City Taxi Data found here: https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

If you are using orchestration such as Mage, Airflow or Prefect do not load the data into Big Query using the orchestrator. Stop with loading the files into a bucket.

You will need to use the PARQUET option files when creating an External Table

**SETUP:** 

Create an external table using the Green Taxi Trip Records Data for 2022.

```sql
CREATE OR REPLACE EXTERNAL TABLE `fleet-furnace-412302.ny_taxi.external_green_taxi_2022`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://mage-zoomcamp-rebekam/green_taxi_2022/green_tripdata_2022-*.parquet']
);
```

Create a table in BQ using the Green Taxi Trip Records for 2022 (do not partition or cluster this table).

```sql
CREATE OR REPLACE TABLE `fleet-furnace-412302.ny_taxi.green_taxi_2022_non_partitoned` AS
SELECT *
FROM `fleet-furnace-412302.ny_taxi.external_green_taxi_2022`;
```

### Question 1:

What is count of records for the 2022 Green Taxi Data?

- 65,623,481
- **840,402**    <-- answer
- 1,936,423
- 253,647

**Answer:**

```sql
SELECT COUNT(*) FROM `fleet-furnace-412302.ny_taxi.green_taxi_2022_non_partitoned`;
```

### Question 2:

Write a query to count the distinct number of `PULocationID`s for the entire dataset on both the tables.

What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?

- **0 MB for the External Table and 6.41MB for the Materialized Table**    <-- answer
- 18.82 MB for the External Table and 47.60 MB for the Materialized Table
- 0 MB for the External Table and 0MB for the Materialized Table
- 2.14 MB for the External Table and 0MB for the Materialized Table

**Answer:**

```sql
SELECT COUNT(DISTINCT PULocationID) FROM `fleet-furnace-412302.ny_taxi.external_green_taxi_2022`;

SELECT COUNT(DISTINCT PULocationID) FROM `fleet-furnace-412302.ny_taxi.green_taxi_2022_non_partitoned`;
```

### Question 3:

How many records have a `fare_amount` of 0?

- 12,488
- 128,219
- 112
- **1,622**    <-- answer

**Answer:**

```sql
SELECT COUNT(*)
FROM `fleet-furnace-412302.ny_taxi.green_taxi_2022_non_partitoned`
WHERE fare_amount = 0;
```

### Question 4:

What is the best strategy to make an optimized table in Big Query if your query will always order the results by PUlocationID and filter based on lpep_pickup_datetime? (Create a new table with this strategy)

- Cluster on lpep_pickup_datetime Partition by PUlocationID
- **Partition by lpep_pickup_datetime  Cluster on PUlocationID**    <-- answer
- Partition by lpep_pickup_datetime and Partition by PUlocationID
- Cluster on by lpep_pickup_datetime and Cluster on PUlocationID

**Answer:**

```sql
CREATE OR REPLACE TABLE `fleet-furnace-412302.ny_taxi.green_taxi_2022_partitoned_clustered`
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY PUlocationID AS
SELECT *
FROM `fleet-furnace-412302.ny_taxi.external_green_taxi_2022`;
```

### Question 5:

Write a query to retrieve the distinct PULocationID between lpep_pickup_datetime 06/01/2022 and 06/30/2022 (inclusive)

Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 4 and note the estimated bytes processed. What are these values?

Choose the answer which most closely matches.

- 22.82 MB for non-partitioned table and 647.87 MB for the partitioned table
- **12.82 MB for non-partitioned table and 1.12 MB for the partitioned table**    <-- answer
- 5.63 MB for non-partitioned table and 0 MB for the partitioned table
- 10.31 MB for non-partitioned table and 10.31 MB for the partitioned table

**Answer:**

```sql
SELECT COUNT(DISTINCT PULocationID)
FROM `fleet-furnace-412302.ny_taxi.green_taxi_2022_non_partitoned`
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';

SELECT COUNT(DISTINCT PULocationID)
FROM `fleet-furnace-412302.ny_taxi.green_taxi_2022_partitoned_clustered`
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30';
```

### Question 6: 

Where is the data stored in the External Table you created?

- Big Query
- **GCP Bucket**    <-- answer
- Big Table
- Container Registry

### Question 7:

It is best practice in Big Query to always cluster your data?

- True
- **False**    <-- answer


### (Bonus) Question 8:

No Points: Write a SELECT count(*) query FROM the materialized table you created. How many bytes does it estimate will be read? Why?

**Answer:**

BigQuery estimates that `this query will process 0 B when run`. This is because BigQuery does not scan the actual data at all and rather uses metadata to get the count of rows.

```sql
SELECT COUNT(*) FROM `fleet-furnace-412302.ny_taxi.green_taxi_2022_non_partitoned`;
```