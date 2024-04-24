with orders as  (
    select * from {{ ref('stg_orders' )}}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

order_payments as (
    select
        order_id,
        sum(case when payment_status = 'success' then payment_amount end) as amount

    from payments
    group by 1
),

final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_placed_at,
        coalesce(order_payments.amount, 0) as amount, 
        {{ current_timestamp() }} as loaded_at_dt 

    from orders
    left join order_payments using (order_id)
)

select * from final 
-- add comment to test modified model.