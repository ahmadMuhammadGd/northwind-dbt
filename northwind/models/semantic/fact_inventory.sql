{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='record_id',
        indexes = 
        [
            {"columns": ['product_sk'], 'unique': False},
            {"columns": ['record_id'], 'unique': True},
        ]
    ) 
}}


WITH inventory AS (
    SELECT DISTINCT ON (dbt_scd_id)
    dbt_scd_id as record_id
    , product_sk
    , units_in_stock
    , units_on_order
    , reorder_level
    , dbt_updated_at AS updated_at
    FROM
        {{ ref('int_inventory') }} 
)
SELECT * FROM inventory