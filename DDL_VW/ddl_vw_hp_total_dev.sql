
CREATE OR REPLACE VIEW `fibrasil-datalake-dev.delivery_zone.vw_hp_total` 
(
  UF                    OPTIONS(description=" Unidade da Federação. Ex: AL, Am, SP, etc."),
  MUNICIPIO	            OPTIONS(description=" Nome do Município, Ex: ARAPIRACA, MANAUS, etc."),
  UNIQUE_ID             OPTIONS(description="Identificador único da localidade. Ex: LOC0000000001215262, LOC0000000001215464, etc."),
  SURVEY_ID             OPTIONS(description="Identificador único do survey, pode ser atrelado ao campo 'id' da 'VW_vurvey' para trazer os dados de survey. Ex: 1317479, 1317602, etc."),
  HP_TOTAL              OPTIONS(description="Quantidade de HP total por Município, excluído os terrenos (TA,TB,TC e EC) e criados pelo Microserviços (MS). Ex: 0, 1, 2, 3, etc."),
  HP_TOTAL_LIMITROFE    OPTIONS(description="Marcação dos Surveys contido nos limites da marcação da mancha"),
  HP_MS                 OPTIONS(description="Quantidade de HP total por Município, criados pelo Microserviços (MS). Ex: 0, 1, 2, 3, etc."),
  CRIADO_EM             OPTIONS(description="Ex: 2022-04-18 18:37:37.561000 UTC, 2022-06-08 23:39:59 UTC, etc."),
  ATUALIZADO_EM         OPTIONS(description="Ex: 2022-05-23 20:55:23.042000 UTC, 2022-06-08 23:39:59 UTC, etc.")
) 
OPTIONS( friendly_name="vw_hp_total",
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
      ud.Municipio AS MUNICIPIO,
      ud.UNIQUE_ID,
      ud.SURVEY_ID,
      SUM(CASE WHEN FLAG_MANCHA = 1 THEN
          CASE
              WHEN (CLASSIFICACAO_RESIDENCIAL NOT IN('EC','TA','TB','TC','MS') 
                      OR CLASSIFICACAO_RESIDENCIAL IS NULL) 
              THEN TOTAL_UCS
              ELSE 0
        END
      END) AS HP_TOTAL,
      SUM(CASE WHEN FLAG_MANCHA = 0 THEN FLAG_LIMITROFE ELSE 0 END)  AS HP_TOTAL_LIMITROFE,
      SUM(CASE WHEN FLAG_MANCHA = 1 THEN (CASE WHEN CLASSIFICACAO_RESIDENCIAL ='MS' THEN TOTAL_UCS ELSE 0 END ) END) AS HP_MS,
      ud.CREATED_AT                       AS CRIADO_EM,
      ud.UPDATED_AT                       AS ATUALIZADO_EM
    FROM `fibrasil-datalake-dev.delivery_zone.vw_hp`           AS ud
    GROUP BY
      ud.UNIQUE_ID,
      ud.SURVEY_ID,
      ud.UF,
      ud.TOTAL_UCS,
      ud.MUNICIPIO,
      ud.CREATED_AT,
      ud.UPDATED_AT
  )



















#### V1
-- CREATE OR REPLACE VIEW `fibrasil-datalake-dev.delivery_zone.vw_hp_total` 
-- (
--   UF                    OPTIONS(description=" Unidade da Federação. Ex: AL, Am, SP, etc."),
--   MUNICIPIO	            OPTIONS(description=" Nome do Município, Ex: ARAPIRACA, MANAUS, etc."),
--   UNIQUE_ID             OPTIONS(description="Identificador único da localidade. Ex: LOC0000000001215262, LOC0000000001215464, etc."),
--   SURVEY_ID             OPTIONS(description="Identificador único do survey, pode ser atrelado ao campo 'id' da 'VW_vurvey' para trazer os dados de survey. Ex: 1317479, 1317602, etc."),
--   HP                    OPTIONS(description="Quantidade de HP total por Município,. Ex: 0, 1, 2, 3, etc."),
--   HP_TOTAL              OPTIONS(description="Quantidade de HP total por Município, excluído os criados pelo Microserviços (MS). Ex: 0, 1, 2, 3, etc."),
--   HP_TOTAL_LIMITROFE    OPTIONS(description="Não informado"),
--   CRIADO_EM             OPTIONS(description="Ex: 2022-04-18 18:37:37.561000 UTC, 2022-06-08 23:39:59 UTC, etc."),
--   ATUALIZADO_EM         OPTIONS(description="Ex: 2022-05-23 20:55:23.042000 UTC, 2022-06-08 23:39:59 UTC, etc.")
-- ) 
-- OPTIONS( friendly_name="vw_viabilidade_cto",
--          description="Descrição do ativo de dado: uma visão que representa o Total de HP Comercializável utilizando como opções de dimensões Cidade e Data;" ||
--                       "Domínio de dado: Financeiro - fin;"||
--                       "Classificação da informação: uso público;"||
--                       "Grupos de acesso: GCP_DL_PRD_BR_Data_Analytics_fin_Corporativo_Delivery;"||
--                       "Período de retenção: a definir;"||
--                       "Relação com indicadores no glossário de negócio: a documentar;"||
--                       "Relação com termos do glossário de negócio: a documentar;"||
--                       "Datatype validado pela curadoria: a validar;"||
--                       "Campos “Null” validado pelo curador: a validar;",
--          labels=[("eng", "engenharia")] ) 
-- AS (
--   SELECT 

--       ud.UF,
--       ud.Municipio AS MUNICIPIO,
--       ud.UNIQUE_ID,
--       ud.SURVEY_ID,
--       SUM(CASE WHEN FLAG_MANCHA = 1 THEN
--           CASE
--               WHEN (CLASSIFICACAO_RESIDENCIAL NOT IN('EC','TA','TB','TC') 
--                       OR CLASSIFICACAO_RESIDENCIAL IS NULL) 
--               THEN TOTAL_UCS
--               ELSE 0
--         END
--       END) AS HP,
--       SUM(CASE WHEN FLAG_MANCHA = 1 THEN
--           CASE
--               WHEN (CLASSIFICACAO_RESIDENCIAL NOT IN('EC','TA','TB','TC','MS') 
--                       OR CLASSIFICACAO_RESIDENCIAL IS NULL) 
--               THEN TOTAL_UCS
--               ELSE 0
--         END
--       END) AS HP_TOTAL,
--       SUM(CASE WHEN FLAG_MANCHA = 0 THEN FLAG_LIMITROFE ELSE 0 END)  AS HP_TOTAL_LIMITROFE,
--       ud.CREATED_AT                       AS CRIADO_EM,
--       ud.UPDATED_AT                       AS ATUALIZADO_EM
--     FROM `fibrasil-datalake-dev.delivery_zone.vw_hp`           AS ud

--     GROUP BY
--       ud.UNIQUE_ID,
--       ud.SURVEY_ID,
--       ud.UF,
--       ud.TOTAL_UCS,
--       ud.MUNICIPIO,
--       ud.CREATED_AT,
--       ud.UPDATED_AT
--   )