SELECT
    CASE 
        WHEN units_in_stock < reorder_level THEN 'Below Reorder Level'
        WHEN units_in_stock = reorder_level THEN 'At Reorder Level'
        ELSE 'Above Reorder Level'
    END AS inventory_status,
    COUNT(*) AS product_count
FROM
    {{ ref('fact_inventory') }}
GROUP BY
    inventory_status
ORDER BY
    product_count DESC;