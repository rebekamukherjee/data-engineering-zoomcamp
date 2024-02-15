{{ config(materialized='view') }}

with tripdata as (
    select * from {{ source('staging', 'fhv_taxi') }}
    where extract(year from pickup_date) = 2019
)
select
    -- identifiers
    {{ dbt.safe_cast("pulocationid", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("dolocationid", api.Column.translate_type("integer")) }} as dropoff_locationid,
    
    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,
    
    -- trip info
    dispatching_base_number,
    affiliated_base_number,
    sr_flag
from tripdata

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}