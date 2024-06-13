CREATE OR REPLACE VIEW `delivery_zone.vw_ordem_erro` (
    ID_Access          OPTIONS(description="Código identificador único do cliente."),
    IN_Estado_Ordem    OPTIONS(description="Status da ordem"),
    IN_TENANT          OPTIONS(description="Tenant, Ex: VIVO, SKY"),
    TP_Ordem           OPTIONS(description="Tipo da ordem. Ex: APROVISIONAMENTO, DESCONEXÃO, EMPARELHAMENTO, DESEMPARELHAMENTO, ATIVAÇÃO, etc."),
    IN_Status_code      OPTIONS(description="Código de status da ordem."),
    IN_Status_Message   OPTIONS(description="Mensagem de status da ordem."),
    TS_Inicio_Ordem    OPTIONS(description="Data e hora de início da ordem. Ex: 2009-12-01 13:02:01 UTC"),
    TS_Fim_Ordem       OPTIONS(description="Data e hora de início do fim da ordem. Ex: 2009-12-01 13:02:01 UTC"),
    TS_Ult_Atualizacao OPTIONS(description="Data e hora da última atualização da ordem. Ex: 2009-12-01 13:02:01 UTC"),
    DT_FOTO            OPTIONS(description="Data de foto da ordem.")
)
OPTIONS(
    description="Uma visão que representa as ordens que ocorreram algum erro. \nDomínio de Dado: Eficiência Operacional - eop \nPeríodo de retenção: a definir \nClassificação da Informação: a definir",
    labels=[("eficiencia_operacional", "eop")]
) AS SELECT DISTINCT
  CASE 
    WHEN TRIM(ord.ID_Access) = '' 
    THEN NULL 
    ELSE ord.ID_Access
  END AS ID_Access
  ,ord.IN_State AS IN_Estado_Ordem
  ,ord.IN_Service_Provider AS IN_TENANT
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
  ,ord.IN_Status_code                                                  
  ,ord.IN_Status_Message 
  ,ord.TS_Start_Time                                                   AS TS_Inicio_Ordem
  ,ord.TS_End_Time                                                     AS TS_Fim_Ordem
  ,ord.TS_Last_Update                                                  AS TS_Ult_Atualizacao
  ,DATETIME_SUB(CURRENT_DATETIME(), INTERVAL 3 HOUR)                   AS DT_FOTO
FROM `gold_zone.tb_eop_ordem_origem`                                                     AS ord
WHERE ord.IN_State <> 'COMPLETED'
GROUP BY
  ord.ID_Access
  ,ord.IN_Status_code                                                
  ,ord.IN_Status_Message 
  ,IN_Action
  ,IN_Estado_Ordem
  ,ord.IN_Service_Provider
  ,TP_Ordem
  ,TS_Inicio_Ordem
  ,TS_Fim_Ordem
  ,TS_Ult_Atualizacao
  ,DT_FOTO
ORDER BY
  ID_Access,
  ord.IN_Service_Provider,
  ord.TS_Start_Time DESC