
-- #deletar registros especificos por dadas
--   delete  `gold_zone.tb_fin_hc_total`
--   where DT_FOTO ='2024-05-24' 



#executa o insert conforme o select
-- mudar a data de acordou com as datas que serão reprocessadas , mudar o campo dt_foto e criado em

insert into `gold_zone.tb_fin_hc_total`
SELECT 
        hc.UF,
        hc.Municipio,
        REGEXP_REPLACE(hc.CFS_TIPO_SERVICO, r'^CFS\.', '') AS CFS_TIPO_SERVICO,
        hc.CFS_TENANT,
        DATE('2024-05-24') as DT_FOTO,
        COUNT(*) AS HC_TOTAL
    FROM `gold_zone.tb_fin_hc` AS hc
    WHERE CFS_STATUS_SERVICO = 'ACTIVE'
        AND CFS_STATUS_OPERACIONAL = 'ENABLED'
        AND UPPER(hc.EXTERNAL_CODE) NOT LIKE '%TEST%'
        AND UPPER(hc.EXTERNAL_CODE) NOT LIKE '%FAKE%'
        AND UPPER(hc.EXTERNAL_CODE) NOT LIKE '%ROLL%'
        AND UPPER(hc.EXTERNAL_CODE) NOT LIKE '%SANIT%'
        AND DT_FIM_VIGENCIA = '2100-12-31'
        AND ID_ADDRESS IS NOT NULL
        AND hc.CFS_CRIADO_EM <= '2024-05-24'
    GROUP BY
        hc.CFS_TENANT,
        hc.CFS_TIPO_SERVICO,
        hc.UF,
        hc.DT_FOTO,
        hc.MUNICIPIO

