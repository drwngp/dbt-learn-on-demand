with 
    orders as (

        select * from {{ source('src_jaffle_shop', 'orders') }}

    )

    , transformed as (

        select 
            orders.id as order_id,
            orders.user_id as customer_id,
            orders.order_date as order_placed_at,
            orders.status as order_status
        from orders

    )

select * from transformed 