WITH orders AS (
    SELECT
        order_date,
        unit_price,
        quantity,
        discount,
        (unit_price * quantity * discount) AS total
    FROM
        {{ ref('fact_orders') }}
    WHERE shipped_date IS NOT NULL
)
,
transformed AS (
    SELECT
        EXTRACT(YEAR FROM order_date) as year,
        ROUND(SUM(total), 2) as total
    FROM
        orders
    GROUP BY
        , EXTRACT(YEAR FROM order_date)
    ORDER BY
        EXTRACT(YEAR FROM order_date)
)
SELECT * FROM transformed
