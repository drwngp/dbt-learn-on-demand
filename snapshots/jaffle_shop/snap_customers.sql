{% snapshot snap_customers %}
    {{
        config(
            target_schema='jaffle_shop_snapshots',
            unique_key='customer_id',
            strategy='check',
            check_cols='all',
            invalidate_hard_deletes=False,
        )
    }}

    select 

        id as customer_id 
        , first_name as customer_first_name
        , last_name as customer_last_name 
        , {{ current_timestamp_in_utc_backcompat() }} as created_dt 
        , {{ job_run_job_id() }} as created_by         

    from {{ source('src_jaffle_shop', 'customers')}}

 {% endsnapshot %}

--select * from {{ source('src_jaffle_shop', 'customers')}}
