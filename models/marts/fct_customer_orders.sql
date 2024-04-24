with 
    customers as (

        select * from {{ ref('stg_customers') }}

    )

    , paid_orders as (

        select * from {{ ref('int_paid_orders') }}

    ) 

, final as (

    select 
        paid_orders.customer_id
        , paid_orders.order_id 
        , paid_orders.order_placed_at
        , paid_orders.order_status
        -- add comment for ci job test.
        , paid_orders.total_amount_paid
        , paid_orders.payment_finalized_date
        , customers.customer_first_name
        , customers.customer_last_name  
        , paid_orders.transaction_seq
        , paid_orders.customer_sales_seq
        , case
            when paid_orders.first_order_date = paid_orders.order_placed_at 
            then 'new' 
            else 'return'
          end as nvsr 
        , paid_orders.customer_lifetime_value
        , paid_orders.first_order_date as FDOS 
    from paid_orders 
    left join customers 
        on paid_orders.customer_id = customers.customer_id 

)

select * from final  
