{{ config(materialized='table') }}

with fhv_tripdata as (
    select *
    from {{ ref('stg_fhv_taxi') }}
), 
dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)
select
    fhv_tripdata.pickup_locationid,
    fhv_tripdata.pickup_datetime,
    pickup_zone.borough as pickup_borough,
    pickup_zone.zone as pickup_zone,
    fhv_tripdata.dropoff_locationid,    
    fhv_tripdata.dropoff_datetime,
    dropoff_zone.borough as dropoff_borough,
    dropoff_zone.zone as dropoff_zone,
    fhv_tripdata.dispatching_base_number,
    fhv_tripdata.affiliated_base_number,
    fhv_tripdata.sr_flag
from fhv_tripdata
inner join dim_zones as pickup_zone
on fhv_tripdata.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on fhv_tripdata.dropoff_locationid = dropoff_zone.locationid