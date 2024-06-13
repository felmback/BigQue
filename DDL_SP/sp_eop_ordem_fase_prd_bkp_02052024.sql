CREATE OR REPLACE PROCEDURE `fibrasil-datalake-uat.gold_zone.sp_eop_ordem_fase`()
OPTIONS (description="Procedure criada para inserir a carga full das informações na gold_zone.tb_eop_ordem_fase")
BEGIN
  DECLARE VAR_DT_FOTO DATETIME DEFAULT CURRENT_DATETIME();
  BEGIN
    SET VAR_DT_FOTO = IFNULL((SELECT MAX(DATETIME(TS_Inicio_Ordem)) FROM `gold_zone.tb_eop_ordem_fase`),'1900-01-01');
    SELECT VAR_DT_FOTO;
  END;

  BEGIN
    CREATE TEMP TABLE temp_origem AS
      SELECT *,
        SUM(IF(IN_Action= 'add', 1, 0)) OVER (
            PARTITION BY ID_Access, IN_Service_Provider 
            ORDER BY ID_Access, IN_Service_Provider, TS_Start_Time
        ) AS grp,
      FROM `gold_zone.tb_eop_ordem_origem`
      WHERE IN_State = 'COMPLETED'
      ORDER BY
        ID_Access,
        IN_Service_Provider,
        TS_Start_Time;
  END;

  CREATE TEMP TABLE temp_order_origem AS
    SELECT DISTINCT
      ord.ID_Access                                                        AS ID_Access
      ,IF ( ord.IN_Action = 'add',
            ord.ID_Char_Reserve, 
            FIRST_VALUE(ord.ID_Char_Reserve) OVER 
            (PARTITION BY ord.ID_Access, ord.IN_Service_Provider, grp 
            ORDER BY ord.TS_Start_Time)
      ) AS ID_Reserva
      ,ord.IN_State                                                        AS IN_Estado_Ordem
      ,ord.IN_Service_Provider                                             AS IN_TENANT
      ,CASE
        WHEN ord.IN_Action = 'add' THEN 'APROVISIONAMENTO'
        WHEN ord.IN_Action = 'delete' THEN 'DESCONEXÃO'
        WHEN ord.IN_Action = 'modify'
          AND ord.IN_Char_Cpe_Action = 'add' 
          AND ord.IN_Char_Cpe_Action_SWAP = 'delete'
          THEN 'SWAP de ONT'
        WHEN ord.IN_Action = 'modify' 
          AND ord.IN_Char_Cpe_Action = 'add' 
          THEN 'EMPARELHAMENTO'
        WHEN ord.IN_Action = 'modify' 
          AND ord.IN_Char_Cpe_Action_SWAP = 'delete'
          THEN 'DESEMPARELHAMENTO'
        WHEN ord.IN_Action = 'modify' 
          AND lower(ord.IN_Char_Service_State) LIKE '%active%'
          AND lower(ord.IN_Char_Service_Name) LIKE '%servicestate%' 
          THEN 'ATIVAÇÃO'
        WHEN ord.IN_Action = 'modify'
          AND lower(ord.IN_Char_Service_Name) LIKE '%serviceprofile%'
          THEN 'MODIFICAÇÃO'
        WHEN ord.IN_Action LIKE '%ollback' THEN 'ROLLBACK'
        WHEN ord.IN_Action = 'modifyPort' THEN 'MANOBRA'
        WHEN ord.IN_Action = 'reconfigureServiceProfile' THEN 'RECONFIGURAÇÃO'
      END                                                                  AS TP_Ordem
      ,ord.TS_Start_Time                                                   AS TS_Inicio_Ordem
      ,ord.TS_End_Time                                                     AS TS_Fim_Ordem
      ,ord.TS_Last_Update                                                  AS TS_Ult_Atualizacao
      ,DATETIME_SUB(CURRENT_DATETIME(), INTERVAL 3 HOUR)                   AS DT_FOTO
    FROM `temp_origem`                                                     AS ord
    WHERE ord.IN_State = 'COMPLETED'
    GROUP BY
      ID_Access
      ,ord.ID_Char_Reserve
      ,grp
      ,IN_Action
      ,IN_Estado_Ordem
      ,ord.IN_Service_Provider
      ,TP_Ordem
      ,TS_Inicio_Ordem
      ,TS_Fim_Ordem
      ,TS_Ult_Atualizacao
      ,DT_FOTO
    ORDER BY
      ord.ID_Access,
      ord.IN_Service_Provider,
      ord.TS_Start_Time; 

  BEGIN
    INSERT INTO `gold_zone.tb_eop_ordem_fase` (
      ID_Access
      ,ID_Reserva
      ,ID_Endereco
      ,ID_Endereco_Base
      ,ID_Localidade
      ,IN_Estado_Ordem
      ,IN_TENANT
      ,TP_Ordem
      ,TS_Inicio_Ordem
      ,TS_Fim_Ordem
      ,TS_Ult_Atualizacao
      ,DT_FOTO
    )
    SELECT DISTINCT
      ID_Access
      ,ID_Reserva
      ,CASE 
        WHEN net_res.ID_ADDRESS IS NULL THEN -1
        ELSE CAST(net_res.ID_ADDRESS AS INT64)
      END                                                                  AS ID_Endereco
      ,CASE 
        WHEN net_add.ID_BASE_ADDRESS IS NULL THEN -1
        ELSE CAST(net_add.ID_BASE_ADDRESS AS INT64)
      END                                                                  AS ID_Endereco_Base
      ,CASE
        WHEN net_loc.ID IS NULL THEN -1
        ELSE CAST(net_loc.ID AS INT64)
      END                                                                  AS ID_Localidade
      ,IN_Estado_Ordem
      ,IN_TENANT
      ,TP_Ordem
      ,TS_Inicio_Ordem
      ,TS_Fim_Ordem
      ,TS_Ult_Atualizacao
      ,DT_FOTO
    FROM temp_order_origem
    LEFT JOIN `silver_zone.netwin_reserve`                                 AS net_res
      ON CAST(ID_Reserva AS STRING) = CAST(net_res.ID AS STRING)
    LEFT JOIN `silver_zone.netwin_address`                                 AS net_add
      ON net_res.ID_ADDRESS = net_add.ID
    LEFT JOIN `silver_zone.netwin_location_address_assoc`                  AS net_aa
      ON net_add.ID = net_aa.ID_ADDRESS 
    LEFT JOIN `silver_zone.netwin_location`                                AS net_loc
      ON net_aa.ID_LOCATION = net_loc.ID
    WHERE DATETIME(TS_Inicio_Ordem) > VAR_DT_FOTO
    GROUP BY
      ID_Access
      ,ID_Reserva
      ,ID_Endereco
      ,ID_Endereco_Base
      ,ID_Localidade
      ,IN_Estado_Ordem
      ,IN_TENANT
      ,TP_Ordem
      ,TS_Inicio_Ordem
      ,TS_Fim_Ordem
      ,TS_Ult_Atualizacao
      ,DT_FOTO;
  EXCEPTION WHEN ERROR THEN 
    SELECT
      @@error.message,
      @@error.stack_trace,
      @@error.statement_text,
      @@error.formatted_stack_trace;
  END;
  
END;