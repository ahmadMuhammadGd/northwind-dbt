{{
 config(
    materialized = 'incremental',
    incremental_strategy = 'append',
    unique_key = 'record_id',
    indexes = [
        {'columns': ['record_id'], 'unique': True},
        {'columns': ['supplier_sk'], 'unique': False},
        {'columns': ['product_id'], 'unique': False}
    ]
 )
}}

WITH new_inventory AS (
    SELECT
        cdc.product_id,
        cdc.supplier_id,
        cdc.units_in_stock,
        cdc.units_on_order,
        cdc.reorder_level,
        cdc.dbt_scd_id,
        cdc.dbt_updated_at
    FROM
        {{ ref('CDC_products_inventory') }} cdc
    
    {% if is_incremental() %}
    WHERE
        NOT EXISTS (
            SELECT 1 
            FROM {{ this }} t 
            WHERE t.record_id = cdc.dbt_scd_id
        )
    {% endif %}

),
enriched AS (
    SELECT
        i.dbt_scd_id::text AS record_id,
        i.product_id::int,
        s.supplier_sk::text,
        i.units_in_stock::int,
        i.units_on_order::int,
        i.reorder_level::int,
        i.dbt_updated_at::timestamp AS updated_at
    FROM
        new_inventory i
    LEFT JOIN
        {{ ref('stg_suppliers') }} s  
    ON
        s.supplier_id = i.supplier_id
)

{% if is_incremental() %}
SELECT * FROM enriched
UNION ALL
SELECT * FROM {{ this }}
{% else %}
SELECT * FROM enriched
{% endif %}