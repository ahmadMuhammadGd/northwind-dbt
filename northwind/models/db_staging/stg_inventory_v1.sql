{{
    config(
        materialized='incremental',
        incremental_strategy='append',
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
        cdc.product_id::int, 
        cdc.product_name::varchar(40), 
        cdc.supplier_id::int, 
        cdc.category_id::int, 
        cdc.quantity_per_unit::varchar(20), 
        cdc.units_in_stock::int, 
        cdc.units_on_order::int, 
        cdc.reorder_level::int, 
        cdc.discontinued::BOOLEAN,
        cdc.dbt_scd_id::text,
        cdc.dbt_updated_at::TIMESTAMP,
        cdc.dbt_valid_from::TIMESTAMP,
        cdc.dbt_valid_to::TIMESTAMP
    FROM {{ ref('CDC_products_inventory') }} as cdc

    {% if is_incremental() %}
    LEFT JOIN
        {{ this }} t
    ON
        t.dbt_scd_id = cdc.dbt_scd_id
    WHERE
        t.dbt_scd_id IS NULL
    {% endif %}
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