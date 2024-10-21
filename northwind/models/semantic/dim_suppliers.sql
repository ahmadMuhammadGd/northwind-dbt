{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='supplier_id',
        indexes = 
        [
            {"columns": ['supplier_id'], 'unique': True},
        ]
    ) 
}}

SELECT
    supplier_id
    , company_name
    , contact_name
    , contact_title
    , address
    , city
    , region
    , postal_code
    , country
    , phone
    , fax
    , homepage
FROM 
    {{ ref('stg_suppliers') }}