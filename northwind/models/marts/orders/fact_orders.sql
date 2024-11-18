{{
    config(
        materialized='incremental',
        strategy='merge',
        unique_key='transaction_id',
        indexes = 
        [
            {"columns": ['transaction_id'], 'unique': True},
            {"columns": ['location_sk'], 'unique': False},
            {"columns": ['product_sk'], 'unique': False},
        ]
    ) 
}}


WITH orders AS (
    SELECT
         order_id
        , order_date
        , required_date
        , shipped_date
        , MD5(ship_address || ship_postal_code) AS location_sk
    FROM
        {{ ref('stg_orders') }}
    WHERE
        shipped_date IS NOT NULL
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
        MD5(o.order_id||od.product_sk) AS transaction_id
        ,o.order_id
        ,o.order_date
        ,o.required_date
        ,o.shipped_date
        ,o.location_sk
        ,od.product_sk
        ,od.unit_price
        ,od.quantity
        ,od.discount
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