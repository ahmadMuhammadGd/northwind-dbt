{{
 config(
    materialized = 'incremental',
    incremental_strategy = 'append',
    unique_key = 'record_id',
    indexes = [
        {'columns': ['record_id'], 'unique': True},
        {'columns': ['supplier_sk'], 'unique': False},
        {'columns': ['product_sk'], 'unique': False}
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
        cdc.CDC_sk,
        cdc.updated_at
    FROM
        {{ ref('stg_inventory', version=2) }} cdc
    
    {% if is_incremental() %}
    LEFT JOIN
        {{ this }} t
    ON
        t.record_id = cdc.CDC_sk
    WHERE
        t.record_id IS NULL
    {% endif %}
),
enriched AS (
    SELECT
        i.CDC_sk::text AS record_id,
        p.product_sk::text,
        s.supplier_sk::text,
        i.units_in_stock::int,
        i.units_on_order::int,
        i.reorder_level::int,
        i.updated_at::timestamp AS updated_at
    FROM
        new_inventory i
    
    LEFT JOIN
        {{ ref('dim_suppliers') }} s  
    ON
        s.supplier_id = i.supplier_id
    
    LEFT JOIN
        {{ ref('dim_products') }} p 
    ON
        p.product_id = i.product_id
    AND
        i.updated_at >= p.start_date
    AND
        i.updated_at < p.end_date
)
SELECT * FROM enriched