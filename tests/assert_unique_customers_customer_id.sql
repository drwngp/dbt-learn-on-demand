{{
    config(
        error_if='>30'
        , warn_if='>10'
    )
}}

select
    customer_id, 
    count(*) as rec_count
from {{ ref('fct_orders') }}
group by 1
having rec_count > 1