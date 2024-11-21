{% test scd_is_active(model, column_name, id_column) %}

SELECT {{ id_column }}, COUNT({{ column_name }})
FROM {{ model }}
WHERE {{ column_name }} IS TRUE
GROUP BY {{ id_column }}
HAVING COUNT({{ column_name }}) > 1

{% endtest %}
