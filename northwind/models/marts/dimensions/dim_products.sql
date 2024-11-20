{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='product_sk',
        indexes = 
        [
            {"columns": ['product_sk'], 'unique': True},
            {"columns": ['product_id'], 'unique': False},
        ]
    )
}}


{% set far_date = "'9999-01-01'" %}
{% set valid_days_currently_active_flag = 99999999 %}


WITH expanded_scd AS (
    SELECT 
        product_id,
        unit_price,
        o.order_date AS start_date,
        LEAD(o.order_date - 1) OVER (PARTITION BY product_id ORDER BY o.order_date ASC) AS end_date
    FROM 
        {{ ref('stg_order_details') }} od
    LEFT JOIN
        {{ ref('stg_orders') }} o
    ON
        od.order_id = o.order_id
	WHERE 
		o.order_date IS NOT NULL
		AND
		unit_price IS NOT NULL
		AND
		unit_price >= 0
)
,
shrinked_scd AS (
	SELECT 
		product_id,
	    unit_price,
		MIN(start_date) AS start_date, 
		MAX(COALESCE(end_date, {{ far_date }})) as end_date
	FROM 
        expanded_scd
	GROUP BY 
		product_id, unit_price
)
,
scd_minimal AS (
	SELECT 
		MD5(product_id::text || start_date::text) AS product_sk,
		product_id,
		unit_price,
		start_date, 
		end_date,
		CASE 
            WHEN end_date = {{ far_date }} 
            THEN 1 
            ELSE 0 
        END AS is_active
	FROM 
		shrinked_scd
	ORDER BY 
        product_id, start_date
)
,
enriched_scd AS (
	SELECT 
		scd.product_sk::TEXT,
		scd.product_id::INT,
		p.product_name::TEXT,
		c.category_name::TEXT,
		scd.unit_price::NUMERIC,
        p.quantity_per_unit::TEXT,
		scd.start_date::DATE,
		scd.end_date::DATE,
		scd.is_active::bool,
		CASE 
            WHEN scd.is_active = 1 
            THEN {{ valid_days_currently_active_flag }}::INT 
            ELSE (end_date - start_date)::INT
        END AS valid_days
	FROM 
		scd_minimal scd
	
	LEFT JOIN
		{{ ref('stg_products') }} p
	ON 
        p.product_id = scd.product_id
	
	LEFT JOIN
		{{ ref('stg_categories') }} c
	ON 
        c.category_id = p.category_id
)
SELECT 
	*
FROM 
    enriched_scd