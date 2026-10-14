{#
  Fails when the table has no row. Used on every raw (source) table: unique, not_null and schema_changes all pass on an empty
  table, so an empty load would otherwise go through silently and leave dwh and mart empty.
  `dbt build` runs source tests before the models that read them, so a failure here skips everything downstream.
  A table that may legitimately be empty is declared with severity warn and a comment saying why:
      tests:
        - not_empty:
            config: {severity: warn}   # reason
#}
{% test not_empty(model) %}
select 1 as empty_table
where not exists (select 1 from {{ model }})
{% endtest %}
