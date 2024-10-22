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
WHERE
    category_id IS NOT NULL
    AND
    category_name IS NOT NULL
    AND
    description IS NOT NULL
    AND
    picture IS NOT NULL
)

SELECT
    MD5(category_name)::text AS category_sk, *
    , 'northwind' AS data_src
FROM 

categories