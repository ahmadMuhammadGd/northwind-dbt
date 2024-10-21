{{ 
    config(
        materialized='incremental',
        strategy='merge',
        unique_key='dbt_scd_id',
        indexes=[
            {"columns": ['dbt_scd_id'], 'unique': True},
            {"columns": ['product_sk'], 'unique': False}
        ]
    ) 
}} 


{% set col_set = [
    'product_sk',
    'product_name',
    'unit_price',
    'quantity_per_unit',
    'dbt_scd_id',
    'dbt_updated_at',
    'dbt_valid_from',
    'dbt_valid_to'
] %}


WITH new_products AS (
    SELECT
        {{ col_set | join(', ') }}
    FROM
        {{ ref('int_CDC_product') }}
)
SELECT
    *
FROM
    new_products










