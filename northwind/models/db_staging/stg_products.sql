{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='product_id',
        indexes = 
        [
            {"columns": ['product_id'], 'unique': False},
        ]
    ) 
}}



WITH products_data AS (
    SELECT
        product_id::int, 
        product_name::varchar(40), 
        supplier_id::int, 
        category_id::int, 
        quantity_per_unit::varchar(20),
        unit_price::numeric, 
        discontinued::BOOLEAN
    FROM {{ source('northwind_raw', 'products') }} 
)
,
cleaned_products AS (
    SELECT
        product_id
        , {{ clean_products_name('product_name') }} AS product_name
        , supplier_id
        , category_id
        , unit_price
        , quantity_per_unit
        , discontinued
    FROM 
        products_data
)

SELECT
    *
FROM 
    cleaned_products