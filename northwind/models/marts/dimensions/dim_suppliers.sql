{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='supplier_sk',
        indexes = 
        [
            {"columns": ['supplier_sk'], 'unique': True},
        ]
    ) 
}}

WITH suppliers AS (
    SELECT
        DISTINCT ON (supplier_id)
        MD5(company_name || contact_title) AS supplier_sk
        , supplier_id
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