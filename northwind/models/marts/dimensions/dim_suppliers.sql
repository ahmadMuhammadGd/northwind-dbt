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
        , supplier_id::int
        , company_name::text
        , contact_name::text
        , contact_title::text
        -- , MD5(address || postal_code) AS location_sk
        , phone::text
        , fax::text
        , homepage::text
    FROM 
        {{ ref('stg_suppliers') }}
)
SELECT * FROM suppliers