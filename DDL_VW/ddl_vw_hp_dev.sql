CREATE OR REPLACE VIEW `fibrasil-datalake-dev.delivery_zone.vw_hp` 
(
    UNIQUE_ID                    OPTIONS(description="Identificador único da localização do Survey. Ex: LOC0000000001204464, LOC0000000001215015, etc."),
    SURVEY_ID                    OPTIONS(description="Identificador único do Survey. Ex: 1317473, 1320816, e"),
    EXTERNAL_ID                  OPTIONS(description="Identificador único utilizado com referência na API externa (FB). Ex: 0001164638, 0001166151, etc. "),
    EQUIPMENT_ID                 OPTIONS(description="Identificador único do equipamento CTO. Ex: 1182111, 1212297, etc."),
    NOME_SURVEY                  OPTIONS(description="Descritivo do survey. Ex: “SRVNVP4265”, “13 DE MAIO (CHACARAS) 1181”, “20 DE SETEMBRO (JUVENTUDE) 253”, etc"), 
    TIPO                         OPTIONS(description="Classificação residencial. MDU=prédio e SDU=residência. Saída binária. Ex: MDU ou SDU."),
    CODIGO_IBGE                  OPTIONS(description="Código de Identificação ùnico dos Estados, Múnicípios classificados pelo IBGE Ex: 1200013"),
    CEP                          OPTIONS(description="Código de identificação Postal (Correios) Ex: 07183260"),      
    UF                           OPTIONS(description="Unidade da federação. Ex: AM, SP, RJ, etc."),
    MUNICIPIO                    OPTIONS(description="Nome do município. Não inclui “distritos”. Ex: VIANA, SARANDI, etc."),
    LOCALIDADE                   OPTIONS(description="Nome do município. Inclui “distritos”. Ex: VIANA, SARANDI, etc"),
    CNL                          OPTIONS(description="Código nacional de localidade. Ex: 71374, 51094, etc"),
    SURVEY_ENDERECO              OPTIONS(description="Endereço do survey. Endereço de um possível cliente. Ex: “RUA QUINZE DE NOVEMBRO GARIBALDI CENTRO 95720000 RS”, “RUA BUARQUE DE MACEDO GARIBALDI SANTA TEREZINHA 95720000 RS”, etc."),
    BAIRRO                       OPTIONS(description="Bairro do logradouro extraído da coluna “SURVEY_ENDERECO”. Ex: SANTA MONICA, SAO BENEDITO etc."),
    LOGRADOURO_TIPO              OPTIONS(description="Tipo do logradouro extraído da coluna “SURVEY_ENDERECO”. Ex: Rodovia, VIA, JARDIM, etc."), 
    LOGRADOURO_TITULO            OPTIONS(description="Título do Endereço Ex: presidente,major , etc. "),
    LOGRADOURO_NOME              OPTIONS(description="Título do logradouro extraído da coluna “SURVEY_ENDERECO”. Ex: SENADOR, MINISTRO, PAPA, etc."),
    LOGRADOURO_NUMERO            OPTIONS(description="Número do logradouro extraído da coluna SURVEY_E DERECO. Ex: 327,516"),
    COMPLEMENTO_01               OPTIONS(description="Não informado"),
    ARGUMENTO_01                 OPTIONS(description="Não informado"),
    COMPLEMENTO_02               OPTIONS(description="Não informado"),
    ARGUMENTO_02                 OPTIONS(description="Não informado"),
    COMPLEMENTO_03               OPTIONS(description="Não informado"),
    ARGUMENTO_03                 OPTIONS(description="Não informado"),
    CELULA                       OPTIONS(description="Não informado"),
    UFLOC                        OPTIONS(description="Não informado"),
    ARMARIO                      OPTIONS(description="Central Abastecedora (Armário , POP , etc.) "),
    DEMANDA                      OPTIONS(description="Não informado"),
    DESCRICAO                    OPTIONS(description="Não informado"),
    CELULA_LABEL                 OPTIONS(description="Não informado"),
    CELULA_N_SURVEYS             OPTIONS(description="Não informado"),
    CELULA_UCS                   OPTIONS(description="Não informado"),
    PROJETO                      OPTIONS(description="Não informado"),
    LATITUDE                     OPTIONS(description="Latitude do Endereço Ex: -3.0943788 "),
    LONGITUDE                    OPTIONS(description="Longitude do Endereço Ex: -35.2002008 "),
    CLASSIFICACAO_RESIDENCIAL    OPTIONS(description="Refere-se a Classificação da Residência Ex: Residência Classe A(RA),ResidÊncia Classe B(RB), etc."),
    CLASSIFICACAO_NEGOCIO        OPTIONS(description="Refere-se a Classificação da Negócio Ex: Residência Classe A(RA),ResidÊncia Classe B(RB), etc. "),
    TOTAL_UCS                    OPTIONS(description="Quantidade de Unidade Consumidoras Total Ex: 0, 1, 2, 3, etc."),
    UC_RESIDENCIAL               OPTIONS(description="Quantidade de Unidade Consumidoras Residencial (casa) Ex: 0, 1, 2, 3, etc."),
    UC_COMERCIAL                 OPTIONS(description="Quantidade de Unidade Consumidoras Comenrcial (lojas)  Ex: 0, 1, 2, 3, etc."),
    UC_INDUSTRIAL                OPTIONS(description="Quantidade de Unidade Consumidoras Industrial ( fábrica)    Ex: 0, 1, 2, 3, etc."),
    UC_ESCRITORIO                OPTIONS(description="Quantidade de Unidade Consumidoras Escritorio (escritorios advocacia) Ex: 0, 1, 2, 3, etc."),
    PISOS                        OPTIONS(description="Referente ao andar . Ex: 0, 1, 2, 3, etc."),
    ESTADO                       OPTIONS(description="Não informado"),
    FRACOES_DEFINIDAS            OPTIONS(description="Não informado"),
    TOTAL_FRACOES                OPTIONS(description="Não informado"),
    FLAG_MANCHA                  OPTIONS(description="Marcação dos Surveys na mancha conforme as marcações da Fibrasil"),
    FLAG_LIMITROFE               OPTIONS(description="Marcação dos Surveys contido nos limites da marcação da mancha"),
    CREATED_AT                   OPTIONS(description="Ex: 2022-04-18 18:37:37.561000 UTC, 2022-06-08 23:39:59 UTC, etc."),
    UPDATED_AT                   OPTIONS(description="Ex: 2022-05-23 20:55:23.042000 UTC, 2022-06-08 23:39:59 UTC, etc."),
    INVOKE_CONTEXT               OPTIONS(description="Origem de criação ao atualização do Survey Ex: Data Manager , Micro Serviço , Netwin, etc."),
    DT_FOTO                      OPTIONS(description="Data de atualização do script no banco Ex: 2022-04-18 18:37:37")
) 
OPTIONS( friendly_name="vw_hp",
         description="Descrição do ativo de dado: uma visão que representa as informações de HPs detalhada;" ||
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
WITH CELL AS (
  SELECT 
    KCEL.ID, 
    S.UNIQUE_ID, 
    KCEL.NAME, 
    IFNULL(SPLIT(KCEL.NAME, '_')[SAFE_OFFSET(0)], null) AS UFLOC,
    IFNULL(SPLIT(KCEL.NAME, '_')[SAFE_OFFSET(1)], null) AS ARMARIO,
    IFNULL(SPLIT(KCEL.NAME, '_')[SAFE_OFFSET(2)], null) AS DEMANDA,
    IFNULL(SPLIT(KCEL.NAME, '_')[SAFE_OFFSET(3)], null) AS DESCRICAO,
    -- KCEL.DESCRIPTION,
    KCEL.LABEL,
    KCEL.N_SURVEYS,
    KCEL.N_CLIENT_UNITS,
    P.DESCRIPTION AS PROJETO,
    XS.SURVEY_ID,
    XS.EQUIPMENT_ID,
    EQ.IDENTIFICACAO
  FROM `silver_zone.netwin_osp_cell` KCEL 
    JOIN `silver_zone.netwin_location` S
      ON ST_INTERSECTS(SAFE.ST_GEOGFROMTEXT(S.GEOM), ST_GEOGFROMTEXT(KCEL.GEOM)) = TRUE
    JOIN `silver_zone.netwin_cat_entity` C 
      ON C.ID = S.ID_CAT_ENTITY
    LEFT JOIN `silver_zone.netwin_location_address_assoc` LA 
      ON LA.ID_LOCATION = S.ID
    LEFT OUTER JOIN `silver_zone.netwin_address` ADDRS 
      ON ADDRS.ID = LA.ID_ADDRESS
    LEFT JOIN `silver_zone.netwin_project` P 
      ON KCEL.PROJECT_ID = P.ID
    LEFT JOIN `silver_zone.netwin_equipment_survey_supply` XS 
      ON XS.SURVEY_ID = S.ID
    LEFT JOIN `silver_zone.netwin_ns_res_ins_node_mirror` NM 
      ON NM.ID_OSP = XS.EQUIPMENT_ID
    LEFT JOIN `silver_zone.netwin_isp_ins_equipamento` EQ 
      ON EQ.ID_BD_EQUIPAMENTO = NM.ID_ISP
  WHERE C.NAME LIKE 'LOC.PHYSICAL.IP.MAIN.SURVEY%'
    AND (ADDRS.PRIMARY = 1
      OR ADDRS.PRIMARY IS NULL
    )
  -- AND KCEL.NAME = 'PEPTA_I02_CARVEOUT'
),
TB_FINAL AS (
  SELECT 
    ROW_NUMBER() OVER(PARTITION BY HP.UNIQUE_ID ORDER BY  HP.UPDATED_AT DESC) AS RK,
    HP.*,
    CELL.NAME             AS  CELULA,
    CELL.UFLOC,
    CELL.ARMARIO,
    CELL.DEMANDA,
    CELL.DESCRICAO,
    CELL.LABEL            AS  CELULA_LABEL,
    CELL.N_SURVEYS        AS  CELULA_N_SURVEYS,
    CELL.N_CLIENT_UNITS   AS  CELULA_UCS,
    CELL.PROJETO          AS  PROJETO
  FROM `gold_zone.tb_eng_hp` HP
    LEFT JOIN CELL
      ON CELL.UNIQUE_ID = HP.UNIQUE_ID
)
SELECT 
    UNIQUE_ID,
    SURVEY_ID,
    EXTERNAL_ID,
    EQUIPMENT_ID,
    NOME_SURVEY,
    TIPO,
    CODIGO_IBGE,
    CEP,
    UF,
    MUNICIPIO,
    LOCALIDADE,
    CNL,
    SURVEY_ENDERECO,
    BAIRRO,
    LOGRADOURO_TIPO,
    LOGRADOURO_TITULO,
    LOGRADOURO_NOME,
    LOGRADOURO_NUMERO,
    COMPLEMENTO_01,
    ARGUMENTO_01,
    COMPLEMENTO_02,
    ARGUMENTO_02,
    COMPLEMENTO_03,
    ARGUMENTO_03,
    CELULA,
    UFLOC,
    ARMARIO,
    DEMANDA,
    DESCRICAO,
    CELULA_LABEL,
    CELULA_N_SURVEYS,
    CELULA_UCS,
    PROJETO,
    LATITUDE,
    LONGITUDE,
    CLASSIFICACAO_RESIDENCIAL,
    CLASSIFICACAO_NEGOCIO,
    TOTAL_UCS,
    UC_RESIDENCIAL,
    UC_COMERCIAL,
    UC_INDUSTRIAL,
    UC_ESCRITORIO,
    PISOS,
    ESTADO,
    FRACOES_DEFINIDAS,
    TOTAL_FRACOES,
    FLAG_MANCHA,
    FLAG_LIMITROFE,
    CREATED_AT,
    UPDATED_AT,
    INVOKE_CONTEXT,
    DT_FOTO
  FROM TB_FINAL
  WHERE RK = 1
)