with teste As (
SELECT
  REGEXP_SUBSTR(col1.table_schema, '^(.*?)_zone') AS Camada,
  REGEXP_SUBSTR(col3.table_schema, '^(.*?)_zone') AS Camada_1,
  col1.table_name AS Nome_do_Ativo,
  col1.column_name AS Nome_do_Campo,
  col3.column_name AS Nome_do_Campo_1,
  col1.data_type AS Data_Type,
  col3.data_type AS Data_Type_1,
FROM
`gold_zone.INFORMATION_SCHEMA.COLUMNS` col1
INNER JOIN `gold_zone.INFORMATION_SCHEMA.COLUMN_FIELD_PATHS` col2
ON col1.table_name = col2.table_name AND col1.column_name = col2.column_name
INNER JOIN `gold_zone.INFORMATION_SCHEMA.COLUMNS` col3
ON col1.table_name = col3.table_name AND col3.column_name = col1.column_name
INNER JOIN `gold_zone.INFORMATION_SCHEMA.COLUMN_FIELD_PATHS` col4
ON col2.table_name = col4.table_name AND col2.column_name = col4.column_name)

SELECT * FROM teste WHERE Nome_do_Ativo = 'tb_eop_ordem_fase'