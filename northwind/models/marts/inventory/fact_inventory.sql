{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='record_id',
        indexes = 
        [
            {"columns": ['record_id'], 'unique': True},
            {"columns": ['supplier_sk'], 'unique': False},
        ]
    ) 
}}

WITH inventory AS (
    SELECT
        product_SK
        , supplier_id
        , units_in_stock
        , units_on_order
        , reorder_level
        , dbt_scd_id
        , dbt_updated_at
        , data_src
    FROM
        {{ ref('stg_inventory') }}
)
,
enriched AS (
    SELECT
        i.product_SK
        , s.supplier_sk
        , i.units_in_stock
        , i.units_on_order
        , i.reorder_level
        , i.dbt_scd_id as record_id
        , i.dbt_updated_at as updated_at
    FROM
        inventory i
    LEFT JOIN
        {{ ref('stg_suppliers') }} s  
    ON
        s.supplier_id = i.supplier_id
    AND
        s.data_src = i.data_src
)
SELECT * FROM enriched