
{% macro clean_company_name(column_name) %}
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