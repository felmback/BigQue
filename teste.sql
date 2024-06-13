SELECT
    'teste de script' as teste ,
      ARRAY_TO_STRING(serviceIds, ',# ')                                   AS ID_Access,
      orderId                                                              AS ID_Order   ,                                           
      ord.externalId                                                       AS ID_External,
      TIMESTAMP_MILLIS(ord.startTime)                                      AS TS_Start_Time,
      TIMESTAMP_MILLIS(ord.endTime)                                        AS TS_End_Time,
      TIMESTAMP_MILLIS(ord.lastUpdate)                                     AS TS_Last_Update,
      InternalAction.action,
      InternalState.state,
      property.value                                                       AS IN_Char_Cpe_Action,
    FROM `fibrasil-datalake-dev.silver_zone.fulfillmentfibrasil_swe_orders` ord
    INNER JOIN UNNEST(internal.orderProcesses)                            AS InternalAction
    INNER JOIN UNNEST(internal.orderProcesses)                            AS InternalState
    INNER JOIN UNNEST ([asyncResponse])                                   AS async
    INNER JOIN UNNEST ([async.payload])                                   AS asyncPayload
    INNER JOIN UNNEST ([asyncPayload.event])                              AS aPayEvent
    INNER JOIN UNNEST ([aPayEvent.serviceOrder])                          AS apeServiceOrder
    INNER JOIN UNNEST (apeServiceOrder.orderItem)                         AS orderItem
    INNER JOIN UNNEST ([orderItem.service])                               AS item_service
    INNER JOIN UNNEST (item_service.resource)                             AS item_resource
    INNER JOIN UNNEST ([item_resource.resource])                          AS resource
    INNER JOIN UNNEST (resource.property)                                 AS property
    where  'ULA-60022569-069' in unnest(serviceIds)
    AND  InternalAction.action ='modify' AND property.value ='add' --emparelhamento
    AND property.value IS NOT NULL
    GROUP BY ALL
    ORDER BY TS_Start_Time
