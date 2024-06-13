WITH teste AS (
  SELECT ARRAY_TO_STRING(ARRAY(
    SELECT CONCAT(column_name, " OPTIONS (DESCRIPTION='", CASE WHEN description IS NULL THEN "" ELSE description END, "')\n")
    FROM delivery_zone.INFORMATION_SCHEMA.COLUMN_FIELD_PATHS
    WHERE table_name = "vw_ordem_origem"
), ', ') AS concatenated_string
)
 
SELECT
  table_name,
  REGEXP_REPLACE(ddl, r"CREATE VIEW `fibrasil-datalake-prd\.delivery_zone\.vw_ordem_origem`",
    CONCAT(
      "CREATE OR REPLACE VIEW `fibrasil-datalake-prd.delivery_zone.vw_ordem_origem`\n","(" ,
      (SELECT concatenated_string FROM teste)
      ,")"))
FROM `delivery_zone.INFORMATION_SCHEMA.TABLES` as tables
WHERE table_name = "vw_ordem_origem"