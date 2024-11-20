{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='supplier_id',
        indexes = 
        [
            {"columns": ['supplier_id'], 'unique': True},
        ],
        group="suppliers"

    ) 
}}

WITH valid_suppliers AS (
    SELECT
        DISTINCT
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
        {{ source('northwind_raw', 'suppliers') }}
)
,
suppliers AS (
    SELECT
    supplier_id
        , {{ clean_company_name('company_name') }} AS company_name
        , {{ string_standarize('contact_name') }} AS contact_name
        , {{ string_standarize('contact_title') }} AS contact_title
        , {{ string_standarize('address') }} AS address
        , {{ string_standarize('city') }} AS city
        , {{ string_standarize('region') }} AS region
        , {{ string_standarize('postal_code') }} AS postal_code
        , {{ string_standarize('country') }} AS country
        , phone
        , fax
        , homepage
    FROM 
        valid_suppliers
)

SELECT
    s.*
FROM 
    suppliers s
