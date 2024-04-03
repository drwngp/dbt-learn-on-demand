with 
    -- with statement
    -- import CTEs 
    customers as (

        select * from {{ ref('stg_customers') }}

    )

    , orders as (

        select * from {{ ref('stg_orders') }}

    )

    , payments as (

        select 
            *
        from {{ ref('stg_payments') }} 

    )


    , int_payments as (

        select 
            order_id 
            , max(payment_created_date) as payment_finalized_date
            , sum(payment_amount) as total_amount_paid
        from {{ ref('stg_payments') }} 
        where payment_status = 'success' 
        group by order_id

    )

     -- final CTE
    -- simple select statement
    , int_paid_orders as (
        
        select 
            orders.order_id
            , orders.customer_id
            , orders.order_placed_at
            , orders.order_status
            , payments.total_amount_paid
            , payments.payment_finalized_date 
            , row_number() over (order by orders.order_id) as transaction_seq
            , row_number() over (
                partition by orders.customer_id order by orders.order_id
                ) as customer_sales_seq 
            , sum(payments.total_amount_paid) over 
                (partition by orders.customer_id 
                    order by orders.order_id range between unbounded preceding and current row) 
                as customer_lifetime_value 

        from orders 
        left outer join int_payments payments 
            on orders.order_id = payments.order_id 
 
    )

    , int_customer_order_profile as (
        select
            customers.customer_id
            , min(orders.order_placed_at) as first_order_date
            , max(orders.order_placed_at) as most_recent_order_date
            , count(orders.order_id) as number_of_orders
        from customers 
        left join orders  
            on orders.customer_id = customers.customer_id
        group by customers.customer_id 
    
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
        --, customers_order_profile.most_recent_order_date
        --, customers_order_profile.number_of_orders 
    from int_paid_orders as paid_orders 
    left join customers 
        on paid_orders.customer_id = customers.customer_id 
    left join int_customer_order_profile as customers_order_profile  
        on paid_orders.customer_id = customers_order_profile.customer_id 

)


select * from final  
--where order_id in(1, 37) 
--where customer_id in(1, 66)
order by customer_id --, order_id
