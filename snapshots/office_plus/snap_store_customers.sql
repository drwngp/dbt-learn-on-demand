{% snapshot snap_store_customers %}
    {{
        config(
            target_schema='office_plus_snapshots', 
            unique_key='custnum',
            strategy='timestamp',
            invalidate_hard_deletes=False,
            updated_at='src_updated_dt',
        )
    }}

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

     from {{ source('src_office_plus', 'customers') }} 

 {% endsnapshot %}