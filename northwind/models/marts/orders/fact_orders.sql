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
        , data_src
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
        , o.data_src
    FROM 
        {{ ref('stg_order_details') }} o
    LEFT JOIN
        {{ ref('stg_products') }} p
    ON 
        o.product_id=p.product_id
    AND
        o.data_src=p.data_src
)
,
fact_table AS (
    SELECT
        MD5(o.order_id||od.product_sk||o.data_src) AS transaction_id
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
    AND
        o.data_src=od.data_src
)
SELECT
    *
FROM
    fact_table