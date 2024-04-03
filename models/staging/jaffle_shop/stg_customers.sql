with 
    customers as (


        select * from {{ source('src_jaffle_shop', 'customers') }}

    )

    , transformed as (

        select
            customers.id as customer_id 
            , customers.first_name as customer_first_name
            , customers.last_name as customer_last_name 
        from customers 

    )

select * from transformed