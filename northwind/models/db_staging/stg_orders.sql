{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='order_id',
        indexes = 
        [
            {"columns": ['order_id'], 'unique': False},
            {"columns": ['customer_id'], 'unique': False},
            {"columns": ['employee_id'], 'unique': False},
        ]
    )
}}




SELECT
    order_id::INT, 
    customer_id::CHARACTER, 
    employee_id::int, 
    order_date::date, 
    required_date::date, 
    shipped_date::date, 
    ship_via::int, 
    freight::numeric, 
    ship_name::varchar(40), 
    ship_address::varchar(60), 
    ship_city::varchar(15), 
    ship_region::varchar(15), 
    ship_postal_code::varchar(10), 
    ship_country::varchar(15)
    , 'northwind' AS data_src

FROM
    {{ source('northwind_raw', 'orders') }}

WHERE
    order_id IS NOT NULL
    AND
    customer_id IS NOT NULL
    AND
    employee_id IS NOT NULL
    AND
    order_date IS NOT NULL
    AND
    required_date IS NOT NULL
    AND
    shipped_date IS NOT NULL
    AND
    ship_via IS NOT NULL
    AND
    freight IS NOT NULL
    AND
    ship_name IS NOT NULL
    AND
    ship_address IS NOT NULL
    AND
    ship_city IS NOT NULL
    AND
    ship_region IS NOT NULL
    AND
    ship_postal_code IS NOT NULL
    AND
    ship_country IS NOT NULL