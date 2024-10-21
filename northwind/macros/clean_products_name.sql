
{% macro clean_products_name(column_name) %}
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