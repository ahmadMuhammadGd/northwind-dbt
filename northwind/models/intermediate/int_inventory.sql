{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='dbt_scd_id',
        indexes = 
        [
            {"columns": ['dbt_scd_id'], 'unique': True},
            {"columns": ['product_SK'], 'unique': False}
        ]
    ) 
}}



WITH products_data AS (
    SELECT
        product_sk
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
        
    FROM {{ ref('stg_inventory') }} pi
)

SELECT
     *
FROM 
    products_data