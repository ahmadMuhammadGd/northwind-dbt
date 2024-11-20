{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='dbt_scd_id',
        indexes = 
        [
            {"columns": ['product_id'], 'unique': False},
            {"columns": ['dbt_scd_id'], 'unique': True},
        ],
        group="inventory"
    ) 
}}



WITH products_data AS (
    SELECT
        product_id::int, 
        product_name::varchar(40), 
        supplier_id::int, 
        category_id::int, 
        quantity_per_unit::varchar(20), 
        units_in_stock::int, 
        units_on_order::int, 
        reorder_level::int, 
        discontinued::BOOLEAN,
        dbt_scd_id::text,
        dbt_updated_at::TIMESTAMP,
        dbt_valid_from::TIMESTAMP,
        dbt_valid_to::TIMESTAMP
    FROM {{ ref('CDC_products_inventory') }} 
)
,
cleaned_products AS (
    SELECT
        product_id
        , {{ clean_products_name('product_name') }} AS product_name
        , supplier_id
        , category_id
        , quantity_per_unit
        , units_in_stock
        , units_on_order
        , reorder_level
        , discontinued
        , dbt_scd_id
        , dbt_updated_at
        , dbt_valid_from
        , dbt_valid_to
    FROM 
        products_data
)

SELECT
     *

FROM 
    cleaned_products