{{ config(
    materialized = 'incremental',
    strategy = 'append',
    unique_key = 'location_id',
    indexes = [
            {"columns": ['location_id'], 'unique': True },
        ]
) }} 

SELECT
    DISTINCT
    MD5(ship_address || ship_postal_code) as location_id
    , ship_address      AS address
    , ship_city         AS city
    , ship_region       AS region
    , ship_postal_code  AS postal_code
    , ship_country      AS country
FROM 
    {{ ref('int_wide_orders') }}