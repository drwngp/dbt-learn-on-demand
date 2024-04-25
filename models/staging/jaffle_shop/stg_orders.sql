{{
    config(
        materialized='incremental'
        , unique_key='order_id'
        , on_schema_change='append_new_columns'
        , merge_exclude_columns =['created_dt', 'created_by', 'order_id'] 
        , incremental_strategy = 'merge'
        , incremental_predicates=["DBT_INTERNAL_DEST.src_updated_dt > dateadd(day, -7, current_date)"]
    )
}}

with 
    orders as (

        select * from {{ source('src_jaffle_shop', 'orders') }} 

        {%- if is_incremental() %}
            where _etl_loaded_at > (select max(src_updated_dt) from {{ this }}   )
        {%- endif -%}

    )

    , transformed as (

        select 
            orders.id as order_id,
            orders.user_id as customer_id,
            orders.order_date as order_placed_at,
            orders.status as order_status ,
            orders._etl_loaded_at as src_updated_dt
            , {{ current_timestamp_in_utc_backcompat() }} as created_dt   
            , {{ job_run_job_id() }} as created_by
            , {{ current_timestamp_in_utc_backcompat() }} as updated_dt 
            , {{ job_run_job_id() }} as updated_by       

        from orders

    )

select * from transformed 