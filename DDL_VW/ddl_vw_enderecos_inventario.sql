CREATE OR REPLACE VIEW `delivery_zone.vw_enderecos_inventario` 
OPTIONS( friendly_name="Enderecos Inventarioy", description="", labels=[("enderecos_inventario", "enderecos")] ) 
AS ( 
 WITH SURVEY_COMPLEMENT AS (
    /* tabela de complemento para o endereço*/
  SELECT 
  EAV.ID AS LABEL_ID, 
  MAX(IT.TRANSLATION) AS  LABEL_VALUE
  FROM       `silver_zone.netwin_cat_attribute_type` TY
  INNER JOIN `silver_zone.netwin_cat_enum_attribute_value` EAV          ON EAV.ID_ATTRIBUTE_TYPE = TY.ID
  INNER JOIN `silver_zone.netwin_i18n_translation` IT                   ON IT.ID_LABEL = EAV.ID_I18N_LABEL AND IT.LOCALE = 'pt'
  WHERE TY.name = 'surveyComplementType'
  GROUP BY EAV.ID
  ),
  TB_ENDERECOS AS (
  SELECT 
  ADDRS.ID AS ID_ADDRESS,
  ADDRS.ID_BASE_ADDRESS,
  LOC.ID_LOCATION,
  AES.NAME AS FB,
  ADDRS.NAME,
  ADDRS.CLEAN_NAME,
  BA.NAME AS  BA_NAME,
  ADDRS.ATTR2 AS STREET_NUMBER,
  A.LABEL_VALUE AS  TYPE_COMPLEMENT_1,
  ADDRS.ATTR4 AS ARG_COMPLEMENT_1,
  B.LABEL_VALUE AS TYPE_COMPLEMENT_2,
  ADDRS.ATTR6 AS ARG_COMPLEMENT_2,
  C.LABEL_VALUE AS TYPE_COMPLEMENT_3,
  ADDRS.ATTR8 AS ARG_COMPLEMENT_3,
  CAST(BA.ATTR1 AS INT64) AS POSTCODE,
  CAST(BA.ATTR9 AS INT64) AS CNL,
  BA.ATTR2  AS CITY,
  BA.ATTR3  AS LOCALITY,
  BA.ATTR4  AS STATE,
  BA.ATTR14 AS SOURCE_SYSTEM, 
  BA.ATTR12 AS NUMERACAO_INICIAL,
  BA.ATTR10 AS NUMERACAO_FINAL,
  BA.ATTR11 AS PAR_IMPAR_AMBOS,
  BA.ATTR13 AS CHAVE_LOGR_DNE,
  BA.ATTR8  AS NEIGHBORHOODS,
  LOC.LATITUDE,
  LOC.LONGITUDE,
  ADDRS.EXTERNAL_CODE,
  ADDRS.PRIMARY,
  'NTW' AS ORIGEM
  FROM          `silver_zone.netwin_address` ADDRS 
  INNER JOIN     `silver_zone.netwin_base_address` BA                          ON BA.ID = ADDRS.ID_BASE_ADDRESS
  INNER JOIN    `silver_zone.netwin_address_external_system` AES              ON AES.ID_ADDRESS = ADDRS.ID
  LEFT JOIN (
              SELECT LOC.*,LAA.*,CE.NAME AS NOME_ENTIDADE
              FROM `silver_zone.netwin_location` LOC
              INNER JOIN `silver_zone.netwin_location_address_assoc` LAA ON LAA.ID_LOCATION = LOC.ID
              INNER JOIN `silver_zone.netwin_cat_entity` CE ON CE.ID = LOC.ID_CAT_ENTITY
            ) LOC on ADDRS.ID = LOC.ID_ADDRESS                             
  /*complementos do endereços*/
  LEFT JOIN      SURVEY_COMPLEMENT A                                          ON A.LABEL_ID = CAST(ADDRS.ATTR3 AS INT64)
  LEFT JOIN      SURVEY_COMPLEMENT B                                          ON B.LABEL_ID = CAST(ADDRS.ATTR5 AS INT64)
  LEFT JOIN      SURVEY_COMPLEMENT C                                          ON C.LABEL_ID = CAST(ADDRS.ATTR7 AS INT64)
  )
  SELECT * FROM TB_ENDERECOS
)