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
        unit_price::numeric, 
        discontinued::BOOLEAN,
        dbt_scd_id::text,
        dbt_updated_at::TIMESTAMP,
        dbt_valid_from::TIMESTAMP,
        dbt_valid_to::TIMESTAMP
    FROM {{ ref('CDC_products_price_discontinued') }} pi
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
        discontinued IS NOT NULL
        AND
        unit_price IS NOT NULL
        AND
        unit_price > 0
)

SELECT
    MD5(product_name) AS product_SK
    , *
    , 'northwind' AS data_src

FROM 
    cleaned_products