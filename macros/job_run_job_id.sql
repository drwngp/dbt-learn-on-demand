{% macro job_run_job_id() -%}
    concat('{{ env_var('DBT_CLOUD_JOB_ID', 'DBT_CLOUD_JOB_ID'  )}}'
                , '-'
                , '{{ env_var('DBT_CLOUD_RUN_ID', 'DBT_CLOUD_RUN_ID'  )}}')
{%- endmacro %}