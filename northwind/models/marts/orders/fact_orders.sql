{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='transaction_sk',
        indexes = 
        [
            {"columns": ['transaction_sk'], 'unique': True},
            {"columns": ['location_sk'], 'unique': False},
            {"columns": ['product_sk'], 'unique': False},
        ],
    ) 
}}

WITH orders AS (
    SELECT
         order_id
        , order_sk
        , order_date
        , required_date
        , shipped_date
        , MD5(ship_postal_code) AS location_sk
    FROM
        {{ ref('stg_orders') }}
    WHERE
        ship_postal_code IS NOT NULL
)
,
order_details AS (
    SELECT
        p.product_SK
        , o.order_id
        , o.unit_price
        , o.quantity
        , o.discount
    FROM 
        {{ ref('stg_order_details') }} o
    LEFT JOIN
        {{ ref('dim_products') }} p
    ON 
        o.product_id=p.product_id
    AND
        o.unit_price = p.unit_price
)
,
fact_table AS (
    SELECT
        MD5(order_sk || od.product_sk) as transaction_sk
        ,o.order_sk
        ,o.order_id::int
        ,o.order_date::date AS order_date
        ,o.required_date::date AS required_date
        ,CASE 
            WHEN 
                o.shipped_date IS NULL 
                THEN 'pending' 
            ELSE 'shipped' 
        END::varchar(10) AS order_status
        ,CASE
            WHEN 
                o.shipped_date IS NOT NULL 
                THEN o.shipped_date
            ELSE
                '9999-01-01'  
        END::date AS shipped_date
        ,o.location_sk::text
        ,od.product_sk::text
        ,od.unit_price::numeric
        ,od.quantity::int
        ,COALESCE(od.discount, 0)::numeric AS discount
    FROM
        orders o
    LEFT JOIN
        order_details od 
    ON
        o.order_id=od.order_id
)
SELECT
    *
FROM
    fact_table