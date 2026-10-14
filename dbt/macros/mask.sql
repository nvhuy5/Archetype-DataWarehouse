{# Masking for the unmasked -> masked pair (see DECISIONS.vi.md, section 2). Dropping a column needs no macro: leave it out of the masked model. #}

{# Keep the last `keep` characters, hide the rest: 0912345678 -> ***5678 #}
{% macro mask_partial(column, keep=4) -%}
    case when {{ column }} is null then null else '***' || right({{ column }}::text, {{ keep }}) end
{%- endmacro %}

{# Birthday -> age in years; the report only needs the age #}
{% macro age_from_birthday(column) -%}
    date_part('year', age(current_date, {{ column }}))::int
{%- endmacro %}
