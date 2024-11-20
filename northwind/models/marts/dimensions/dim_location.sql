{{
    config(
        materialized='incremental',
        incremental_strategy='append',
        unique_key='location_sk',
        indexes = 
        [
            {"columns": ['location_sk'], 'unique': True},
        ]
    ) 
}}

    {% set not_null_cols = [
        'postal_code'
    ] %}

    WITH suppliers_location AS (
        SELECT DISTINCT
            city
            ,region
            ,postal_code
            ,country
        FROM
            {{ ref('stg_suppliers') }}
        WHERE 
        {% for col in not_null_cols %}
            {{ col }} IS NOT NULL
            {% if not loop.last %} AND {% endif %}
        {% endfor %}
    )
    ,
    orders_location AS (
        SELECT DISTINCT
            ship_city            AS city
            ,ship_region         AS region
            ,ship_postal_code    AS postal_code
            ,ship_country        AS country
        FROM
            {{ ref('stg_orders') }}
        WHERE 
        {% for col in not_null_cols %}
             {{ 'ship_' + col }} IS NOT NULL
            {% if not loop.last %} AND {% endif %}
        {% endfor %}
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
        MD5(postal_code) AS location_sk
        , *
    FROM 
        pre_location_dim
)
SELECT * FROM location_dim