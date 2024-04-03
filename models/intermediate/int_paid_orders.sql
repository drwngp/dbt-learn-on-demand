with
    orders as (select * from {{ ref("stg_orders") }}),

    payments as (

        select
            order_id,
            max(payment_created_date) as payment_finalized_date,
            sum(payment_amount) as total_amount_paid
        from {{ ref("stg_payments") }}
        where payment_status = 'success'
        group by order_id

    ),

    paid_orders as (

        select
            orders.order_id,
            orders.customer_id,
            orders.order_placed_at,
            orders.order_status,
            payments.total_amount_paid,
            payments.payment_finalized_date,
            row_number() over (order by orders.order_id) as transaction_seq,
            row_number() over (
                partition by orders.customer_id order by orders.order_id
            ) as customer_sales_seq,
            sum(payments.total_amount_paid) over (
                partition by orders.customer_id
                order by orders.order_id
                range between unbounded preceding and current row
            ) as customer_lifetime_value

        from orders
        left outer join payments on orders.order_id = payments.order_id

    ) 

select * from paid_orders
