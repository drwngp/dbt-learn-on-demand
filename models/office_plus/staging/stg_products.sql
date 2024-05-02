{{-
    config(
        materialized='incremental',
        unique_key='product_code',
        incremental_strategy='merge',
        merge_exclude_columns=['created_by', 'created_dt']
    )
-}}

with products as (

    select * from {{ source("src_office_plus", 'products')}} 

    {%- if is_incremental() %}
    where _load_dt = (select max(src_updated_dt) from {{ this }})
    {%- endif -%}

)

, transformed as (

    select 
        productcode as product_code 
        , productname as product_name 
        , subcategorycode as category_code 
        , cost 
        , retailprice as retail_price
        , _load_dt as src_updated_dt 
        , {{ current_timestamp_in_utc_backcompat() }} as created_dt 
        , {{ job_run_job_id() }} as created_by 
        , {{ current_timestamp_in_utc_backcompat() }} as updated_dt 
        , {{ job_run_job_id() }} as updated_by 
    from products 

)

select * from transformed