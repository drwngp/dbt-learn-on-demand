import snowflake.snowpark.functions as f 
from snowflake.snowpark.functions import col 

def model(dbt, session):
    dbt.config(
        materialized="table"
#        packages=[]
    )

    def_cust = dbt.ref("stg_customers")
    def_ord = dbt.ref("stg_orders") 
    def_raw_cust = dbt.source("src_jaffle_shop", "orders")

#    def_customer_order =  df_ord.group_by(col("customer_id")).agg([f.min(col("order_placed_at")).alias("first_order"), f.max("order_placed_at").alias("most_recent_order"), f.count("order_id").alias("order_count")  ])

    return def_raw_cust 