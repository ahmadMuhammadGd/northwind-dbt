{{
    config(
        materialized='incremental',
        strategy='merge',
        unique_key='category_id',
        indexes = 
        [
            {"columns": ['category_id'], 'unique': True},
        ]
    ) 
}}



WITH categories AS (
SELECT 
    category_id::INT, 
    {{ clean_product_category('category_name') }}::varchar(15) AS category_name, 
    {{ string_standarize('description')}}::text AS description, 
    picture::bytea AS picture
FROM
    {{ source('northwind_raw', 'categories') }}
)

SELECT
    MD5(category_name)::text AS category_sk, *
FROM 

categories