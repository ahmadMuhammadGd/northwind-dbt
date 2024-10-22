{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='supplier_sk',
        indexes = 
        [
            {"columns": ['supplier_sk'], 'unique': True},
        ]
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
    WHERE
        supplier_id IS NOT NULL
        AND
        contact_name IS NOT NULL
        AND
        contact_title IS NOT NULL
        AND
        address IS NOT NULL
        AND
        postal_code IS NOT NULL
        AND
        phone IS NOT NULL
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
    MD5(company_name) AS supplier_sk
    ,*
    , 'northwind' AS data_src
FROM 
    suppliers