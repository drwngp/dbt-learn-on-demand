with 
    orders as (

        select * from {{ ref('stg_orders') }}

    ) 

    , final as (
        select
            orders.customer_id
            , min(orders.order_placed_at) as first_order_date
            , max(orders.order_placed_at) as most_recent_order_date
            , count(orders.order_id) as number_of_orders
        from orders  
        group by orders.customer_id 
    )

select * from final