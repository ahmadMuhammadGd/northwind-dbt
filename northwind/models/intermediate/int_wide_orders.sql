{{
    config(
        materialized='incremental',
        strategy='merge',
        unique_key='order_sk',
        indexes = [
            {"columns": ['order_sk'], "unique": True},
            {"columns": ['customer_id'], "unique": False},
            {"columns": ['employee_id'], "unique": False}
        ]
    )
}}

WITH cleaned_orders AS (
    SELECT
        order_id,
        customer_id,
        employee_id,
        order_date,
        required_date,
        shipped_date,
        ship_via,
        freight,
        ship_name,
        ship_address,
        ship_city,
        ship_region,
        ship_postal_code,
        ship_country
    FROM
        {{ ref('stg_orders') }}
    WHERE
        shipped_date IS NOT NULL
),
distinct_products AS (
    SELECT DISTINCT ON (product_sk)
        product_sk,
        product_id
    FROM
        {{ ref('stg_products') }}
)
,
cleaned_order_details AS (
    SELECT
        od.order_id,
        p.product_sk,
        od.unit_price,
        od.quantity,
        od.discount
    FROM
        {{ ref('stg_order_details') }} od
    LEFT JOIN
        distinct_products p ON p.product_id = od.product_id
),
wide_orders AS (
    SELECT
        MD5(od.order_id::text || od.product_sk::text) AS order_sk,
        od.product_sk,
        od.unit_price,
        od.quantity,
        od.discount,
        o.order_id,
        o.customer_id,
        o.employee_id,
        o.order_date,
        o.required_date,
        o.shipped_date,
        o.ship_via,
        o.freight,
        o.ship_name,
        o.ship_address,
        o.ship_city,
        o.ship_region,
        o.ship_postal_code,
        o.ship_country
    FROM
        cleaned_orders o
    LEFT JOIN
        cleaned_order_details od ON o.order_id = od.order_id
)
SELECT * FROM wide_orders
