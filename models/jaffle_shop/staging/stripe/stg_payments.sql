{{
    config(
        materialized='incremental'
        , unique_key='payment_id'
        , on_schema_change='append_new_columns'
        , merge_exclude_columns =['created_dt', 'created_by', 'payment_id'] 
        , incremental_strategy = 'merge'
        , incremental_predicates=["DBT_INTERNAL_DEST.src_updated_dt > dateadd(day, -7, current_date)"] 
        , post_hook=["update {{ this }} set updated_dt = created_dt where updated_dt is null" , "select true"]
    )
}}

with 
    payments as (

        select * from {{ source('src_stripe', 'payments') }} 

        {%- if is_incremental() %}

            where _batched_at > (select max(src_updated_dt) from {{ this }})

        {%- endif -%}
    )

    , transformed as (

        select 
            payments.id as payment_id 
            , payments.orderid as order_id 
            , payments.status as payment_status 
            , payments.paymentmethod as payment_method

            --, payments.amount / 100 as payment_amount 
            , {{ cents_to_dollars('payments.amount', 4) }} as payment_amount 
            , payments.created as payment_created_date 
            , payments._BATCHED_AT as src_updated_dt
            , {{ current_timestamp_in_utc_backcompat() }} as created_dt 
            , {{ job_run_job_id() }} as created_by
            , {{ current_timestamp_in_utc_backcompat() }} as updated_dt 
            , {{ job_run_job_id() }} as updated_by
        from payments

    ) 

select * from transformed 