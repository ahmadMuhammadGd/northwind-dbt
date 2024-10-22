{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='category_sk',
        indexes = 
        [
            {"columns": ['category_sk'], 'unique': True},
        ]
    ) 
}}



WITH category AS (
    SELECT 
        category_sk
        , category_name
        , description
    FROM 
        {{ ref('stg_categories') }}
)
SELECT * FROM category