{% snapshot CDC_products_price_discontinued %}

{{
    config(
        target_schema='snapshots',
        unique_key='product_id',
        strategy='check',
        check_cols=['unit_price', 'discontinued'],
    )
}}

SELECT
    product_id::int, 
    product_name::varchar(40), 
    supplier_id::int, 
    category_id::int, 
    quantity_per_unit::varchar(20), 
    unit_price::numeric, 
    units_in_stock::int, 
    units_on_order::int, 
    reorder_level::int, 
    discontinued::BOOLEAN



FROM 

    {{ source('northwind_raw', 'products') }}

{% endsnapshot %}