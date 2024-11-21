{{
    config(
        materialized='incremental',
        incremental_strategy='append',
        unique_key='CDC_sk',
        indexes = 
        [
            {"columns": ['product_id'], 'unique': False},
            {"columns": ['CDC_sk'], 'unique': True},
        ],
        group="inventory"
    ) 
}}

{% 
    set columns_to_track = [
        'product_id'
        , 'units_in_stock'
        , 'units_on_order'
        , 'reorder_level'
        , 'discontinued'
    ]  
%}

WITH products_data AS (
    SELECT
        src.product_id::int, 
        src.product_name::varchar(40), 
        src.supplier_id::int, 
        src.category_id::int, 
        src.quantity_per_unit::varchar(20), 
        src.units_in_stock::int, 
        src.units_on_order::int, 
        src.reorder_level::int, 
        src.discontinued::BOOLEAN,
        {{ generate_cdc_sk(columns_to_track, 'src') }}::text as CDC_sk
    FROM {{ source('northwind_raw', 'products') }} as src

    {% if is_incremental() %}
    LEFT JOIN
        {{ this }} t
    ON
        t.CDC_sk = {{ generate_cdc_sk(columns_to_track, 'src') }}
    WHERE
        t.CDC_sk IS NULL
    {% endif %}
)
,
cleaned_products AS (
    SELECT
        product_id
        , {{ clean_products_name('product_name') }} AS product_name
        , supplier_id
        , category_id
        , quantity_per_unit
        , units_in_stock
        , units_on_order
        , reorder_level
        , discontinued
        , CDC_sk
        , NOW() as updated_at
    FROM 
        products_data
)
SELECT
     *
FROM
    cleaned_products