{{
    config(
        materialized='incremental',
        incremental_strategy='append',
        unique_key='order_id',
        indexes = 
        [
            {"columns": ['order_id'], 'unique': False}, 
            {"columns": ['product_id'], 'unique': False},
        ],
        group="orders"
    ) 
}}


-- be aware of duplicates

SELECT 
    order_id::int,
    product_id::int, 
    unit_price::numeric, 
    quantity::int, 
    discount::numeric

FROM
    {{ source('northwind_raw', 'order_details') }}