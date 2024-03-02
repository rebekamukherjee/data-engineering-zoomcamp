# Spark

Apache Spark is an open-source multi-language unified analytics engine for large-scale data processing.
- Spark is an engine because it processes data.
- Spark can be ran in clusters with multiple nodes, each pulling and transforming data.
- Spark is multi-language because we can use Java and Scala natively, and there are wrappers for Python, R and other languages. The wrapper for Python is called PySpark.

Spark can be used to execute both batch and streaming jobs. A streaming job is essentially a sequence of small batch jobs.

### When to use Spark?

Spark is used for processing data in a Data Lake.

![spark workflow](res/spark-workflow.png)

There are tools such as Hive, Presto or Athena that allow us to express jobs as SQL queries. If a batch job can be expressed with SQL, then these tools should be used.

However, there are times where we need to apply more complex manipulation which are very difficult or even impossible to express with SQL. In these instances, Spark is the tool to use.

## Installation (Windows)

### Install Java

Download **Java** from: https://www.java.com/en/
- Spark runs on Java 8/7/11
- Install JRE-8 and change the destination folder to `C:\jre-8`
- Add a new **System Variable**
    - Variable name = `JAVA_HOME`
    - Variable value = `C:\jre-8`
- Check that Java works correctly by running `java -version` in the command prompt
    - We should see version `1.8.0`
- Run the command `echo %JAVA_HOME%` to see the location of Java

### Install Hadoop

- Create a folder `C:\hadoop-3.0.0\bin`
- Download `winutils.exe` and `hadoop.dll` from: https://github.com/steveloughran/winutils/blob/master/hadoop-3.0.0/bin/ and save it in the folder
- Add a new **System Variable**
    - Variable name = `HADOOP_HOME`
    - Variable value = `C:\hadoop-3.0.0`
- Edit the **User Variable** `Path`
    - Add a new value `%HADOOP_HOME%\bin`

### Install Spark

- Create a folder `C:\spark`
- Navigate to this folder in Git Bash and download Spark by running: `curl -LfO https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz`
- Untar the file by running `tar xzfv spark-3.3.2-bin-hadoop3.tgz`
- Add a new **System Variable**
    - Variable name = `SPARK_HOME`
    - Variable value = `C:\spark\spark-3.3.2-bin-hadoop3`
- Edit the **User Variable** `Path`
    - Add a new value `%SPARK_HOME%\bin`
- To test the installation, navigate to `spark-3.3.2-bin-hadoop3` directory
    - Run `./bin/spark-shell.cmd`
    - Then run the following code:
    ```scala
    val data = 1 to 10000
    val distData = sc.parallelize(data)
    distData.filter(_ < 10).collect()
    ```

Testing did not work in Git Bash but it did in Command Prompt.

![spark install test](res/spark-install-test.png)

### Install PySpark

- Run `pip install pyspark` or `pipenv install pyspark`

## Spark Basics

We will import `pyspark` in a jupyter notebook to learn how to use Spark.

### Creating a Spark session

`SparkSession` is an object that is used for interacting with Spark.

```python
spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()
```
- `SparkSession` is the class of the object that we instantiate. `builder` is the builder method.
- `master()` sets the Spark master URL to connect to. The `local` string means that Spark will run on a local cluster. `[*]` means that Spark will run with as many CPU cores as possible.
- `appName()` defines the name of our application/session. This will show in the Spark UI.
- `getOrCreate()` will create the session or recover the object if it was previously created.

Once we've instantiated a session, we can access the Spark UI by navigating to `localhost:4040` in a web browser. The UI will display all current jobs. Since we've just created the instance, there should be no jobs currently running.

### Reading CSV files

Download the High Volume For-Hire Vehicle Trip Records for January 2021 dataset from here: https://github.com/DataTalksClub/nyc-tlc-data/releases/tag/fhvhv. Then, unzip the CSV file.

In GitBash run the command `wc -l fhvhv_tripdata_2021-01.csv` to check the number of rows in the file. It should be 11908469 rows.

To read the CSV file, run the following code in the jupyter notebook:

```python
df = spark.read \
    .option("header", "true") \
    .csv('fhvhv_tripdata_2021-01.csv')
```
- `read()` reads the file.
- `option()` contains options for the `read` method. In this case, we're specifying that the first line of the CSV file contains the column names.
- `csv()` is for reading CSV files.

Spark reads CSV files into dataframes.
- Unlike `pandas`, Spark can handle much bigger datasets but it's unable to infer the datatypes of each column.
- Spark dataframes use custom data types; we cannot use regular Python types.

To check the current schema of the dataframe, we can run `df.schema`. We will notice that the data type of each column is `StringType()`.

We can fix this by using pandas to get the datatypes of the dataset and using that to change the Spark schema. We only need a few rows for pandas to get the datatypes.

To create a smaller dataset run the command `head -n 1001 fhvhv_tripdata_2021-01.csv > head.csv` in GitBash.

We can create a new schema for the spark dataframe by running  `spark.createDataFrame(df_pandas).schema`.

In the example, PULocationID and DOLocationID are of `long` type. We want to use `int` instead because `long` is more inefficient in this case. `int` uses only 4 bytes whereas `long` uses 8 bytes.

We can use `StructType` to define the schema by running the following code:

```python
from pyspark.sql import types

schema = types.StructType([
    types.StructField('hvfhs_license_num', types.StringType(), True),
    types.StructField('dispatching_base_num', types.StringType(), True),
    types.StructField('pickup_datetime', types.TimestampType(), True),
    types.StructField('dropoff_datetime', types.TimestampType(), True),
    types.StructField('PULocationID', types.IntegerType(), True),
    types.StructField('DOLocationID', types.IntegerType(), True),
    types.StructField('SR_Flag', types.StringType(), True)
])

df = spark.read \
    .option("header", "true") \
    .schema(schema) \
    .csv('fhvhv_tripdata_2021-01.csv')
```
- `types` contains all of the available data types for Spark dataframes.
- `True` means the field is nullable.

### Partitioning

A **Spark cluster** is composed of multiple **executors**. Each executor can process data independently in order to parallelize and speed up work.

![spark clusters](res/spark-clusters.png)

In the previous example we read a single large CSV file. A file can only be read by a single executor, which means that the code we've written so far isn't parallelized and thus will only be run by a single executor rather than many at the same time.

In order to solve this issue, we can split a file into multiple chunks so that each executor can process a chunk and have all executors working simultaneously. These splits are called **partitions**.

We will now read the CSV file, partition the dataframe and parquetize it. This will create multiple files in parquet format. Converting to parquet is an expensive operation which may take several minutes.

```python
# create 24 partitions in our dataframe
df = df.repartition(24)

# parquetize and write to 'fhvhv/2021/01/' folder
df.write.parquet('fhvhv/2021/01/')
```
- `repartition()` is a lazy command and does not trigger anything. The partitioning will take place only when we write the dataframe into parquet files.

We can check the Spark UI at any time and see the progress of the current job, which is divided into stages which contain tasks. The tasks in a stage will not start until all tasks on the previous stage are finished.

When creating a dataframe, Spark creates as many partitions as CPU cores available by default, and each partition creates a task. Thus, assuming that the dataframe was initially partitioned into 6 partitions, the `write.parquet()` method will have 2 stages: the first with 6 tasks and the second one with 24 tasks.

Besides the 24 parquet files, we should also see a `_SUCCESS` file which should be empty. This file is created when the job finishes successfully.

Trying to write the files again will output an error because Spark will not write to a non-empty folder. We can force an overwrite with the `mode` argument: `df.write.parquet('fhvhv/2021/01/', mode='overwrite')`

We can read the parquet files by running `df = spark.read.parquet('fhvhv/2021/01/')`. Parquet remembers the data types specified in the schema. We can also run `df.printSchema()` to check the schema.

One of the reasons why parquet files are smaller than CSV files is because they store the data according to the datatypes, so `int` values take less space than `long` or `string` values.

## Spark DataFrames

### DataFrame operations

There are many Pandas-like operations that we can do on Spark dataframes, such as:
- **Column selection**: returns a dataframe with only the specified columns.
    ```python
    new_df = df.select('pickup_datetime', 'dropoff_datetime', 'PULocationID', 'DOLocationID')
    ```
- **Filtering by value**: returns a dataframe whose records match the condition stated in the filter.
    ```python
    new_df = df.select('pickup_datetime', 'dropoff_datetime', 'PULocationID', 'DOLocationID').filter(df.hvfhs_license_num == 'HV0003')
    ```
    - This does not execute unless we also append `.show()` at the end of the code. We should be able to see a new job in the Spark UI.

### Actions vs Transformations

- **Transofrmations**: These are lazy commands. They are not executed right away.
    - `select()`
    - `filter()`
    - `join()`
    - `groupBy()`
    - `repartition()`
    - etc.
- **Actions**: These are eager commands. They are executed immediately. Computations only happen when actions are triggered.
    - `show()`
    - `take()`
    - `head()`
    - `read()`
    - `write()`
    - etc.

```python
df.select('pickup_datetime', 'dropoff_datetime', 'PULocationID', 'DOLocationID') \
  .filter(df.hvfhs_license_num == 'HV0003') \
  .show()
```
- In this example, the whole instruction gets evaluated only when the `show()` action is triggered.

### Functions and User Defined Functions (UDFs)

Spark provides built-in functions that allow for more complex data manipulation.

Here's an example of built-in function usage:
```python
from pyspark.sql import functions as F

df \
    .withColumn('pickup_date', F.to_date(df.pickup_datetime)) \
    .withColumn('dropoff_date', F.to_date(df.dropoff_datetime)) \
    .select('pickup_date', 'dropoff_date', 'PULocationID', 'DOLocationID') \
    .show()
```
- `withColumn()`: adds a new column to the dataframe. Adding a new column with the same name as a previously existing column will overwrite the existing column!
- `select()`: selects the stated columns.
- `F.to_date()`: built-in Spark function that converts a timestamp to date format (year, month and day only, no hour and minute).

Besides these built-in functions, Spark also allows us to create **User Defined Functions** (UDFs) with custom behavior for those instances where creating SQL queries for that behaviour becomes difficult both to manage and test.

UDFs are regular python functions which are then passed as parameters to a special builder.

```python
# create a function
def crazy_stuff(base_num):
    num = int(base_num[1:])
    if num % 7 == 0:
        return f's/{num:03x}'
    elif num % 3 == 0:
        return f'a/{num:03x}'
    else:
        return f'e/{num:03x}'

# convert the function to a user-defined function
crazy_stuff_udf = F.udf(crazy_stuff, returnType=types.StringType())
```
- `F.udf()` can be used to convert a function into a user-defined function. In this example, `crazy_stuff()` is the function and the return type for the function is string.

We can then use the UDF in transformations just like built-in functions:

```python
df \
    .withColumn('pickup_date', F.to_date(df.pickup_datetime)) \
    .withColumn('dropoff_date', F.to_date(df.dropoff_datetime)) \
    .withColumn('base_id', crazy_stuff_udf(df.dispatching_base_num)) \
    .select('base_id', 'pickup_date', 'dropoff_date', 'PULocationID', 'DOLocationID') \
    .show()
```

## Spark SQL

Spark can also run SQL queries.

### Combining two datasets

Load the parquet files for yellow and green taxi data for 2020 and 2021 to Spark dataframes by running the following code:

```python
df_green = spark.read.parquet('data/pq/green/*/*')
df_yellow = spark.read.parquet('data/pq/yellow/*/*')
```
Create two new columns called `pickup_datetime` and `dropoff_datetime` in the two dataframes because the column names are different in each dataframe:

```python
df_green = df_green \
    .withColumnRenamed('lpep_pickup_datetime', 'pickup_datetime') \
    .withColumnRenamed('lpep_dropoff_datetime', 'dropoff_datetime')

df_yellow = df_yellow \
    .withColumnRenamed('tpep_pickup_datetime', 'pickup_datetime') \
    .withColumnRenamed('tpep_dropoff_datetime', 'dropoff_datetime')
```
- `withColumnRenamed(arg1, arg2)` is used to create a new column where `arg1` is the name of the new column and `arg2` is the calculation for the content of the new column.

Create a combined dataframe with the common columns to both datasets:

```python
# find common columns in both dataframes
common_colums = []
yellow_columns = set(df_yellow.columns)
for col in df_green.columns:
    if col in yellow_columns:
        common_colums.append(col)

# select common columns from both dataframes and create a new column called `service_type`
df_green_sel = df_green \
    .select(common_colums) \
    .withColumn('service_type', F.lit('green'))

df_yellow_sel = df_yellow \
    .select(common_colums) \
    .withColumn('service_type', F.lit('yellow'))

# combine both the dataframes into one dataframe
df_trips_data = df_green_sel.unionAll(df_yellow_sel)
```
- `F.lit()` adds a literal or constant to a dataframe. We use it here to fill the `service_type` column with a constant value, which is its corresponding taxi type.

Now we can count the amount of records per taxi type by running the following code:

```python
df_trips_data.groupBy('service_type').count().show()
```

### Querying a dataset with Temporary Tables

SQL expects a table for retrieving records, but a dataframe is not a table. We need to register a dataframe as a table first by running the following code:

```python
df_trips_data.registerTempTable('trips_data')
```
- This method creates a temporary table with the name `trips_data`.

We can now perform regular SQL operations:

```python
spark.sql("""
SELECT
    service_type,
    count(1)
FROM
    trips_data
GROUP BY 
    service_type
""").show()
```
- This query outputs the same result as `df_trips_data.groupBy('service_type').count().show()`
- The query output can be manipulated as a dataframe, which means that we can perform any queries on our table and manipulate the results with Python as we see fit.

We can also write more complex queries as the following:

```python
df_result = spark.sql("""
SELECT 
    -- Reveneue grouping 
    PULocationID AS revenue_zone,
    date_trunc('month', pickup_datetime) AS revenue_month, 
    service_type, 

    -- Revenue calculation 
    SUM(fare_amount) AS revenue_monthly_fare,
    SUM(extra) AS revenue_monthly_extra,
    SUM(mta_tax) AS revenue_monthly_mta_tax,
    SUM(tip_amount) AS revenue_monthly_tip_amount,
    SUM(tolls_amount) AS revenue_monthly_tolls_amount,
    SUM(improvement_surcharge) AS revenue_monthly_improvement_surcharge,
    SUM(total_amount) AS revenue_monthly_total_amount,
    SUM(congestion_surcharge) AS revenue_monthly_congestion_surcharge,

    -- Additional calculations
    AVG(passenger_count) AS avg_montly_passenger_count,
    AVG(trip_distance) AS avg_montly_trip_distance
FROM
    trips_data
GROUP BY
    1, 2, 3
""")
```
- SQL queries are transformations, so we need an action to perform them such as `df_result.show()`.

We can also store the results as a parquet file just like any other dataframe by running the following code:

```python
df_result.write.parquet('data/report/revenue/')
```
- This will create more than 200 parquet files of very small size, which isn't very desirable.
- In order to reduce the amount of files, we need to reduce the amount of partitions of the dataset. This can be done with the `coalesce()` method:

```python
df_result.coalesce(1).write.parquet('data/report/revenue/', mode='overwrite')
```
- This reduces the number of partitions to just 1.

## Spark Internals

### Anatomy of a Spark Cluster

Until now we have only used a local cluster (`LOCAL[*]`) to run Spark.

Spark clusters often contain multiple computers that behave as **executors**. Spark clusters are managed by a **master**. A **driver** sends a Spark job to the master. A driver can be an Airflow job, a computer running a local script, etc. The master divides the work among the executors. If any executor fails and becomes offline, the master reassigns the task to another executor.

Each executor fetches a **dataframe partition** stored in a data lake (S3, GCS), processes the data, and then store it back in the data lake or somewhere else. If there are more partitions than executors, executors keep fetching partitions until every single one has been processed.

![spark anatomy](res/spark-anatomy.png)

This is in contrast to [Hadoop](https://hadoop.apache.org/), another data analytics engine, whose executors locally store the data they process. Partitions in Hadoop are duplicated across several executors for redundancy and in case an executor fails. Hadoop is meant for clusters made of commodity hardware computers. However, data locality has become less important as storage and data transfer costs have dramatically decreased. Thus nowadays it's feasible to separate storage from computation and Hadoop has become less popular.

### GroupBy in Spark

The following query calculates the total revenue and amount of trips per hour per zone. This is done by performing a `GROUP BY hour, zone`.

```python
# load green taxi trip data parquet files
df_green = spark.read.parquet('data/pq/green/*/*')

# register green taxi trip dataframe as a table
df_green.registerTempTable('green')

# execute a group by
df_green_revenue = spark.sql("""
SELECT 
    date_trunc('hour', lpep_pickup_datetime) AS hour, 
    PULocationID AS zone,

    SUM(total_amount) AS amount,
    COUNT(1) AS number_records
FROM
    green
WHERE
    lpep_pickup_datetime >= '2020-01-01 00:00:00'
GROUP BY
    1, 2
""")

# display the query results
df_green_revenue.show()
```

Since the data is split along partitions, it's likely that Spark will need to group data which are in separate partitions. We know from the previous section that executors only deal with individual partitions. Spark solves this issue by separating the grouping in 2 stages.

In the first stage, each executor groups the results in the partition they're working on and outputs the results to a temporary partition. These temporary partitions are the **intermediate results**.

![spark groupby stage 1](res/spark-groupby-stage1.png)

In the second stage, the data goes through **reshuffling**. Spark puts all records with the same **keys** into the same partition. In this example, the keys are `hour` and `zone`. The algorithm to do this is called **external merge sort**. Once reshuffling is completed, Spark applies `GROUP BY` to the new partitions and **reduces** the records to the final output. The reshuffled partitions may contain more than one key, but all records belonging to a key should end up in the same partition.

![spark groupby stage 2](res/spark-groupby-stage2.png)

Running the code should display the following DAG in the Spark UI:

![spark groupby stages](res/spark-groupby-stages.png)
- The `Exchange` task refers to the reshuffling.

If we were to add sorting to the query by adding `ORDER BY 1,2` at the end, Spark would perform a very similar operation to `GROUP BY` after grouping the data. The resulting DAG will look liked this in the Spark UI:

![spark groupby orderby stages](res/spark-groupby-orderby-stages.png)

By default, Spark repartitions the dataframe into 200 partitions after reshuffling the data. This is fine for large datasets, but this could be counterproductive in small datasets (our example) because of the small size of each partition/file.

Repartitioning also involves reshuffling data.

Reshuffling is an **expensive operation**, so it is in our best interest to reduce the amount of data to shuffle when querying.

### Joins in Spark

#### Joining two large tables

To perform an outer join on two dataframes, run the following code:

```python
# read green and yellow revenue report parquet files
df_green_revenue = spark.read.parquet('data/report/revenue/green')
df_yellow_revenue = spark.read.parquet('data/report/revenue/yellow')

# add the service type as a prefix to 'amount' and 'number_records' fields in both dataframes
df_green_revenue_tmp = df_green_revenue \
    .withColumnRenamed('amount', 'green_amount') \
    .withColumnRenamed('number_records', 'green_number_records')

df_yellow_revenue_tmp = df_yellow_revenue \
    .withColumnRenamed('amount', 'yellow_amount') \
    .withColumnRenamed('number_records', 'yellow_number_records')

# join both the dataframes on 'hour' and 'zone' fields
df_join = df_green_revenue_tmp.join(df_yellow_revenue_tmp, on=['hour', 'zone'], how='outer')

# display the joined dataframe
df_join.show()
```
Running the code should display the following DAG in the Spark UI:

![spark join large tables stages](res/spark-join-large-tables-stages.png)
- In the first stage, `df_green_revenue_tmp` is created
- In the second stage, `df_yellow_revenue_tmp` is created
- In the third stage, the outer join is performed

Given all records for yellow taxis `Y1, Y2,... Yn` and for green taxis `G1, G2,... Gn` and knowing that the resulting composite key is `key K = (hour H, zone Z)`, we can express the resulting complex records as `(Kn, Yn)` for yellow records and `(Kn, Gn)` for green records.

Spark performs a **reshuffle** on the data using **external merge sort**. Then it performs a **reduce** on the records by consolidating the records for yellow and green data with the same key to show the final output.

![spark joins](res/spark-joins.png)
- When the operation is an **outer join**, keys which only have yellow taxi or green taxi records will be shown with empty fields for the missing data and keys with both types of records will show both yellow and green taxi data.
- When the operation is an **inner join**, only the keys with both types of records will be shown. This means  records such as `(K1, Y1, Ø)` and `(K4, Ø, G3)` would be excluded from the final result.

#### Joining a large table and a small table

To join a small table and a large table, run the following code:

```python
# read joined revenue report
df_join = spark.read.parquet('data/report/revenue/total')

# read taxi zones data
df_zones = spark.read.parquet('data/zones/')

# join both the dataframes on Zone ID
df_result = df_join.join(df_zones, df_join.zone == df_zones.LocationID)

# display the joined dataframe
df_result.drop('LocationID', 'zone').show()
```
- The default join type in Spark SQL is the inner join.
- Since we renamed the `LocationID` in the joined table to `zone`, we can't simply specify the columns to join and we need to provide a condition as criteria.
- We use the `drop()` method to get rid of the extra columns we don't need anymore.

Running the code should display the following DAG in the Spark UI:

![spark join small large tables stages](res/spark-join-small-large-tables-stages.png)

Since the `zones` table is very small, joining both tables with merge sort is unnecessary. What Spark does instead is called **broadcasting**. Spark sends a copy of the complete table to all of the executors and each executor then joins each partition of the big table in memory by performing a lookup on the local broadcasted table.

Reshuffling isn't necessary because each executor already has all of the necessary information to perform the join on each partition, thus speeding up the join operation by orders of magnitude.

![spark join broadcasting](res/spark-join-broadcasting.png)

## Running Spark on Google Cloud Platform

### Connecting to Google Cloud Storage

#### Uploading files to GCP using `gsutil`

We will use `gsutil` to upload our local files into our Data Lake. `gsutil` is included with the GCP SDK, so we should already have it from the previous modules.

To upload the parquet files in the `code/7_spark/data/pq/` folder into GCS, run the following command from the `code/7_spark` folder in Git Bash:

```bash
gsutil -m cp -r data/pq/ gs://mage-zoomcamp-rebekam/pq
```
- `-m` option is for enabling multithreaded upload in order to speed it up
- `cp` is for copying files
- `-r` stands for recursive; it's used to state that the contents of the local folder are to be uploaded. For single files this option isn't needed.

#### Configuring Spark with the GCS connector

Download the connector from the [Google's Cloud Storage Connector](https://cloud.google.com/dataproc/docs/concepts/connectors/cloud-storage#non-clusters) website into a folder called `lib` in the working directory by running the following command in Git Bash:

```bash
gsutil cp gs://hadoop-lib/gcs/gcs-connector-hadoop3-2.2.5.jar lib/gcs-connector-hadoop3-2.2.5.jar
```
- We are using version 2.5.5 for Hadoop 3 in this lesson.

Now, run the following code in a jupyter notebook to configure Spark by creating a configuration object:

```python
# import libraries
from pyspark.sql import SparkSession
from pyspark.conf import SparkConf
from pyspark.context import SparkContext

# configure Spark by creating a configuration object
credentials_location = 'C:/Users/rebek/.google/credentials/google_credentials.json'

conf = SparkConf() \
    .setMaster('local[*]') \
    .setAppName('test') \
    .set("spark.jars", "./lib/gcs-connector-hadoop3-2.2.5.jar") \
    .set("spark.hadoop.google.cloud.auth.service.account.enable", "true") \
    .set("spark.hadoop.google.cloud.auth.service.account.json.keyfile", credentials_location)
```

Before we implicitly created a **context**, which represents a connection to a spark cluster. Now we need to explicitly create and configure the context by running the following code:

```python
sc = SparkContext(conf=conf)

hadoop_conf = sc._jsc.hadoopConfiguration()

hadoop_conf.set("fs.AbstractFileSystem.gs.impl",  "com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS")
hadoop_conf.set("fs.gs.impl", "com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem")
hadoop_conf.set("fs.gs.auth.service.account.json.keyfile", credentials_location)
hadoop_conf.set("fs.gs.auth.service.account.enable", "true")
```

Finally, instantiate a Spark session:

```python
spark = SparkSession.builder \
    .config(conf=sc.getConf()) \
    .getOrCreate()
```

#### Reading the remote data

We can now read the parquet files stored in the Data Lake using Spark by using the bucket URI as a parameter:

```python
# read parquet files from the data lake into a spark dataframe
df_green = spark.read.parquet('gs://mage-zoomcamp-rebekam/pq/green/*/*')

# display the spark dataframe
df_green.show()
```

### Creating a Local Spark Cluster

#### Spark standalone master and workers

Until now we have been creating a local Spark cluster and connecting to it using the following code. However, once the notebook kernel is shut down, the cluster disappears.

```python
spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()
```
To keep a cluster running even after notebook in which it was created is stopped, we need to learn how to create a Spark cluster in [Standalone Mode](https://spark.apache.org/docs/latest/spark-standalone.html).

To setup Spark standalone mode on Windows:
- Open a CMD terminal and navigate to the location of Spark `C:\spark\spark-3.3.2-bin-hadoop3`
    - Start a master node by running: `bin\spark-class org.apache.spark.deploy.master.Master`
    - Navigate to `localhost:8080` to see the Spark UI. There should not be any workers visible.
    - Copy the Spark address that looks like `spark://<master_ip>:<port>` for the next step.
- Open another CMD terminal and navigate to the location of spark
    - Start a worker node by running: `bin\spark-class org.apache.spark.deploy.worker.Worker spark://192.168.1.12:7077`
    - Alternatively we could try to run the following command but it may not run: `bin\spark-class org.apache.spark.deploy.worker.Worker spark://localhost:7077`
    - We can append `--host <IP_ADDR>` at the end of the previous command if we want to run the worker on a different machine. For now we can leave it empty.
    - Now we should be able to see a worker added to the Spark UI.

> We use port 8080 to access the Spark UI and we use port 7077 for connecting our code to the cluster.

Now we can modify the Spark Session code to the following code and run any operations that we have already learned:

```python
spark = SparkSession.builder \
    .master("spark://192.168.1.12:7077") \
    .appName('test') \
    .getOrCreate()
```

A worker may not be able to run multiple jobs simultaneously. If we are running separate notebooks and connecting to the same Spark worker, we can the number of application that are running in the Spark UI. Since we haven't configured the workers, jobs will take as many resources as there are available to it.

#### Parameterizing the script

We can convert a jupyter notebook into a python script using `nbconvert` by running the following code: `jupyter nbconvert --to=script pyspark_standalone.ipynb`

Then, we can use the `argparse` library to pass arguments as parameters to the script.

```python
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--input_green', required=True)
parser.add_argument('--input_yellow', required=True)
parser.add_argument('--output', required=True)

args = parser.parse_args()
input_green = args.input_green
input_yellow = args.input_yellow
output = args.output
```

Next, we can modify the code using the parameters that we have created:

```python
df_green = spark.read.parquet(input_green)
df_yellow = spark.read.parquet(input_yellow)

...

df_result.coalesce(1) \
    .write.parquet(output, mode='overwrite')
```

Finally, we can run the script from the terminal along with the parameters as follows:

```bash
python pyspark_standalone.py \
    --input_green=data/pq/green/2020/*/ \
    --input_yellow=data/pq/yellow/2020/*/ \
    --output=data/report-2020
```

#### Submitting Spark jobs with Spark submit

We can also parameterize the script to input
- the cluster URL when having multiple available clusters
- the number of workers to use for the job

We can use an external script called [spark submit](https://spark.apache.org/docs/latest/submitting-applications.html) to do this instead of specifying these parameters when setting up the session inside the script.

We can parameterize the script to input the cluster URL when having multiple available clusters by modifying the following code:

```python
spark = SparkSession.builder \
    .appName('test') \
    .getOrCreate()
```

We can use `spark-submit` to run the script by running the following command in Git Bash:

```bash
spark-submit \
    --master="spark://192.168.1.12:7077" \
    pyspark_standalone.py \
        --input_green=data/pq/green/2020/*/ \
        --input_yellow=data/pq/yellow/2020/*/ \
        --output=data/report-2020
```

Once we are done running Spark in standalone mode, we will need to manually shut it down by entering `Ctrl+c` in both the CMD terminals for master and worker.

### Setting up a Dataproc Cluster

#### Creating the cluster

**Dataproc** is Google's cloud-managed service for running Spark and other data processing tools.

Navigate to Google Cloud Platform console and search for `dataproc`. The first time we access this, it will ask us to enable to API which we can do by clicking on the `ENABLE` button.

![spark dataproc enable](res/spark-dataproc-enable.png)

Next, click on `CREATE CLUSTER` > `Cluster on Compute Engine` > `CREATE`
- Cluster Name = `de-zoomcamp-cluster`
- Region = `us-west2` (same as bucket)
- Zone = `Any`
- Cluster type = `Single Node`
- Optional components = `Jupyter Notebook`, `Docker`

Now if we search for `vm instances` in Google Cloud Platform console, we should be able to see a new Virtual Machine instance called `de-zoomcamp-cluster-m`. We can connect to it if we want to connect to master UI, but we do not need to connect to it now.

#### Running a job with the web UI

Dataproc is already configured to use Google Cloud Storage so we do not need to configure it with code like we did [previously](#configuring-spark-with-the-gcs-connector).

Make sure the PySpark script `pyspark_standalone.py` does not include `master` because we want to make sure the job uses the configuration from Dataproc in order to correctly assign the master. The SparkSession should look like this:

```python
spark = SparkSession.builder \
    .appName('test') \
    .getOrCreate()
```

In Google Cloud Storage, create a folder called `code` in the bucket and upload `pyspark_standalone.py` by running the following command in Git Bash from the working directory: `gsutil cp pyspark_standalone.py gs://mage-zoomcamp-rebekam/code/`

Click on the cluster > `SUBMIT JOB` button > `SUBMIT`
- Job tpe = `PySpark`
- Main python file = `gs://mage-zoomcamp-rebekam/code/pyspark_standalone.py`
- Arguments =
    - `--input_green=gs://mage-zoomcamp-rebekam/pq/green/2021/*/`
    - `--input_yellow=gs://mage-zoomcamp-rebekam/pq/yellow/2021/*/`
    - `--output=gs://mage-zoomcamp-rebekam/report-2021`

We can check the status of the job in the `Job details` page. Once the job has finished running we should be able to see something like the following line in the output: `GoogleCloudStorageFileSystem: Successfully repaired 'gs://mage-zoomcamp-rebekam/report-2021/' directory.`

Now if we refresh our GCS bucket we should be able to see the folder `report-2021` with the output parquet file.

#### Running a job with the gcloud SDK

There are 3 ways of submitting jobs to a Dataproc cluster:
1. Web UI
2. Google Cloud SDK
3. REST API

In order to submit a job through **gcloud SDK**, we will need to grant certain permission to the service account that we have been using so far.

Navigate to **IAM & Admin** in the Google Cloud console and add `Dataproc Administrator` role to the service account.

Now, we can submit a job from the command line by running the following code:

```bash
gcloud dataproc jobs submit pyspark \
    --cluster=de-zoomcamp-cluster \
    --region=us-west2 \
    gs://mage-zoomcamp-rebekam/code/pyspark_standalone.py \
    -- \
        --input_green=gs://mage-zoomcamp-rebekam/pq/green/2020/*/ \
        --input_yellow=gs://mage-zoomcamp-rebekam/pq/yellow/2020/*/ \
        --output=gs://mage-zoomcamp-rebekam/report-2020
```

Now if we refresh our GCS bucket we should be able to see the folder `report-2020` with the output parquet file.

### Connecting Spark to BigQuery

We can use the BigQuery connector with Spark with [this example](https://cloud.google.com/dataproc/docs/tutorials/bigquery-connector-spark-example#pyspark).

Create a new python script called `pyspark_bigquery.py` and copy the contents of `pyspark_standalone.py` into it.

After creating the Spark Session, add a line to create a temporary GCS bucket. We can use the temporary GCS bucket that Dataproc created.

```python
spark = SparkSession.builder \
    .appName('test') \
    .getOrCreate()

spark.conf.set('temporaryGcsBucket', 'dataproc-temp-us-west2-297549834165-ty8oagby')
```

Then, replace the following code:
```python
df_result.coalesce(1) \
    .write.parquet(output, mode='overwrite')
```

with:
```python
df_result.write.format('bigquery') \
    .option('table', output) \
    .save()
```

Upload `pyspark_bigquery.py` by running the following command in Git Bash from the working directory: `gsutil cp pyspark_bigquery.py gs://mage-zoomcamp-rebekam/code/`

Now, we can submit a job from the command line by running the following code:

```bash
gcloud dataproc jobs submit pyspark \
    --cluster=de-zoomcamp-cluster \
    --region=us-west2 \
    --jars=gs://spark-lib/bigquery/spark-bigquery-latest_2.12.jar \
    gs://mage-zoomcamp-rebekam/code/pyspark_bigquery.py \
    -- \
        --input_green=gs://mage-zoomcamp-rebekam/pq/green/2020/*/ \
        --input_yellow=gs://mage-zoomcamp-rebekam/pq/yellow/2020/*/ \
        --output=trips_data_all.reports-2020
```

Now if we navigate to BigQuery and hit refresh we should be able to see a table called `report-2020` under the `trips_data_all` schema.

If we run the following SQL query in BigQuery we should be able to see the data in `report-2020`.

```sql
SELECT * FROM `fleet-furnace-412302.trips_data_all.reports-2020` LIMIT 10;
```