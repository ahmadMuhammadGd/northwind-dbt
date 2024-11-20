{{
    config(
        materialized='table',
        strategy='append',
        unique_key='order_sk',
        indexes = 
        [
            {"columns": ['order_sk'], 'unique': true},
            {"columns": ['order_id'], 'unique': False},
            {"columns": ['customer_id'], 'unique': False},
            {"columns": ['employee_id'], 'unique': False},
        ],
        group="orders"
    )
}}


SELECT
    MD5(order_id::TEXT || COALESCE(shipped_date::TEXT, '')) AS order_sk,
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

FROM
    {{ source('northwind_raw', 'orders') }}