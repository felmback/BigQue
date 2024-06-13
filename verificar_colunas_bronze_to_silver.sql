SELECT distinct
bronze.column_name as bronze_column_name,
silver.column_name as silver_column_name
FROM
  `fibrasil-datalake-prd.bronze_zone.INFORMATION_SCHEMA.COLUMN_FIELD_PATHS` bronze
LEFT join `fibrasil-datalake-prd.silver_zone.INFORMATION_SCHEMA.COLUMN_FIELD_PATHS` silver
on bronze.column_name = silver.column_name

 where bronze.table_catalog ='fibrasil-datalake-prd'
 --and table_schema ='bronze_zone'
and bronze.table_name ='postgres_alarm_instance'
AND silver.column_name is null
ORDER BY 1 ASC;

