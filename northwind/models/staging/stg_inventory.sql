{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='dbt_scd_id',
        indexes = 
        [
            {"columns": ['product_id'], 'unique': False},
            {"columns": ['dbt_scd_id'], 'unique': True},
            {"columns": ['product_SK'], 'unique': False}
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
        units_in_stock::int, 
        units_on_order::int, 
        reorder_level::int, 
        discontinued::BOOLEAN,
        dbt_scd_id::text,
        dbt_updated_at::TIMESTAMP,
        dbt_valid_from::TIMESTAMP,
        dbt_valid_to::TIMESTAMP
    FROM {{ ref('CDC_products_inventory') }} pi
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
    WHERE
        product_name IS NOT NULL
        AND
        supplier_id IS NOT NULL
        AND
        category_id IS NOT NULL
        AND
        quantity_per_unit IS NOT NULL
        AND
        units_in_stock IS NOT NULL
        AND
        units_on_order IS NOT NULL
        AND
        reorder_level IS NOT NULL
        AND
        discontinued IS NOT NULL
)

SELECT
    MD5(product_name) AS product_SK
    , *
FROM 
    cleaned_products