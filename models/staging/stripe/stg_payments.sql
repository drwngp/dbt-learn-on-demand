with 
    payments as (

        select * from {{ source('src_stripe', 'payments') }}

    )

    , transformed as (

        select 
            payments.id as payment_id 
            , payments.orderid as order_id 
            , payments.status as payment_status 
            , payments.paymentmethod as payment_method

            --, payments.amount / 100 as payment_amount 
            , {{ cents_to_dollars('payments.amount', 4) }} as payment_amount 
            , payments.created as payment_created_date
        from payments

    ) 

select * from transformed 