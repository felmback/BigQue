CREATE OR REPLACE VIEW `delivery_zone.vw_ordem_mediana_das_fases` (
    Mediana_APROV          OPTIONS(description="Tempo médio geral entre a reserva e o aprovisioamento. Ex: 185791.0"),
    Mediana_EMP            OPTIONS(description="Tempo médio ente o aprovisioamento e o emparelhamento. Ex: 281491.0")
)
OPTIONS(
    description="Uma visão que representa as medianas do tempo entre as fases das ordens. View usada para identificar e expurgar outliers. \nDomínio de Dado: Eficiência Operacional - eop \nPeríodo de retenção: a definir \nClassificação da Informação: a definir",
    labels=[("eficiencia_operacional", "eop")]
)AS SELECT DISTINCT
    PERCENTILE_CONT(delta_aprov, 0.5)   OVER (PARTITION BY FASE_APROV)  AS Mediana_APROV,
    PERCENTILE_CONT(delta_emp, 0.5)     OVER (PARTITION BY FASE_EMP)    AS Mediana_EMP,
FROM (
    SELECT DISTINCT
        a.ID_Access,
        a.TP_Ordem AS FASE_APROV,
        b.TP_Ordem AS FASE_EMP,
        TIMESTAMP_DIFF(b.TS_Inicio_Ordem, reserva.CREATED_AT, SECOND)   AS delta_aprov,
        TIMESTAMP_DIFF(c.TS_Inicio_Ordem, a.TS_Fim_Ordem, SECOND)       AS delta_emp,
    FROM `delivery_zone.vw_ordem_aprovisionamento`                  AS a
    LEFT JOIN `delivery_zone.vw_ordem_emparelhamento`               AS b
        ON  a.ID_Access = b.ID_Access
    LEFT JOIN `delivery_zone.vw_ordem_ativacao`                     AS c
        ON  a.ID_Access = c.ID_Access
    LEFT JOIN `delivery_zone.vw_reserve`                         AS reserva
        ON CAST(reserva.ID AS STRING) = a.ID_Reserva 
        AND a.TP_Ordem = 'APROVISIONAMENTO' 
        AND reserva.STATE_LIFECYCLE = 'TERMINATED'
    WHERE a.IN_Estado_Ordem = 'COMPLETED'
)
ORDER BY Mediana_EMP DESC
LIMIT 1