{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='order_sk',
        indexes = 
        [
            {"columns": ['order_sk'], "unique": True},
        ]
    )
}}


WITH dim_location AS (
    SELECT
        location_id,
        address,
        postal_code
    FROM 
    {{ ref('dim_location') }}
)
,
wide_orders AS (
    SELECT
        order_sk
        , product_sk
        , unit_price
        , quantity
        , discount
        , ship_address
        , ship_postal_code
    FROM 
        {{ ref('int_wide_orders') }}
)
,
fact AS (
    SELECT
        order_sk
        , product_sk
        , unit_price
        , quantity
        , discount
        , l.location_id
    FROM
        wide_orders w
    LEFT JOIN
        dim_location l
    ON
        l.address = w.ship_address
    AND
        l.postal_code = w.ship_postal_code
)
SELECT
    *
FROM
    fact