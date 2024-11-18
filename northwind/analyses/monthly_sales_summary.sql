WITH orders AS (
    SELECT
        order_date,
        unit_price,
        quantity,
        discount,
        CASE 
            WHEN discount = 0 THEN unit_price * quantity
            ELSE unit_price * quantity * discount
        END AS total
    FROM
        {{ ref('fact_orders') }}
    WHERE shipped_date IS NOT NULL
)
,
transformed AS (
    SELECT
        EXTRACT(MONTH FROM order_date) as month,
        EXTRACT(YEAR FROM order_date) as year,
        ROUND(SUM(total), 2) as total
    FROM
        orders
    GROUP BY
        EXTRACT(MONTH FROM order_date)
        , EXTRACT(YEAR FROM order_date)
    ORDER BY
        EXTRACT(YEAR FROM order_date)
		, EXTRACT(MONTH FROM order_date)
)
SELECT * FROM transformed
