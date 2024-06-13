CREATE TABLE IF NOT EXISTS  `fibrasil-datalake-uat.gold_zone.anatel_de_para_operadoras`
(
  cnpj STRING OPTIONS(description="CNPJ Operadora na base de Acessos Anatel"),
  de_operadoras STRING OPTIONS(description="Operadora na base de Reclamação Anatel"),
  para_operadoras STRING OPTIONS(description="Operadora na base de Acessos Anatel"),
  grupo_economico STRING OPTIONS(description="Agrupamento da operadoras"),
  porte_operadora STRING OPTIONS(description="Classificação das operadoras"),
)
OPTIONS(
  description="Tabela que armazena informações das prestadoras de serviço cadastrado na Anatel .",
  labels=[("anatel_de_para_operadoras", "eop")]
);

truncate table `fibrasil-datalake-uat.gold_zone.anatel_de_para_operadoras`;

insert into  `fibrasil-datalake-uat.gold_zone.anatel_de_para_operadoras`
(
  cnpj,
  de_operadoras,
  para_operadoras,
  grupo_economico,
  porte_operadora
)

WITH lista AS (
  SELECT ROW_NUMBER() OVER() AS level
  FROM UNNEST(GENERATE_ARRAY(1, 19)) AS _
),

de_para_operadoras AS (
SELECT
    CASE 
      WHEN level = 1 THEN 'ALGAR'
      WHEN level = 2 THEN 'BLINK TELECOM'
      WHEN level = 3 THEN 'BR SUPER'
      WHEN level = 4 THEN 'BRISANET'
      WHEN level = 5 THEN 'CABO TELECOM'
      WHEN level = 6 THEN 'CLARO'
      WHEN level = 7 THEN 'GB ONLINE'
      WHEN level = 8 THEN 'HUGHES'
      WHEN level = 9 THEN 'LIGGA TELECOM'
      WHEN level = 10 THEN 'MOB TELECOM'
      WHEN level = 11 THEN 'OI'
      WHEN level = 12 THEN 'OUTROS'
      WHEN level = 13 THEN 'PROXXIMA'
      WHEN level = 14 THEN 'SERCOMTEL'
      WHEN level = 15 THEN 'SKY'
      WHEN level = 16 THEN 'TIM'
      WHEN level = 17 THEN 'UNIFIQUE'
      WHEN level = 18 THEN 'VALENET'
      WHEN level = 19 THEN 'VIVO'
    END AS de_operadoras,
    CASE 
      WHEN level = 1 THEN 'ALGAR (CTBC TELECOM)'
      WHEN level = 2 THEN 'BRASIL TECPAR'
      WHEN level = 3 THEN 'RAWNET INFORMATICA LTDA'
      WHEN level = 4 THEN 'BRISANET'
      WHEN level = 5 THEN 'ALARES'
      WHEN level = 6 THEN 'CLARO'
      WHEN level = 7 THEN 'GB ONLINE TELECOMUNICACOES LTDA'
      WHEN level = 8 THEN 'HUGHES'
      WHEN level = 9 THEN 'LIGGA TELECOM'
      WHEN level = 10 THEN 'EB FIBRA'
      WHEN level = 11 THEN 'OI'
      WHEN level = 12 THEN 'OUTROS'
      WHEN level = 13 THEN 'PROXXIMA TELECOMUNICACOES S A'
      WHEN level = 14 THEN 'LIGGA TELECOM'
      WHEN level = 15 THEN 'SKY/AT&T'
      WHEN level = 16 THEN 'TIM'
      WHEN level = 17 THEN 'UNIFIQUE'
      WHEN level = 18 THEN 'COMPANHIA ITABIRANA DE TELECOMUNICACOES LTDA'
      WHEN level = 19 THEN 'VIVO'

    END AS para_operadoras,
    CASE 
      WHEN level = 1 THEN '71208516000174'
      WHEN level = 2 THEN '07756651000155'
      WHEN level = 3 THEN '05804309000158'
      WHEN level = 4 THEN '04601397000128'
      WHEN level = 5 THEN '02952192000161'
      WHEN level = 6 THEN '66970229000167'
      WHEN level = 7 THEN '05499007000113'
      WHEN level = 8 THEN '05206385000161' 
      WHEN level = 9 THEN '04368865000166'
      WHEN level = 10 THEN '07870094000107'
      WHEN level = 11 THEN '76535764000143'
      WHEN level = 12 THEN '-1'
      WHEN level = 13 THEN '40120343000104'
      WHEN level = 14 THEN '01371416000189'
      WHEN level = 15 THEN '00497373000110'
      WHEN level = 16 THEN '02421421000111'
      WHEN level = 17 THEN '02255187000108'
      WHEN level = 18 THEN '05684180000191'
      WHEN level = 19 THEN '02558157000162'
    END AS cnpj
  FROM lista
)

SELECT
coalesce(ace.cnpj,'-1') AS cnpj,
de_para.de_operadoras,
de_para.para_operadoras,
coalesce(ace. GrupoEconomico,'OUTROS') AS grupo_economico,
coalesce(ace.PortedaPrestadora,'OUTROS') AS porte_operadora

FROM de_para_operadoras de_para
LEFT JOIN (
            SELECT
            CNPJ,
            Empresa,
            GrupoEconomico,
            UPPER(PortedaPrestadora) AS PortedaPrestadora
            FROM `fibrasil-datalake-uat.bronze_zone.anatel_dados_abertos_acessos_banda_larga_fixa` 
            QUALIFY ROW_NUMBER() OVER(PARTITION BY CNPJ ORDER BY CNPJ,Empresa) = 1
) ace ON de_para.cnpj = ace.CNPJ
