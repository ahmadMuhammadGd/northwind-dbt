{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='dbt_scd_id',
        indexes = 
        [
            {"columns": ['dbt_scd_id'], 'unique': True},
            {"columns": ['product_SK'], 'unique': False},
        ]
    ) 
}}
WITH products AS (
    SELECT
          product_SK
        , supplier_id
        , category_id
        , product_name
        , unit_price
        , quantity_per_unit
        , discontinued
        , dbt_scd_id
        , dbt_updated_at
        , dbt_valid_from
        , dbt_valid_to
    FROM 
        {{ ref('stg_products') }}
)

SELECT
    *
FROM
    products