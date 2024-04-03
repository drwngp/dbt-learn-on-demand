with 
    -- with statement
    -- import CTEs 
    customers as (

        select * from {{ ref('stg_customers') }}

    )

    , paid_orders as (

        select * from {{ ref('int_paid_orders') }}

    ) 

    , customers_order_profile as (

        select * from {{ ref('int_customer_order_profile') }}

    )

, final as (

    select 
        paid_orders.customer_id
        , paid_orders.order_id 
        , paid_orders.order_placed_at
        , paid_orders.order_status
        , paid_orders.total_amount_paid
        , paid_orders.payment_finalized_date
        , customers.customer_first_name
        , customers.customer_last_name  
        , paid_orders.transaction_seq
        , paid_orders.customer_sales_seq
        , case
            when customers_order_profile.first_order_date = paid_orders.order_placed_at 
            then 'new' 
            else 'return'
          end as nvsr 
        , paid_orders.customer_lifetime_value
        , customers_order_profile.first_order_date as FDOS 
    from paid_orders 
    left join customers 
        on paid_orders.customer_id = customers.customer_id 
    left join int_customer_order_profile as customers_order_profile  
        on paid_orders.customer_id = customers_order_profile.customer_id 

)

select * from final  
--where order_id in(1, 37) 
--where customer_id in(1, 66)
--order by customer_id --, order_id
