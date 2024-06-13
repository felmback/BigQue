CREATE OR REPLACE VIEW `delivery_zone.vw_ordem_perfil` (
    Tenant             OPTIONS(description="Tenant que criou a ordem. Ex: VIVO, SKY."),
    ID_Access          OPTIONS(description="Identificador da Ordem. Ex: 1000000005,1000000020,1000000025"),
    ID_Reserva         OPTIONS(description="Número identificador único referente a reserva. OBS (views relacionadas: campo 'ID' da vw_reserve, utilizado para obter o ID_address da view vw_address, a qual será cruzada com vw_base_address para obter as informações do endereço)."),
    SK                 OPTIONS(description="Campo concatenado: 'ID_Access' + 'ID_Reserva'."),
    DT_Ordem           OPTIONS(description="Data e Hora da Criação da Ordem. Ex: 2023-08-10 23:31:26.084000 UTC,2023-08-04 20:00:14.553000 UTC"),
    IN_Char_Profile    OPTIONS(description="Velocidade contratada, possuindo velocidade download/upload_tenant. Ex: 1GB/500MB_JUSTWEB,1MB/500K_SKY"),
    Perfil             OPTIONS(description="Valor numérico da velocidade de download contratada. Ex: 400,1, 200"),
    RN                 OPTIONS(description="Row_number, valor numérico ordenado pela data de criação de forma decrescente. Ex: 1, 2 ,3"),
    FLAG               OPTIONS(description="Flag identificando qual seria a categoria desta ordem, sendo: inadimplente, adimplente, upgrade, downgrade. Ex: X, I, A, U, D")
)
OPTIONS(
    description="Uma visão que representa a visão de movimentação dos planos que uma ordem possuía. \nDomínio de Dado: Eficiência Operacional - eop  \nClassificação da Informação: a definir \nGrupos de acesso: a definir \nPeríodo de retenção: a definir \nRelação com indicadores no glossário de negócio: a documentar \nRelação com termos do glossário de negócio: a documentar \nDatatype validado pela curadoria: a validar \nCampos “Null” validado pelo curador: a validar",
    labels=[("eficiencia_operacional", "eop")]
) AS
WITH temp_ordem_origem as (
  SELECT *,
        SUM(IF(IN_Action= 'add', 1, 0)) OVER (PARTITION BY IN_Service_Provider, ID_Access ORDER BY ID_Access, TS_Start_Time) AS grp,
      FROM `gold_zone.tb_eop_ordem_origem`
      WHERE IN_State = 'COMPLETED'
      ORDER BY
        IN_Service_Provider,
        ID_Access,
        TS_Start_Time)

,profile as (
SELECT distinct
  ord.IN_Service_Provider AS Tenant,
  ord.ID_Access,
  IF (ord.IN_Action = 'add', ord.ID_Char_Reserve, FIRST_VALUE(ord.ID_Char_Reserve) OVER (PARTITION BY ord.IN_Service_Provider, ord.ID_Access, grp ORDER BY ord.TS_Start_Time)) AS ID_Reserva,
  ord.SK_Access_Reserve as SK,
  ord.TS_Order_Date AS DT_Ordem,
  ord.TS_Start_Time,
  ord.IN_Char_Profile,
  Case
    WHEN IN_Char_Profile like "%BROADBAND%" THEN CAST(REGEXP_EXTRACT(IN_Char_Profile, r'BROADBAND_([0-9]+)') AS INT64)
    ELSE CAST(REGEXP_EXTRACT(REGEXP_EXTRACT(REGEXP_EXTRACT(REPLACE(REPLACE(IN_Char_Profile, '1GB', '1000MB'),'1G','1000MB'), r'([^/]+)'), r'([0-9]+(?:G|M|GB|MB))$'), r'[0-9]+') AS INT64) 
  END AS Perfil,
  ROW_NUMBER() OVER (PARTITION BY ID_Access ORDER BY TS_Order_Date,ord.IN_Service_Provider DESC) AS RN
FROM temp_ordem_origem as ord
WHERE IN_State = 'COMPLETED'
      and IN_CHAR_PROFILE IS NOT NULL
      AND TRIM(IN_CHAR_PROFILE) <>""
ORDER BY
  In_service_Provider,
  ID_Access,
  TS_Order_Date DESC)
SELECT
  Tenant,
  profile.ID_Access,
  ID_Reserva,
  Concat(ID_Access, ID_Reserva) as SK,
  DT_Ordem,
  IN_Char_Profile,
  CAST(
  CASE 
    WHEN Perfil >= 1024
    THEN Perfil / 1024
    ELSE Perfil
  END AS INT64) AS Perfil,
  RN,
  CASE
    WHEN Perfil = 1 THEN 'I'
    WHEN LAG(RN) OVER (PARTITION BY profile.ID_Access ORDER BY DT_Ordem,Tenant DESC) IS NULL THEN "X"
    WHEN LAG(Perfil) OVER (PARTITION BY profile.ID_Access ORDER BY DT_Ordem,Tenant DESC) = 1
      AND LAG(Perfil) OVER (PARTITION BY profile.ID_Access ORDER BY DT_Ordem,Tenant DESC) < Perfil THEN "A"
    WHEN LAG(Perfil) OVER (PARTITION BY profile.ID_Access ORDER BY DT_Ordem,Tenant DESC) = Perfil THEN "X"
    WHEN LAG(Perfil) OVER (PARTITION BY profile.ID_Access ORDER BY DT_Ordem,Tenant DESC) < Perfil THEN "U"
    WHEN LAG(Perfil) OVER (PARTITION BY profile.ID_Access ORDER BY DT_Ordem,Tenant DESC) > Perfil THEN "D"
  END AS FLAG
FROM profile
ORDER BY
  profile.tenant,
  profile.ID_Access,
  profile.DT_Ordem DESC