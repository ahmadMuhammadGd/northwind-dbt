{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='location_sk',
        indexes = 
        [
            {"columns": ['location_sk'], 'unique': True},
        ]
    ) 
}}

WITH suppliers_location AS (
    SELECT DISTINCT
        address
        ,city
        ,region
        ,postal_code
        ,country
    FROM
        {{ ref('stg_suppliers') }}
)
,
orders_location AS (
    SELECT DISTINCT
        ship_address        AS address
        ,ship_city           AS city
        ,ship_region         AS region
        ,ship_postal_code    AS postal_code
        ,ship_country        AS country
    FROM
        {{ ref('stg_orders') }}
)
,
pre_location_dim AS (
    SELECT
        *
    FROM 
        suppliers_location
    
    UNION
    
    SELECT
        *
    FROM
        orders_location
)
,
location_dim AS (
    SELECT
        MD5(address || postal_code) AS location_sk
        , *
    FROM 
        pre_location_dim
)
SELECT * FROM location_dim