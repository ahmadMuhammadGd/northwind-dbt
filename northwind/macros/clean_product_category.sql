
{% macro clean_product_category(column_name) %}
    (
        INITCAP(
            LOWER(
                TRIM(
                    {{ column_name }}
                    )
            )
        )
    )
{% endmacro %}