CREATE TABLE IF NOT EXISTS `fibrasil-datalake-uat.gold_zone.tb_ctrl_volumetria`
    (
        TABELA STRING OPTIONS(description="Nome da tabela na camada gold"),
        CHAVE  STRING OPTIONS(description="Campo da tabela usado para contar os valores distint"),
        INDICADOR STRING OPTIONS(description="Métrica agregada"),
        VOLUME_DISTINTO INT64 OPTIONS(description="Contagem de registros distintos"),
        VOLUME_TOTAL STRING OPTIONS(description="Soma ou contagem da métrica"),
        MAX_DATA_DADOS STRING OPTIONS(description="DATA do ultimo registro da tabela"),
        DT_FOTO STRING OPTIONS(description="DATA em que o processo de coleta das informações foi executado")
    )
    


        

INSERT INTO `fibrasil-datalake-dev.gold_zone.tb_ctrl_volumetria`
(
    TABELA,
    CHAVE,
    INDICADOR,
    VOLUME_DISTINTO,
    VOLUME_TOTAL,
    MAX_DATA_DADOS,
    DT_FOTO
)

SELECT
    'gold_zone_tb_acessos_banda_larga_fixa' AS TABELA,
    'CNPJ' as CHAVE,
    'RECLAMACAO_BANDA_LARGA' AS INDICADOR,
    COUNT(DISTINCT CNPJ) AS VOLUME_DISTINTO,
    SUM(SOLICITACOES) AS VOLUME_TOTAL,
    CAST(MAX(PERIODO) AS STRING) AS MAX_DATA_DADOS,
    FORMAT_TIMESTAMP("%Y-%m-%d %H:%M", TIMESTAMP_ADD(CURRENT_DATETIME(), INTERVAL -3 HOUR)) AS DT_FOTO
FROM `fibrasil-datalake-dev.gold_zone.tb_reclamacoes_banda_larga_fixa` 
WHERE PERIODO = (SELECT MAX(PERIODO) FROM `fibrasil-datalake-dev.gold_zone.tb_reclamacoes_banda_larga_fixa` );