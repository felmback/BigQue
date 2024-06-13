
CREATE OR REPLACE VIEW `delivery_zone.vw_historico_manobra_cto` 
(
  OLDCTOID                  OPTIONS(description="Identificador do equipamento anterior a manobra"),
  NEWCTOID                  OPTIONS(description="Identificador do equipamento posterior a manobra"),
  MODIFICATIONDATE          OPTIONS(description="Compo referente a data em que foi feito a manobra"), 
  ORDERID                   OPTIONS(description="Identificador único de registro da criação da ordem no FullFilment One -FF1"),
  IDSERVICENAME             OPTIONS(description="Identificador único do serviço do cliente"),
  SERVICENAME               OPTIONS(description="Designador do serviço contratado pelo cliente"),
  SERVICEPROVIDE            OPTIONS(description="Identifica o provedor de serviço - cliente"),
  SURVEYID                  OPTIONS(description="Identificador único do survey"),
  SURVEYNAME                OPTIONS(description="Nome do Survey"),
  SURVEYLAT                 OPTIONS(description="Latitude do Survey"),
  SURVEYLONG                OPTIONS(description="Longitude do Survey"),
  OLDCTONAME                OPTIONS(description="Nome da antiga cto"),
  OLDCTOLAT                 OPTIONS(description="Longitude da  antiga cto"),
  OLDCTOLONG                OPTIONS(description="Longitude da  antiga cto"),
  NEWCTONAME                OPTIONS(description="Nome da nova cto"),
  NEWCTOLAT                 OPTIONS(description="Longitude da nova cto"),
  NEWCTOLONG                OPTIONS(description="Longitude da nova cto"),
  DISTANCEMAX               OPTIONS(description="Cálculo para determinar a distância entre as duas ctos manobradas."),
  ORIGEM                    OPTIONS(description="Nome da fonte de origem a qual as informações foram extraídas"),
  DT_FOTO                   OPTIONS(description="Data em que ocorreu a extração das informações e atualização da tabela")
)
OPTIONS( friendly_name="manobra_cto", description="", labels=[("eng", "manobra_cto")] ) 
AS ( 
SELECT 
OLDCTOID,
NEWCTOID,
MODIFICATIONDATE,
ORDERID,
IDSERVICENAME,
SERVICENAME,
SERVICEPROVIDE,
SURVEYID,
SURVEYNAME,
SURVEYLAT,
SURVEYLONG,
OLDCTONAME,
OLDCTOLAT,
OLDCTOLONG,
NEWCTONAME,
NEWCTOLAT,
NEWCTOLONG,
DISTANCEMAX,
ORIGEM,
DT_FOTO
 FROM `fibrasil-datalake-dev.gold_zone.tb_historico_manobra_cto`
);