CREATE OR REPLACE VIEW `delivery_zone.vw_ordem_lifecycle` (
    ID_Access          OPTIONS(description="Identificador único de acessos."),
    UF                 OPTIONS(description="Unidade da Federação. Ex: SP, MG, RJ."),
    Municipio          OPTIONS(description="Nome do Municícipio Ex: Manaus, Sao Paulo, etc"),
    CNL                OPTIONS(description="Código Nacional de Localidade: Ex: 25647, 49635, etc."),
    COD_IBGE           OPTIONS(description="Código do IBGE: Ex: 1200013, 1200328, etc."),
    IN_TENANT          OPTIONS(description="Lista de Tenants: Ex: VIVO, SKY, etc."),
    SK                 OPTIONS(description="Campo concatenado: 'ID_Access' + 'ID_Reserva'."),
    ID_Reserva         OPTIONS(description="Identificador único da Reserva. Ex: 963214567, 254695314, etc."),
    IN_Char_Cpe_SN     OPTIONS(description="Número Serial da CPE"),
    IN_Char_Cpe_Model  OPTIONS(description="Modelo da CPE"),
    IN_Char_Cpe_Vendor OPTIONS(description="Fornecedor da CPE"),
    LATITUDE           OPTIONS(description="Latitude."),
    LONGITUDE          OPTIONS(description="Longitude."),
    ORD_APROV          OPTIONS(description="Status da Ordem Ex: 'Aprovisionamento' ou 'Null'"),
    ORD_EMP            OPTIONS(description="Status da Ordem Ex: 'Emparelhamento' ou 'Null'"),
    ORD_DESEMP         OPTIONS(description="Status da Ordem Ex: 'Desemparelhamento' ou 'Null'"),
    ORD_ATIV           OPTIONS(description="Status da Ordem Ex: 'Ativação' ou 'Null'"),
    ORD_ORIGEM         OPTIONS(description="Canal de entrada da ordem API/POTAL"),
    ORD_DESC           OPTIONS(description="Status da Ordem Ex: 'Quebra' ou 'Churn' ou 'Null'"),
    TS_UPD_RESERVA     OPTIONS(description="Data e hora da reserva. Ex: 2023-03-10 18:10:39 UTC, etc."),
    TS_UPD_APROV       OPTIONS(description="Data e hora do Aprovisionamento. Ex: 2023-03-10 18:10:39 UTC, Null, etc."),
    TS_UPD_EMP         OPTIONS(description="Data e hora do Emparelhamento. Ex: 2023-03-10 18:10:39 UTC, null, etc."),
    TS_UPD_DESEMP      OPTIONS(description="Data e hora do Desemparelhamento. Ex: 2023-03-10 18:12:49 UTC, null, etc"),
    TS_UPD_ATIV        OPTIONS(description="Data e hora do Ativação. Ex: 2023-03-10 18:10:39 UTC, null, etc."),
    TS_UPD_DESC        OPTIONS(description="Data e hora da Desconexão. Ex: 2023-03-10 18:10:39 UTC, null, etc.")
)
OPTIONS(
    description="Uma visão que representa todo o ciclo de vida das ordens. \nDomínio de Dado: Eficiência Operacional - eop \nPeríodo de retenção: a definir \nClassificação da Informação: a definir \nGrupo de Acesso: \nRelacionamento com termo do Glossário: \nRelacionamento com indicadores do Glossário:",
    labels=[("eficiencia_operacional", "eop"), ("eficiencia_operacional_eop", "dominio_dado")]
)AS SELECT DISTINCT
        a.ID_Access,
        IFNULL(ba.ATTR4, NULL)              AS UF,
        IFNULL(ba.ATTR2, NULL)              AS Municipio,
        IFNULL(ba.ATTR9, NULL)             AS CNL,
        IFNULL(cn.COD_IBGE, NULL)          AS COD_IBGE, -- RN2 OK
        a.IN_TENANT,
        CONCAT(a.ID_Access,a.ID_Reserva)              AS SK,
        a.ID_Reserva,
        cpe.IN_Char_Cpe_SN,
        cpe.IN_Char_Cpe_Model,
        cpe.IN_Char_Cpe_Vendor,
        loc.LATITUDE,
        loc.LONGITUDE,
        a.TP_Ordem                                    AS ORD_APROV,
        b.TP_Ordem                                    AS ORD_EMP,
        e.TP_Ordem                                    AS ORD_DESEMP, --RN3 OK
        c.TP_Ordem                                    AS ORD_ATIV,
        c.Ordem_Origem AS ORD_ORIGEM,
        CASE
            WHEN d.TS_Ult_Atualizacao < a.TS_Ult_Atualizacao THEN NULL
            WHEN d.TP_Ordem = "DESCONEXÃO" AND c.TP_Ordem = "ATIVAÇÃO" THEN "CHURN"
            WHEN d.TP_Ordem = "DESCONEXÃO" AND c.TP_Ordem IS NULL THEN "QUEBRA"
            ELSE d.TP_Ordem
        END                                           AS ORD_DESC,
        MAX( TIMESTAMP_TRUNC(reserva.UPDATED_AT, SECOND)   )   AS TS_UPD_RESERVA,
        MAX( TIMESTAMP_TRUNC(a.TS_Ult_Atualizacao, SECOND) )   AS TS_UPD_APROV,
        MAX( TIMESTAMP_TRUNC(b.TS_Ult_Atualizacao, SECOND) )   AS TS_UPD_EMP,
        MAX( TIMESTAMP_TRUNC(e.TS_Ult_Atualizacao, SECOND) )   AS TS_UPD_DESEMP, --RN3 OK
        MAX( TIMESTAMP_TRUNC(c.TS_Ult_Atualizacao, SECOND) )   AS TS_UPD_ATIV,
        ARRAY_AGG(
                    CASE
                        WHEN d.TS_Ult_Atualizacao < a.TS_Ult_Atualizacao 
                        THEN NULL 
                        ELSE TIMESTAMP_TRUNC(d.TS_Ult_Atualizacao, SECOND) 
                    END 
                    ORDER BY a.TS_Ult_Atualizacao DESC LIMIT 1
        )[SAFE_OFFSET(0)] AS TS_UPD_DESC,
    FROM `delivery_zone.vw_ordem_aprovisionamento`       AS a
    LEFT JOIN `delivery_zone.vw_ordem_emparelhamento`    AS b
        ON  a.ID_Access = b.ID_Access
        AND a.ID_Reserva = b.ID_Reserva
        AND a.IN_TENANT = b.IN_TENANT
    LEFT JOIN (
                SELECT *
                FROM `gold_zone.tb_eop_ordem_fase` 
                WHERE TP_Ordem = 'ATIVAÇÃO' 
                    AND IN_Estado_Ordem = 'COMPLETED'
    ) AS c
        ON  a.ID_Access = c.ID_Access
        AND a.ID_Reserva = c.ID_Reserva
        AND a.IN_TENANT = c.IN_TENANT
    LEFT JOIN (
                SELECT * 
                FROM `gold_zone.tb_eop_ordem_fase` 
                WHERE TP_Ordem = 'DESCONEXÃO'
    ) AS d
        ON  a.ID_Access = d.ID_Access
        AND a.ID_Reserva = d.ID_Reserva
        AND a.IN_TENANT = d.IN_TENANT
    LEFT JOIN (
                SELECT * 
                FROM `gold_zone.tb_eop_ordem_fase` 
                WHERE TP_Ordem = 'DESEMPARELHAMENTO'
    ) AS e
        ON  a.ID_Access = e.ID_Access
        AND a.ID_Reserva = e.ID_Reserva
        AND a.IN_TENANT = e.IN_TENANT
    LEFT JOIN `delivery_zone.vw_reserve`                              AS reserva
        ON CAST(reserva.ID AS STRING) = a.ID_Reserva
    LEFT JOIN `delivery_zone.vw_address`                              AS addr
        ON addr.ID = reserva.ID_ADDRESS
    LEFT JOIN `delivery_zone.vw_base_address`                         AS ba
        ON ba.ID = addr.ID_BASE_ADDRESS
    LEFT JOIN `silver_zone.manual_dados_abertos_mun_tratado_protheus` AS cn
        ON CAST(cn.COD_CNL AS INT64) = CAST(ba.ATTR9 AS INT64)
    LEFT JOIN `delivery_zone.vw_location_address_assoc`               AS assoc
        ON addr.ID = assoc.ID_ADDRESS
    LEFT JOIN `delivery_zone.vw_location`                             AS loc
        ON assoc.ID_LOCATION = loc.ID
    LEFT JOIN (
        -- Apenas é possivel identificar a CPE quando
        -- IN_Action = modify
        -- IN_Char_Cpe_Action = add
        -- Para outros casos ira retornar Null
        SELECT
            ID_Access,
            IN_Service_Provider,
            IN_Char_Cpe_SN,
            IN_Char_Cpe_Model,
            IN_Char_Cpe_Vendor,
            TS_Start_Time,
            ROW_NUMBER() OVER (PARTITION BY ID_Access, IN_Service_Provider ORDER BY TS_Start_Time DESC ) AS RK
        FROM `delivery_zone.vw_ordem_origem`
        WHERE IN_Action = 'modify'
            AND IN_Char_Cpe_Action = 'add'
            --AND IN_Char_Cpe_SN IS NOT NULL
            --AND IN_Char_Cpe_Model IS NOT NULL
            --AND IN_Char_Cpe_Vendor IS NOT NULL
        ORDER BY
            ID_Access,
            IN_Service_Provider
    ) AS cpe
        ON  a.ID_Access = cpe.ID_Access
        AND a.IN_TENANT = cpe.IN_Service_Provider
        AND cpe.RK = 1
    WHERE a.IN_Estado_Ordem = 'COMPLETED'
    GROUP BY
        a.ID_Access,
        ba.ATTR4,
        ba.ATTR2,
        ba.ATTR9,
        cn.COD_IBGE,
        a.IN_TENANT,
        CONCAT(a.ID_Access,a.ID_Reserva),
        a.ID_Reserva,
        cpe.IN_Char_Cpe_SN,
        cpe.IN_Char_Cpe_Model,
        cpe.IN_Char_Cpe_Vendor,
        loc.LATITUDE,
        loc.LONGITUDE,
        a.TP_Ordem,
        b.TP_Ordem,
        e.TP_Ordem,
        c.TP_Ordem,
        c.Ordem_Origem,
        ORD_DESC
    ORDER BY SK DESC