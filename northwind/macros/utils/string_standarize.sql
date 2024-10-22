
{% macro string_standarize(column_name) %}
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