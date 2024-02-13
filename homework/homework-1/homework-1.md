# Homework 1: Introduction & Prerequisites

**Homework submission link**: https://courses.datatalks.club/de-zoomcamp-2024/homework/hw01

**Deadline**: 29 January 2024

## Docker & SQL

In this homework we'll prepare the environment and practice with Docker and SQL

### Question 1: Knowing docker tags

Run the command to get information on Docker `docker --help`

Now run the command to get help on the "docker build" command `docker build --help`

Do the same for "docker run"

Which tag has the following text? *Automatically remove the container when it exits*

- --delete
- --rc
- --rmc
- **--rm**    <-- answer

**Answer:**

*Run `docker run --help`*

### Question 2: Understanding docker first run

Run docker with the python:3.9 image in an interactive mode and the entrypoint of bash. Now check the python modules that are installed (use `pip list`). What is version of the package wheel ?

- **0.42.0**    <-- answer
- 1.0.0
- 23.0.1
- 58.1.0

**Answer:**

*Run `docker run -it --entrypoint=bash python:3.9` followed by `pip list`*

## Prepare Postres

Run Postgres and load data as shown in the videos. We'll use the green taxi trips from September 2019:

`wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz`

You will also need the dataset with zones:

`wget https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv`

Download this data and put it into Postgres (with jupyter notebooks or with a pipeline)

**Answer:**

*Run the following command in the command line*

*`docker run -it -e POSTGRES_USER="root" -e POSTGRES_PASSWORD="root" -e POSTGRES_DB="ny_taxi" -v D:/rebeka/developer/courses/data-engineering-zoomcamp/code/1_docker/ny_taxi_postgres_data:/var/lib/postgresql/data -p 5432:5432 postgres:13`*

*Once it says `database system is ready to accept connections`, run the Python code below*

```python
import pandas as pd
from sqlalchemy import create_engine
from time import time

engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')

green_taxi_trips_url = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz"
df = pd.read_csv(green_taxi_trips_url, nrows=10)
df.head(n=0).to_sql(name='green_taxi_trips', con=engine, if_exists='replace')
df_iter = pd.read_csv(green_taxi_trips_url, iterator=True, chunksize=100000)
while True:
    t_start = time()
    df = next(df_iter)
    df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
    df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)
    df.to_sql(name='green_taxi_trips', con=engine, if_exists='append')
    t_end = time()
    print ('inserted another batch..., took %.3f seconds' % (t_end-t_start))
    if len(df) < 100000:
        break

taxi_zones_url = "https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv"
df = pd.read_csv(taxi_zones_url)
df.to_sql(name='taxi_zone_lookup', con=engine, if_exists='replace')
```

*Exit and stop the container. Then run the `Docker-Compose.yaml` using `docker-compose up` and use PgAdmin GUI to solve the next 3 questions.*

### Question 3: Count records

How many taxi trips were totally made on September 18th 2019?

Tip: started and finished on 2019-09-18.

Remember that lpep_pickup_datetime and lpep_dropoff_datetime columns are in the format timestamp (date and hour+min+sec) and not in date.

- 15767
- **15612**    <-- answer
- 15859
- 89009

**Answer**:

```sql
SELECT COUNT(*)
FROM green_taxi_trips
WHERE DATE(lpep_pickup_datetime)='2019-09-18'
AND DATE(lpep_dropoff_datetime)='2019-09-18'
```

### Question 4: Largest trip for each day

Which was the pick up day with the largest trip distance. Use the pick up time for your calculations.

- 2019-09-18
- 2019-09-16
- **2019-09-26** <-- answer
- 2019-09-21

**Answer**:

```sql
SELECT 
	DATE(lpep_pickup_datetime),
	SUM(trip_distance)
FROM green_taxi_trips
GROUP BY 1
ORDER BY 2 DESC
```

### Question 5: Three biggest pick up Boroughs

Consider lpep_pickup_datetime in '2019-09-18' and ignoring Borough has Unknown

Which were the 3 pick up Boroughs that had a sum of total_amount superior to 50000?

- **"Brooklyn" "Manhattan" "Queens"**    <-- answer
- "Bronx" "Brooklyn" "Manhattan"
- "Bronx" "Manhattan" "Queens"
- "Brooklyn" "Queens" "Staten Island"

**Answer**:

```sql
SELECT
	pickup_tzl."Borough",
	SUM(green_taxi_trips."total_amount")
FROM green_taxi_trips
LEFT JOIN taxi_zone_lookup AS pickup_tzl
	ON pickup_tzl."LocationID" = green_taxi_trips."PULocationID"
WHERE DATE(green_taxi_trips.lpep_pickup_datetime)='2019-09-18'
AND pickup_tzl."Borough" != 'Unknown'
GROUP BY 1
ORDER BY 2 DESC
```

### Question 6: Largest tip

For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip? We want the name of the zone, not the id.

Note: it's not a typo, it's tip , not trip

- Central Park
- Jamaica
- **JFK Airport**    <-- answer
- Long Island City/Queens Plaza

**Answer**:

```sql
SELECT
	dropoff_tzl."Zone",
	green_taxi_trips."tip_amount"
FROM green_taxi_trips
LEFT JOIN taxi_zone_lookup AS pickup_tzl
	ON pickup_tzl."LocationID" = green_taxi_trips."PULocationID"
LEFT JOIN taxi_zone_lookup AS dropoff_tzl
	ON dropoff_tzl."LocationID" = green_taxi_trips."DOLocationID"
WHERE DATE(DATE_TRUNC('month', green_taxi_trips."lpep_pickup_datetime")) = '2019-09-01'
AND pickup_tzl."Zone" = 'Astoria'
ORDER BY 2 DESC
```

## Terraform

In this section we'll prepare the environment by creating resources in GCP with Terraform.

In your VM on GCP/Laptop/GitHub Codespace install Terraform. Copy the files from the course repo [here](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/01-docker-terraform/1_terraform_gcp/terraform) to your VM/Laptop/GitHub Codespace.

Modify the files as necessary to create a GCP Bucket and Big Query Dataset.

### Question 7: Creating Resources

After updating the main.tf and variable.tf files run `terraform apply`

Paste the output of this command into the homework submission form.

**Answer**:

```bash
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_bigquery_dataset.demo_dataset will be created
  + resource "google_bigquery_dataset" "demo_dataset" {
      + creation_time              = (known after apply)
      + dataset_id                 = "demo_dataset"
      + default_collation          = (known after apply)
      + delete_contents_on_destroy = false
      + effective_labels           = (known after apply)
      + etag                       = (known after apply)
      + id                         = (known after apply)
      + is_case_insensitive        = (known after apply)
      + last_modified_time         = (known after apply)
      + location                   = "US"
      + max_time_travel_hours      = (known after apply)
      + project                    = "fleet-furnace-412302"
      + self_link                  = (known after apply)
      + storage_billing_model      = (known after apply)
      + terraform_labels           = (known after apply)
    }

  # google_storage_bucket.demo_bucket will be created
  + resource "google_storage_bucket" "demo_bucket" {
      + effective_labels            = (known after apply)
      + force_destroy               = true
      + id                          = (known after apply)
      + location                    = "US"
      + name                        = "fleet-furnace-412302-terra-bucket"
      + project                     = (known after apply)
      + public_access_prevention    = (known after apply)
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + terraform_labels            = (known after apply)
      + uniform_bucket_level_access = (known after apply)
      + url                         = (known after apply)

      + lifecycle_rule {
          + action {
              + type = "AbortIncompleteMultipartUpload"
            }
          + condition {
              + age                   = 1
              + matches_prefix        = []
              + matches_storage_class = []
              + matches_suffix        = []
              + with_state            = (known after apply)
            }
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_bigquery_dataset.demo_dataset: Creating...
google_storage_bucket.demo_bucket: Creating...
google_bigquery_dataset.demo_dataset: Creation complete after 1s [id=projects/fleet-furnace-412302/datasets/demo_dataset]
google_storage_bucket.demo_bucket: Creation complete after 1s [id=fleet-furnace-412302-terra-bucket]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```