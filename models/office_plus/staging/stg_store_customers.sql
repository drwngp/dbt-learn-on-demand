{{
    config(
        materialized='incremental',
        unique_key='custnum',
        incremental_strategy='merge',
        merge_exclude_columns=['created_dt', 'created_by']
    )
}}

with customers as (

    select * from {{ source('src_office_plus', 'customers') }}

    {%- if is_incremental() %}
        where _load_dt >= (select max(src_updated_dt) from {{ this }})
    {%- endif -%}

)

, transformed as (

    select 
        custnum 
        , firstname as first_name 
        , lastname as last_name
        , concat(trim(firstname), ' ' , trim(lastname)) as fullname
        , city 
        , state_region 
        , country 
        , _load_dt as src_updated_dt 
        , {{ current_timestamp_in_utc_backcompat() }} as created_dt 
        , {{ job_run_job_id() }} as created_by 
        , {{ current_timestamp_in_utc_backcompat() }} as updated_dt 
        , {{ job_run_job_id() }} as updated_by 
    from customers 

)

select * from transformed