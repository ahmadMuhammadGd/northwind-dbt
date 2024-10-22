{{
    config(
        materialized='incremental',
        strategy='merge',
        unique_key='dbt_scd_id',
        indexes = 
        [
            {"columns": ['dbt_scd_id'], 'unique': True},
            {"columns": ['category_sk'], 'unique': False},
        ]
    )
}}


WITH scd2_products AS (
    SELECT  
        product_SK
        , product_name
        , category_id
        , unit_price
        , quantity_per_unit
        , discontinued
        , dbt_scd_id
        , dbt_updated_at
        , dbt_valid_from
        , dbt_valid_to
        , data_src
    FROM
        {{ ref('stg_products') }}
)
,
eniched AS (
    SELECT
        p.product_SK
        , p.product_name
        , c.category_sk
        , p.unit_price
        , p.quantity_per_unit
        , p.discontinued
        , p.dbt_scd_id
        , p.dbt_updated_at
        , p.dbt_valid_from
        , p.dbt_valid_to
    FROM
        scd2_products p
    LEFT JOIN
        {{ ref('stg_categories') }} c  
    ON
        c.category_id = p.category_id
    AND
        c.data_src = p.data_src
)
SELECT * FROM eniched