CREATE OR REPLACE VIEW `fibrasil-datalake-dev.delivery_zone.vw_tempo_ordens`
(
  ID_Access          OPTIONS(description='Identificador do Acesso, código do cliente.'),
  First_ID_Order     OPTIONS(description='Identificador da Ordem, código da ordem do primeiro status'),
  First_ID_External  OPTIONS(description='Identificador do externalId.'),
  First_State        OPTIONS(description='Indicador do Estado da Ordem, Ex: Completed, Failed, Cancelled primeiro status.'),
  First_Start_Time   OPTIONS(description='Data e Hora do Início da Ordem do primeiro status.'),
  Last_State         OPTIONS(description='Indicador do Estado da Ordem, Ex: Completed, Failed, Cancelled ultimo status.'),
  Last_ID_Order      OPTIONS(description='Identificador da Ordem, código da ordem do ultimo status.'),
  Last_ID_External   OPTIONS(description='Identificador do externalId.'),
  Last_TS_End_Time   OPTIONS(description='Data e Hora da Conclusão da Ordem.'),
  DT_FOTO            OPTIONS(description='Data da atualização das informações no GCP.')
)
OPTIONS( friendly_name="vw_tempo_ordens", description="View com o tempos das ordens provenientes do FF1 entre a primeira hora início de determinada fase da ordem x última data fim da ordem pois possuímos a necessidade de controlar o tempo de cada tarefa.", labels=[("eop", "vw_tempo_ordens")] )
AS (
select 
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
from `fibrasil-datalake-dev.gold_zone.tb_eop_tempo_ordens`
)