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




SELECT 
    category_id::INT, 
    {{ clean_product_category('category_name') }} ::varchar(15) AS category_name, 
    description::text, 
    picture::bytea
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