CREATE OR REPLACE VIEW `fibrasil-datalake-dev.delivery_zone.vw_hp_total_comerc_demanda` 
(
  UF                    OPTIONS(description="Unidade da Federação. Ex: AL, Am, SP, etc."),
  MUNICIPIO	            OPTIONS(description="Nome do Município, Ex: ARAPIRACA, MANAUS, etc."),
  DEMANDA               OPTIONS(description="Não informado"),
  HP_TOTAL              OPTIONS(description="Quantidade de HP total por Município, excluído os terrenos (TA,TB,TC e EC) e criados pelo Microserviços (MS). Ex: 0, 1, 2, 3, etc."),
  HP_COMERCIALIZAVEL    OPTIONS(description="Quantidade de HP total por Município, excluído os terrenos (TA,TB,TC e EC) e criados pelo Microserviços (MS) que seja abastecido(tenha cto associado) e na mancha. Ex: 0, 1, 2, 3, etc."),
  HP_TOTAL_LIMITROFE    OPTIONS(description="Marcação dos Surveys contido nos limites da marcação da mancha"),
  HP_MS                 OPTIONS(description="Quantidade de HP total por Município, criados pelo Microserviços (MS). Ex: 0, 1, 2, 3, etc."),
  DT_FOTO               OPTIONS(description="Data que as informações da  view foram atualizadas Ex: 2022-04-18 18:37:37.561000 UTC, 2022-06-08 23:39:59 UTC, etc.")
) 
OPTIONS( friendly_name="vw_hp_total_comerc_demanda",
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
            ON C.ID= S.ID_CAT_ENTITY
        LEFT JOIN `silver_zone.netwin_location_address_assoc` LA 
            ON LA.ID_LOCATION = S.ID
        LEFT OUTER JOIN `silver_zone.netwin_address` ADDRS 
            ON ADDRS.ID=LA.ID_ADDRESS
        LEFT JOIN `silver_zone.netwin_project` P 
            ON KCEL.PROJECT_ID = P.ID
        LEFT JOIN `silver_zone.netwin_equipment_survey_supply` XS 
            ON XS.SURVEY_ID = S.ID
        LEFT JOIN `silver_zone.netwin_ns_res_ins_node_mirror` NM 
            ON NM.ID_OSP= XS.EQUIPMENT_ID
        LEFT JOIN `silver_zone.netwin_isp_ins_equipamento` EQ 
            ON EQ.ID_BD_EQUIPAMENTO=NM.ID_ISP
    WHERE C.NAME LIKE 'LOC.PHYSICAL.IP.MAIN.SURVEY%'
        AND (ADDRS.PRIMARY =1
            OR ADDRS.PRIMARY IS NULL
        )
        -- AND KCEL.NAME = 'PEPTA_I02_CARVEOUT'
),
TB_FINAL AS (
    SELECT
        hpt.UF,
        hpt.MUNICIPIO,
        CELL.DEMANDA,
        SUM(hpt.HP_TOTAL) AS HP_TOTAL,
        SUM(hpc.HP_COMERCIALIZAVEL) AS HP_COMERCIALIZAVEL,
        SUM(hpc.HP_TOTAL_LIMITROFE) AS HP_TOTAL_LIMITROFE,
        SUM(hpc.HP_MS) AS HP_MS,
        CURRENT_DATE() AS DT_FOTO
    FROM `delivery_zone.vw_hp_total` as hpt
    LEFT JOIN `delivery_zone.vw_hp_comercializavel` as hpc
        ON hpt.UNIQUE_ID = hpc.UNIQUE_ID
        AND hpt.SURVEY_ID = hpc.SURVEY_ID
    LEFT JOIN CELL
        ON CELL.SURVEY_ID = hpc.SURVEY_ID
        AND hpc.NM_CTO = CELL.IDENTIFICACAO
    GROUP BY
        hpt.UF,
        hpt.Municipio,
        CELL.DEMANDA
    ORDER BY
        hpt.UF,
        hpt.Municipio
)
SELECT 
* 
FROM TB_FINAL
WHERE HP_TOTAL IS NOT NULL
ORDER BY 
UF,
Municipio
)