CREATE OR REPLACE PROCEDURE `fibrasil-datalake-uat.gold_zone.sp_eop_tempo_ordens`()
OPTIONS (description="Procedure criada para inserir as infromações referente ao tempo das ordens do FF1 pegando o primeiro status e data .")
BEGIN
  DECLARE VAR_DT_FOTO DATETIME DEFAULT CURRENT_DATETIME();
  BEGIN
    SET VAR_DT_FOTO = IFNULL((SELECT MAX(DATETIME(First_Start_Time)) FROM `fibrasil-datalake-uat.gold_zone.tb_eop_tempo_ordens`),'1900-01-01');
  END;
BEGIN
CREATE TABLE IF NOT EXISTS `fibrasil-datalake-uat.gold_zone.tb_eop_tempo_ordens`
(
  ID_Access                     STRING OPTIONS(description='Identificador do Acesso, código do cliente.'),
  First_ID_Order                STRING OPTIONS(description='Identificador da Ordem, código da ordem do primeiro status'),
  First_ID_External             STRING OPTIONS(description='Identificador do externalId.'),
  First_State                   STRING OPTIONS(description='Indicador do Estado da Ordem, Ex: Completed, Failed, Cancelled primeiro status.'),
  First_Start_Time              TIMESTAMP OPTIONS(description='Data e Hora do Início da Ordem do primeiro status.'),
  Last_State                    STRING OPTIONS(description='Indicador do Estado da Ordem, Ex: Completed, Failed, Cancelled ultimo status.'),
  Last_ID_Order                 STRING OPTIONS(description='Identificador da Ordem, código da ordem do ultimo status.'),
  Last_ID_External              STRING OPTIONS(description='Identificador do externalId.'),
  Last_TS_End_Time              TIMESTAMP OPTIONS(description='Data e Hora da Conclusão da Ordem.'),
  DT_FOTO                       DATETIME OPTIONS(description='Data da atualização das informações no GCP.')
)
OPTIONS(
  description="Tabela com o tempos das ordens provenientes do FF1 entre a primeira hora início de determinada fase da ordem x última data fim da ordem pois possuímos a necessidade de controlar o tempo de cada tarefa.",
  labels=[("eop", "tb_eop_tempo_ordens")]
);

--ler a tabela fonte na silver , executa a iteração nos campos records para retornar as informações
CREATE TEMP TABLE tmp_ordem AS  (
SELECT
      ARRAY_TO_STRING(serviceIds, ',# ')                                   AS ID_Access,
      orderId                                                              AS ID_Order   ,                                           
      ord.externalId                                                       AS ID_External,
      TIMESTAMP_MILLIS(ord.startTime)                                      AS TS_Start_Time,
      TIMESTAMP_MILLIS(ord.endTime)                                        AS TS_End_Time,
      TIMESTAMP_MILLIS(ord.lastUpdate)                                     AS TS_Last_Update,
      InternalAction.action,
      InternalState.state,
      property.value                                                       AS IN_Char_Cpe_Action,
      DATETIME_SUB(CURRENT_DATETIME(), INTERVAL 3 HOUR)                    AS DT_FOTO,
    FROM `fibrasil-datalake-uat.silver_zone.fulfillmentfibrasil_swe_orders` ord
    LEFT JOIN UNNEST(internal.orderProcesses)                            AS InternalAction
    LEFT JOIN UNNEST(internal.orderProcesses)                            AS InternalState
    LEFT JOIN UNNEST ([asyncResponse])                                   AS async
    LEFT JOIN UNNEST ([async.payload])                                   AS asyncPayload
    LEFT JOIN UNNEST ([asyncPayload.event])                              AS aPayEvent
    LEFT JOIN UNNEST ([aPayEvent.serviceOrder])                          AS apeServiceOrder
    LEFT JOIN UNNEST (apeServiceOrder.orderItem)                         AS orderItem
    LEFT JOIN UNNEST ([orderItem.service])                               AS item_service
    LEFT JOIN UNNEST (item_service.resource)                             AS item_resource
    LEFT JOIN UNNEST ([item_resource.resource])                          AS resource
    LEFT JOIN UNNEST (resource.property)                                 AS property
    WHERE  DATETIME(TIMESTAMP_MILLIS(ord.startTime)) > VAR_DT_FOTO
    AND InternalAction.action ='modify' AND property.value ='add' --emparelhamento
    AND property.value IS NOT NULL
    GROUP BY ALL

);
-- ler a tabela temporaria já tratada , extrai o menor id_order ,id_external , data de inicio e o status.. assim retorna o primeira ordem com primeiro status e data
CREATE TEMP TABLE tmp_min_status as (
SELECT
  ID_Access,
  MIN(ID_Order) as First_ID_Order,
  MIN(ID_External) as First_ID_External,
  MIN(state) as First_State,
  MIN(TS_Start_Time) as First_Start_Time,
  DT_FOTO
FROM tmp_ordem
GROUP BY ALL
);
--  ler a tabela temporaria já tratada, para trazer a ultimo status e data , cruzando com a tabela do primeiro status
CREATE TEMP TABLE tb_tempo_final AS (
SELECT
  mx.ID_Access,
  mi.First_ID_Order,
  mi.First_ID_External,
  mi.First_State,
  mi.First_Start_Time,
  mx.state as Last_State,
  MAX(mx.ID_Order) as Last_ID_Order,
  MAX(mx.ID_External) as Last_ID_External,
  MAX(mx.TS_End_Time) as Last_TS_End_Time,
  mx.DT_FOTO
FROM tmp_ordem mx
INNER JOIN tmp_min_status mi on mi.ID_Access = mx.ID_Access
WHERE mx.state ='COMPLETED'
GROUP BY ALL
);

INSERT INTO    `fibrasil-datalake-uat.gold_zone.tb_eop_tempo_ordens`
(
  ID_Access,
  First_ID_Order,
  First_ID_External,
  First_State,
  First_Start_Time,
  Last_State,
  Last_ID_Order,
  Last_ID_External,
  Last_TS_End_Time,
  DT_FOTO
)

SELECT * FROM tb_tempo_final;

EXCEPTION WHEN ERROR THEN 
    SELECT
      @@error.message,
      @@error.stack_trace,
      @@error.statement_text,
      @@error.formatted_stack_trace;
    END;
END;