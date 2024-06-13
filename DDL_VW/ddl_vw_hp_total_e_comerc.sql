CREATE OR REPLACE VIEW `fibrasil-datalake-dev.delivery_zone.vw_hp_total_e_comerc`
(
  UF                    OPTIONS(description="Unidade da Federação. Ex: AL, Am, SP, etc."),
  MUNICIPIO	            OPTIONS(description="Nome do Município, Ex: ARAPIRACA, MANAUS, etc."),
  HP_TOTAL              OPTIONS(description="Quantidade de HP total por Município, excluído os terrenos (TA,TB,TC e EC) e criados pelo Microserviços (MS). Ex: 0, 1, 2, 3, etc."),
  HP_COMERCIALIZAVEL    OPTIONS(description="Quantidade de HP total por Município, excluído os terrenos (TA,TB,TC e EC) e criados pelo Microserviços (MS) que seja abastecido(tenha cto associado) e na mancha. Ex: 0, 1, 2, 3, etc."),  
  HP_TOTAL_LIMITROFE    OPTIONS(description="Marcação dos Surveys contido nos limites da marcação da mancha"),
  HP_MS                 OPTIONS(description="Quantidade de HP total por Município, criados pelo Microserviços (MS). Ex: 0, 1, 2, 3, etc."),
  DT_FOTO               OPTIONS(description="Data que as informações da  view foram atualizadas Ex: 2022-04-18 18:37:37.561000 UTC, 2022-06-08 23:39:59 UTC, etc.")
) 
OPTIONS( friendly_name="vw_hp_total_e_comerc",
         description="Descrição do ativo de dado: uma visão que representa o Total de HP  com opções de dimensões Cidade e Data;" ||
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
hpt.UF,
hpt.MUNICIPIO,
hpt.HP_TOTAL,
hpt.HP_COMERCIALIZAVEL,
hpt.HP_COM_LIMITROFE,
hpt.HP_MS,
hpt.DT_FOTO
FROM `gold_zone.tb_eng_hp_total` as hpt
Where HP_TOTAL IS NOT NULL
)