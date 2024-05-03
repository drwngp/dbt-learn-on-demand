select
    customer_id, 
    count(*) as rec_count
from {{ ref('fct_orders') }}
group by 1
having rec_count > 1