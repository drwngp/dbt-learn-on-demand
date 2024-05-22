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
        , 'test value of dbt clone on Slim CI' as test_column
        , 'another test column' as test_column_2

    from orders
    left join order_payments using (order_id)
)

select * from final 
-- adding comment to test CI slim run; more addon comment.