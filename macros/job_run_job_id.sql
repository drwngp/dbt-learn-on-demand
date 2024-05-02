{% macro job_run_job_id() -%}
    concat('{{ env_var('DBT_CLOUD_JOB_ID',  target.user  )}}'
                , '-'
                , '{{ env_var('DBT_CLOUD_RUN_ID', target.name )}}')
{%- endmacro %}