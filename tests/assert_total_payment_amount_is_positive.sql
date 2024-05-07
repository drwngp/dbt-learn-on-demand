select
    customer_id, 
    sum(amount) as total_payment_amount
from {{ ref('fct_orders') }}
group by 1
having total_payment_amount < 0