WITH MonthlySales AS (
    SELECT
        p.product_name,
        DATE_TRUNC('month', o.order_date)::date AS month_start,  -- Get the month start date
        ROUND(
            SUM(
                o.unit_price * 
                CASE 
                    WHEN o.discount = 0 THEN 1 
                    ELSE o.discount 
                END * o.quantity
            ), 
            2
        ) AS total_sales
    FROM
        {{ ref("fact_orders") }} o
    LEFT JOIN 
        {{ ref("dim_products") }} p ON o.product_sk = p.product_sk
    WHERE 
        o.shipped_date IS NOT NULL
    GROUP BY
        p.product_name, DATE_TRUNC('month', o.order_date)  
)

SELECT
    product_name,
    month_start,
    total_sales
FROM
    MonthlySales
ORDER BY
    month_start ASC,   
    total_sales DESC;  
