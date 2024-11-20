{{
    config(
        materialized='incremental',
        strategy='merge',
        unique_key='supplier_sk',
        indexes = 
        [
            {"columns": ['supplier_sk'], 'unique': True},
        ]
    ) 
}}

WITH suppliers AS (
    SELECT
        DISTINCT
        supplier_sk
        , company_name
        , contact_name
        , contact_title
        -- , MD5(address || postal_code) AS location_sk
        , phone
        , fax
        , homepage
    FROM 
        {{ ref('stg_suppliers') }}
)
SELECT * FROM suppliers