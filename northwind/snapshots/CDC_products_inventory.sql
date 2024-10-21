{% snapshot CDC_products_inventory %}

{{
    config(
        target_schema='snapshots',
        unique_key='product_id',
        strategy='check',
        check_cols=['supplier_id', 'units_in_stock', 'units_on_order', 'reorder_level'],
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