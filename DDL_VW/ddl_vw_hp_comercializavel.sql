CREATE OR REPLACE VIEW `fibrasil-datalake-dev.delivery_zone.vw_hp_comercializavel` 
( 
  UF                      OPTIONS(description="Unidade da Federação. Ex: AL, Am, SP, etc."),
  MUNICIPIO	              OPTIONS(description="Nome do Município, Ex: ARAPIRACA, MANAUS, etc."),
  UNIQUE_ID               OPTIONS(description="Identificador único da localidade. Ex: LOC0000000001215262, LOC0000000001215464, etc."),
  SURVEY_ID               OPTIONS(description="Identificador único do survey, pode ser atrelado ao campo 'id' da 'VW_vurvey' para trazer os dados de survey. Ex: 1317479, 1317602, etc."),
  NM_CTO                  OPTIONS(description="Nome do Equipamento instalado (cto) Ex: I01G0021"),
  TOTAL_UCS               OPTIONS(description="Quantidade de Unidade Consumidora . Ex: 0, 1, 2, 3, etc."),
  HP_TOTAL                OPTIONS(description="Quantidade de HP total por Município, excluído os terrenos (TA,TB,TC e EC) e criados pelo Microserviços (MS). Ex: 0, 1, 2, 3, etc."),
  HP_NAO_COMERCIALIZAVEL  OPTIONS(description="Quantidade de HP não Comercializável  por Município, expurgando os criados pelo Micro serviços (MS). Ex: 0, 1, 2, 3, etc."),
  HP_COMERCIALIZAVEL      OPTIONS(description="Quantidade de HP  Comercializável  por Município,onde são expurgados os terrenos e surveys criado pelo Micro serviços (MS) e que estão na mancha "),
  HP_TOTAL_LIMITROFE      OPTIONS(description="Quantidade de HP  contido nos limites da marcação da mancha Ex: 0, 1, 2, 3, etc."), 
  HP_MS                   OPTIONS(description="Quantidade de HP total por Município, criados pelo Microserviços (MS). Ex: 0, 1, 2, 3, etc."),
  CRIADO_EM               OPTIONS(description="Ex: 2022-04-18 18:37:37.561000 UTC, 2022-06-08 23:39:59 UTC, etc."),
  ATUALIZADO_EM           OPTIONS(description="Ex: 2022-05-23 20:55:23.042000 UTC, 2022-06-08 23:39:59 UTC, etc.")
) 
OPTIONS( friendly_name="vw_hp_comercializavel",
         description="Descrição do ativo de dado: uma visão que representa o Total de HP Comercializável utilizando como opções de dimensões Cidade e Data;" ||
                      "Domínio de dado: Financeiro - fin;"||
                      "Classificação da informação: uso público;"||
                      "Grupos de acesso: GCP_DL_PRD_BR_Data_Analytics_fin_Corporativo_Delivery;"||
                      "Período de retenção: a definir;"||
                      "Relação com indicadores no glossário de negócio: a documentar;"||
                      "Relação com termos do glossário de negócio: a documentar;"||
                      "Datatype validado pela curadoria: a validar;"||
                      "Campos “Null” validado pelo curador: a validar;",
         labels=[("eng", "engenharia")] ) 
AS (
SELECT
  ud.UF,
  ud.MUNICIPIO,
  ud.UNIQUE_ID,
  ud.SURVEY_ID,
  PDO.NAME AS NM_CTO,
  CASE WHEN ud.FLAG_MANCHA = 1 THEN SUM(TOTAL_UCS) ELSE 0 END AS TOTAL_UCS,
    SUM(
      CASE WHEN FLAG_MANCHA = 1 THEN
          CASE
            WHEN (CLASSIFICACAO_RESIDENCIAL = 'EC' 
              OR CLASSIFICACAO_RESIDENCIAL = 'TA' 
              OR CLASSIFICACAO_RESIDENCIAL = 'TB' 
              OR CLASSIFICACAO_RESIDENCIAL = 'TC'
              OR CLASSIFICACAO_RESIDENCIAL = 'MS')
            THEN 0
            WHEN 1=1 
            THEN ud.TOTAL_UCS 
            ELSE 0 
          END
      END
  ) AS HPS_TOTAL,

  SUM(
    CASE WHEN FLAG_MANCHA = 1 THEN
      CASE
        WHEN (CLASSIFICACAO_RESIDENCIAL = 'EC' 
          OR CLASSIFICACAO_RESIDENCIAL = 'TA' 
          OR CLASSIFICACAO_RESIDENCIAL = 'TB' 
          OR CLASSIFICACAO_RESIDENCIAL = 'TC'
          OR CLASSIFICACAO_RESIDENCIAL = 'MS')
        THEN 0
        WHEN (PDO.NAME LIKE '%GPF%' OR PDO.NAME LIKE '%GPV%' OR PDO.NAME IS NULL)
        THEN ud.TOTAL_UCS 
        ELSE 0 
      END
    END
  ) AS HP_NAO_COMERCIALIZAVEL,
  SUM(
      CASE WHEN FLAG_MANCHA = 1 THEN
          CASE
            WHEN (CLASSIFICACAO_RESIDENCIAL = 'EC' 
              OR CLASSIFICACAO_RESIDENCIAL = 'TA' 
              OR CLASSIFICACAO_RESIDENCIAL = 'TB' 
              OR CLASSIFICACAO_RESIDENCIAL = 'TC'
              OR CLASSIFICACAO_RESIDENCIAL = 'MS')
            THEN 0
            WHEN 1=1 
            THEN ud.TOTAL_UCS 
            ELSE 0 
          END
        END) - 
        SUM(
          CASE WHEN FLAG_MANCHA = 1 THEN
            CASE
              WHEN (CLASSIFICACAO_RESIDENCIAL = 'EC' 
                OR CLASSIFICACAO_RESIDENCIAL = 'TA' 
                OR CLASSIFICACAO_RESIDENCIAL = 'TB' 
                OR CLASSIFICACAO_RESIDENCIAL = 'TC'
                OR CLASSIFICACAO_RESIDENCIAL = 'MS')
              THEN 0
              WHEN (PDO.NAME LIKE '%GPF%' OR PDO.NAME LIKE '%GPV%' OR PDO.NAME IS NULL)
              THEN ud.TOTAL_UCS 
              ELSE 0 
            END
          END
  ) AS HP_COMERCIALIZAVEL,  
  SUM(CASE WHEN FLAG_MANCHA = 0 THEN FLAG_LIMITROFE END ) AS HP_COM_LIMITROFE,

  SUM(CASE WHEN FLAG_MANCHA = 1 THEN (CASE WHEN CLASSIFICACAO_RESIDENCIAL ='MS' THEN TOTAL_UCS ELSE 0 END ) END) AS HP_MS,
  ud.CREATED_AT                       AS CRIADO_EM,
  ud.UPDATED_AT                       AS ATUALIZADO_EM
FROM `delivery_zone.vw_hp`                 AS ud
LEFT JOIN `silver_zone.netwin_ns_res_ins_node_mirror_sbd`     AS NM
  ON ud.EQUIPMENT_ID = NM.ID_OSP
  AND NM.ENTITY_ISP = 'AC_GEN_INS_EQUIPAMENTO'
LEFT JOIN `silver_zone.netwin_osp_equipment`                  AS PDO
  ON NM.ID_OSP = PDO.ID
GROUP BY
  ud.UF,
  ud.MUNICIPIO,
  ud.UNIQUE_ID,
  ud.SURVEY_ID,
  PDO.NAME,
  ud.CREATED_AT,
  ud.UPDATED_AT,
  ud.FLAG_MANCHA

)