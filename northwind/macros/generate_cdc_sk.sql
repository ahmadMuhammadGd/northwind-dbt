{% macro generate_cdc_sk(columns_to_track, table_alias=None) %}
    {% if table_alias is not none %}
        {% set prefix = table_alias + '.' %}
    {% else %}
        {% set prefix = '' %}
    {% endif %}
MD5(
    {% for column in columns_to_track %}
        {{ prefix }}{{ column }}::text
        {% if not loop.last %} || {% endif %}
    {% endfor %}
 )
{% endmacro %}