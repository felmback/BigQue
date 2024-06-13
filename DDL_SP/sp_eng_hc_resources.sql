CREATE OR REPLACE PROCEDURE `fibrasil-datalake-prd.gold_zone.sp_eng_hc_resources`()
OPTIONS (description="Procedure criada para inserir a carga full das informações nas tabelas de recursos de HC")
BEGIN
  BEGIN
    BEGIN
      CREATE TEMP TABLE pipe_base_query AS
        SELECT
          CAST(nm.ID_OSP AS INT64)              AS EQUIPMENT_ID,
          ADDRS.ID                              AS ID_ADDRESS,
          cfs1.id                               AS CFS_ID,
          cfs1.external_code                    AS EXTERNAL_CODE,
          rfs1.id                               AS RFS_ID,
          rfs1.name                             AS RFS_NAME,
          rfs_nscs.`TYPE`                       AS TYPE,
          res_pipe.resource_business_name       AS RESOURCE_BUSINESS_NAME,
          
          --PORTAS
          CASE
            WHEN rfs_nscs.`TYPE` = 'RFS.PON' THEN
              REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '^[^<>]+', 1, 1)), '[^|]+', 1, 2)
            WHEN rfs_nscs.`TYPE` = 'RFS.SVLAN' THEN
              REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '^[^<>]+', 1, 1)), '[^|]+', 1, 2)
            WHEN rfs_nscs.`TYPE` = 'RFS.EVPL' THEN
              -- Valida se o tamanho da primeira parte da string é maior que 20
              CASE WHEN INSTR(res_pipe.resource_business_name,'<>', 1, 1) > 20 THEN
                -- Valida se o AGG recebe um pipe a mais que os outros padrões
                CASE WHEN STRPOS(res_pipe.resource_business_name, '|GA01|') > 0 THEN
                  -- Faz o Regex para um pipe a mais
                  REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '^[^<>]+', 1, 1)), '[^|]+', 1, 3)
                  -- Faz o Regex para a regra de negócio apresentada
                  ELSE REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '^[^<>]+', 1, 1)), '[^|]+', 1, 2)
                END
              --se o tamanho da primeira parte da string é menor que 20
              ELSE
                --Valida se o AGG recebe um pipe a mais que os outros padrões
                CASE WHEN STRPOS(res_pipe.resource_business_name, '|GA01|') > 0 THEN
                  -- Faz o Regex para um pipe a mais
                  REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '<>[^<>]+', 1, 1)), '[^|]+', 1, 3)
                  -- Faz o Regex para a regra de negócio apresentada
                  ELSE REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '<>[^<>]+', 1, 1)), '[^|]+', 1, 2)
                END
              END
          END AS PORTAS,

          -- PORTA_CTO
          CASE
            WHEN rfs_nscs.`TYPE` = 'RFS.PON' THEN
              REGEXP_EXTRACT(res_pipe.resource_business_name, r'\|([^<>]+)$')
            WHEN rfs_nscs.`TYPE` = 'RFS.SVLAN' THEN
              REGEXP_EXTRACT(res_pipe.resource_business_name, r'\|([^<>]+)$')
            WHEN rfs_nscs.`TYPE` = 'RFS.EVPL' THEN
              CASE WHEN INSTR(res_pipe.resource_business_name,'<>', 1, 1) > 20 THEN
              REGEXP_EXTRACT(res_pipe.resource_business_name, r'\|([^<>]+)$')
              ELSE REGEXP_EXTRACT(res_pipe.resource_business_name, r'\|([^<>]+)')
              END
            ELSE NULL
          END AS PORTA_CTO,
            -- OLT
          CASE
            WHEN rfs_nscs.`TYPE` = 'RFS.PON' THEN
                CASE WHEN INSTR(res_pipe.resource_business_name,'<>', 1, 1) > 20 THEN
                  SUBSTRING(res_pipe.resource_business_name, 1, STRPOS(res_pipe.resource_business_name, '|') - 1)
                  ELSE REPLACE(REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '<>[^<>]+', 1, 1)), '[^|]+', 1, 1), '<> ', '')
                END
            WHEN rfs_nscs.`TYPE` = 'RFS.SVLAN' THEN
                CASE WHEN INSTR(res_pipe.resource_business_name,'<>', 1, 1) > 20 THEN
                  SUBSTRING(res_pipe.resource_business_name, 1, STRPOS(res_pipe.resource_business_name, '|') - 1)
                  ELSE REPLACE(REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '<>[^<>]+', 1, 1)), '[^|]+', 1, 1), '<> ', '')
                END
            WHEN rfs_nscs.`TYPE` = 'RFS.EVPL' THEN
              CASE WHEN INSTR(res_pipe.resource_business_name,'<>', 1, 1) > 20 THEN
                SUBSTRING(res_pipe.resource_business_name, 1, STRPOS(res_pipe.resource_business_name, '|') - 1)
                ELSE REPLACE(REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '<>[^<>]+', 1, 1)), '[^|]+', 1, 1), '<> ', '')
                END
            ELSE NULL
          END AS EQP_OLT,
            -- CTO
          CASE
            WHEN rfs_nscs.`TYPE` = 'RFS.PON' THEN
              CASE WHEN INSTR(res_pipe.resource_business_name,'<>', 1, 1) > 20 THEN
                REPLACE(REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '<>[^<>]+', 1, 1)), '[^|]+', 1, 1), '<> ', '')
                ELSE REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '^[^<>]+', 1, 1)), '[^|]+', 1, 1)
              END
            WHEN rfs_nscs.`TYPE` = 'RFS.SVLAN' THEN
              CASE WHEN INSTR(res_pipe.resource_business_name,'<>', 1, 1) > 20 THEN
                REPLACE(REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '<>[^<>]+', 1, 1)), '[^|]+', 1, 1), '<> ', '')
                ELSE REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '^[^<>]+', 1, 1)), '[^|]+', 1, 1)
              END
            WHEN rfs_nscs.`TYPE` = 'RFS.EVPL' THEN
              CASE WHEN INSTR(res_pipe.resource_business_name,'<>', 1, 1) > 20 THEN
                REPLACE(REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '<>[^<>]+', 1, 1)), '[^|]+', 1, 1), '<> ', '')
                ELSE REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '^[^<>]+', 1, 1)), '[^|]+', 1, 1)
                END
            ELSE NULL
          END AS EQP_CTO,
          --SVLAN
          CASE
            WHEN rfs_nscs.`TYPE` = 'RFS.PON' THEN
              REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '^[^<>]+', 1, 1)), '[^|]+', 1, 3) 
            WHEN rfs_nscs.`TYPE` = 'RFS.SVLAN' THEN
              REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '^[^<>]+', 1, 1)), '[^|]+', 1, 3) 
            WHEN rfs_nscs.`TYPE` = 'RFS.EVPL' THEN
              -- Valida se o tamanho da primeira parte da string é maior que 20
              CASE WHEN INSTR(res_pipe.resource_business_name,'<>', 1, 1) > 20 THEN
                -- Valida se o AGG recebe um pipe a mais que os outros padrões
                CASE WHEN STRPOS(res_pipe.resource_business_name, '|GA01|') > 0 THEN
                  REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '^[^<>]+', 1, 1)), '[^|]+', 1, 4)
                ELSE REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '^[^<>]+', 1, 1)), '[^|]+', 1, 3)
                END
              --se o tamanho da primeira parte da string é menor que 20
              ELSE
                --Valida se o AGG recebe um pipe a mais que os outros padrões
                CASE WHEN STRPOS(res_pipe.resource_business_name, '|GA01|') > 0 THEN
                  REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '<>[^<>]+', 1, 1)), '[^|]+', 1, 4)
                ELSE REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '<>[^<>]+', 1, 1)), '[^|]+', 1, 3)
                END
              END
            WHEN rfs_nscs.`TYPE` = 'RFS.VLAN_1:N' THEN 
              '4000'
            ELSE NULL
          END AS SVLAN,
          -- CVLAN
          CASE
            WHEN rfs_nscs.`TYPE` = 'RFS.PON' THEN
              NULL
            WHEN rfs_nscs.`TYPE` = 'RFS.SVLAN' THEN
              NULL
            WHEN rfs_nscs.`TYPE` = 'RFS.EVPL' THEN
              -- Valida se o tamanho da primeira parte da string é maior que 20
              CASE WHEN INSTR(res_pipe.resource_business_name,'<>', 1, 1) > 20 THEN
                -- Valida se o AGG recebe um pipe a mais que os outros padrões
                CASE WHEN STRPOS(res_pipe.resource_business_name, '|GA01|') > 0 THEN
                  REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '^[^<>]+', 1, 1)), '[^|]+', 1, 5) 
                  ELSE REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '^[^<>]+', 1, 1)), '[^|]+', 1, 4)
                END
              --se o tamanho da primeira parte da string é menor que 20
              ELSE
                --Valida se o AGG recebe um pipe a mais que os outros padrões
                CASE WHEN STRPOS(res_pipe.resource_business_name, '|GA01|') > 0 THEN
                  REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '<>[^<>]+', 1, 1)), '[^|]+', 1, 5)
                  ELSE REGEXP_SUBSTR(TRIM(REGEXP_SUBSTR(res_pipe.resource_business_name, '<>[^<>]+', 1, 1)), '[^|]+', 1, 4)
                END
            END
            WHEN rfs_nscs.`TYPE` = 'RFS.VLAN_1:N' THEN 
              'N/A'
            ELSE NULL
          END AS CVLAN,
          cfs1.service_provider                  AS SERVICE_PROVIDER,
          nd.name                                AS ISP_EQP_NAME_CPE,
          nd.serial_number                       AS SERIAL_NUMBER,
          cpe_scv.name                           AS STATUS_CICLO_VIDA_CPE,
          cpe_sop.name                           AS STATUS_OPERACIONAL_CPE,
          icme.sigla_equip                       AS MODELO_CPE,
          eq.sigla_tecnologia                    AS TAXONOMIA_ONT,
          eq.sigla_fabricante                    AS FABRICANTE_CPE,
          eq.usage_state_date                    AS DATA_CICLO_VIDA_CPE,
          cpe_sad.name                           AS STATUS_PROVISAO_CPE,
          eq.data_estado_provisao                AS DATA_PROVISAO_CPE,
          CONCAT(cfs1.service_provider,cfs1.external_code)  AS CHAVE
        FROM
          `silver_zone.netwin_ns_ser_ins_service_sbd` cfs1
          -- ASSOCIATIVA CFS x RFS 
          LEFT JOIN `silver_zone.netwin_ns_ser_ins_servic_servic_sbd`  cfs_rfs  
              ON cfs_rfs.id_service_parent = cfs1.id
          -- RFS
          LEFT JOIN `silver_zone.netwin_ns_ser_ins_service_sbd`        rfs1 
              ON rfs1.id = cfs_rfs.id_service
          -- RFS SERVICE RESOURCE
          LEFT JOIN `silver_zone.netwin_ns_ser_ins_service_resour_sbd` rfs_res  
              ON rfs_res.id_bd_service = rfs1.id
          -- COMPLEMENTARES RFS
          LEFT JOIN `silver_zone.netwin_ns_ser_cat_service`            rfs_nscs 
              ON rfs_nscs.id_bd_cat_service = rfs1.id_bd_cat_service
          -- RESORUCE PIPE -- SERVICO -- 'RFS.PON' OU 'RFS.EVPL'
          LEFT JOIN `silver_zone.netwin_ns_res_ins_pipe_sbd`           res_pipe   
              ON res_pipe.id = rfs_res.id_bd_res_pipe
          -- NODE -- SERVICO 'RFS.CPE' 
          LEFT JOIN `silver_zone.netwin_ns_res_ins_node_sbd`           nd 
              ON nd.id = rfs_res.id_bd_res_node
          LEFT JOIN `silver_zone.netwin_isp_ins_equipamento_sbd`       eq
              ON eq.identificacao = nd.name  
          --modelo
          LEFT JOIN `silver_zone.netwin_isp_cat_modelo_equip`          icme 
              ON icme.id_bd_tipo_equip = eq.id_bd_tipo_equip
          --status_operacional
          LEFT JOIN `silver_zone.netwin_cat_state`                     cpe_sop 
              ON cpe_sop.id = eq.operational_state_id
          --status_ciclo de vida
          LEFT JOIN `silver_zone.netwin_cat_state`                   cpe_scv 
              ON cpe_scv.id = eq.usage_state_id 
          --status da procisao cpe
          LEFT JOIN `silver_zone.netwin_cat_state`                     cpe_sad 
              ON cpe_sad.id = eq.administrative_state_id
          -- equipment_id da cto
          LEFT JOIN `silver_zone.netwin_ns_res_ins_node_mirror_sbd`     AS nm   --x
              ON eq.ID_BD_EQUIPAMENTO = nm.ID_ISP
              AND nm.ENTITY_ISP = 'AC_GEN_INS_EQUIPAMENTO'
          -- id do endereço
          LEFT JOIN `silver_zone.netwin_location`                        AS LOC
              ON LOC.ID = eq.ID_BD_PI
          LEFT JOIN `silver_zone.netwin_location_address_assoc`          AS LA1
              ON CAST(LA1.ID_LOCATION AS INT64) = CAST(loc.ID AS INT64)
          LEFT JOIN `silver_zone.netwin_address`                         AS ADDRS
            ON CAST(LA1.ID_ADDRESS AS INT64) = CAST(ADDRS.ID AS INT64)
            AND ADDRS.PRIMARY = 1
          ORDER BY CFS_ID, EXTERNAL_CODE, SVLAN ASC;

      CREATE TEMP TABLE filter_pon_evpl AS
        SELECT
          CFS_ID,
          EQUIPMENT_ID,
          ID_ADDRESS,
          EXTERNAL_CODE,
          CHAVE,
          CASE WHEN `TYPE` = 'RFS.PON' THEN RESOURCE_BUSINESS_NAME ELSE NULL END AS RESOURCE_BUSINESS_NAME,
          CASE WHEN `TYPE` = 'RFS.PON' THEN PORTAS ELSE NULL END AS PORTAS,
          CASE WHEN `TYPE` = 'RFS.PON' THEN PORTA_CTO ELSE NULL END AS PORTA_CTO,
          CASE WHEN `TYPE` = 'RFS.PON' THEN EQP_OLT ELSE NULL END AS EQP_OLT,
          CASE WHEN `TYPE` = 'RFS.PON' THEN EQP_CTO ELSE NULL END AS EQP_CTO,
          CASE WHEN `TYPE` = 'RFS.EVPL' THEN CAST(SVLAN AS INT64) ELSE NULL END AS SVLAN,
          CASE WHEN `TYPE` = 'RFS.EVPL' THEN CAST(CVLAN AS INT64) ELSE NULL END AS CVLAN,
          SERVICE_PROVIDER AS TENANT,
          ISP_EQP_NAME_CPE,
          SERIAL_NUMBER,
          STATUS_CICLO_VIDA_CPE,
          STATUS_OPERACIONAL_CPE,
          MODELO_CPE,
          TAXONOMIA_ONT,
          FABRICANTE_CPE,
          DATA_CICLO_VIDA_CPE,
          STATUS_PROVISAO_CPE,
          DATA_PROVISAO_CPE
        FROM pipe_base_query
        ORDER BY EXTERNAL_CODE, SVLAN;

      CREATE TEMP TABLE svlan_cvlan_array AS
        SELECT 
          EXTERNAL_CODE,
          CHAVE,
          ARRAY_AGG(DISTINCT SVLAN IGNORE NULLS ORDER BY SVLAN) AS SVLAN_ARRAY,
          ARRAY_AGG(DISTINCT CVLAN IGNORE NULLS ORDER BY CVLAN) AS CVLAN_ARRAY,
        FROM filter_pon_evpl
        GROUP BY
          EXTERNAL_CODE,CHAVE;

      CREATE TEMP TABLE final_group_by AS
        SELECT
          EXTERNAL_CODE                                                   AS EXTERNAL_CODE,
          CHAVE,
          MIN(EQUIPMENT_ID)                                               AS EQUIPMENT_ID,
          MIN(ID_ADDRESS)                                                 AS ID_ADDRESS,
          MIN(RESOURCE_BUSINESS_NAME)                                     AS PIPE_TRAIL,
          MIN(PORTAS)                                                     AS PORTAS,
          MIN(PORTA_CTO)                                                  AS PORTA_CTO,
          MIN(EQP_OLT)                                                    AS EQP_OLT,
          MIN(EQP_CTO)                                                    AS EQP_CTO,
          MIN(TENANT)                                                     AS TENANT,
          MIN(ISP_EQP_NAME_CPE)                                           AS ISP_EQP_NAME_CPE,
          MIN(SERIAL_NUMBER)                                              AS SERIAL_NUMBER,
          MIN(STATUS_CICLO_VIDA_CPE)                                      AS STATUS_CICLO_VIDA_CPE,
          MIN(STATUS_OPERACIONAL_CPE)                                     AS STATUS_OPERACIONAL_CPE,
          MIN(MODELO_CPE)                                                 AS MODELO_CPE,
          MIN(TAXONOMIA_ONT)                                              AS TAXONOMIA_ONT,
          MIN(FABRICANTE_CPE)                                             AS FABRICANTE_CPE,
          MIN(DATA_CICLO_VIDA_CPE)                                        AS DATA_CICLO_VIDA_CPE,
          MIN(STATUS_PROVISAO_CPE)                                        AS STATUS_PROVISAO_CPE,
          MIN(DATA_PROVISAO_CPE)                                          AS DATA_PROVISAO_CPE,
          'NTW'                                                           AS ORIGEM
        FROM filter_pon_evpl
        GROUP BY
          EXTERNAL_CODE,CHAVE;

      CREATE TEMP TABLE sk_access_reserve AS
        SELECT
          a.ID_Access,
          a.ID_Reserva,
          o.IN_Service_Provider AS IN_Tenant,
          CONCAT(o.IN_Service_Provider,a.ID_Access) AS Chave,
          MAX(a.TS_Inicio_Ordem) AS TS_Inicio_Ordem,
        FROM (
          SELECT 
            ID_Access,ID_Reserva,TS_Inicio_Ordem,IN_TENANT
          FROM `gold_zone.tb_eop_ordem_fase` 
          WHERE TP_Ordem = 'APROVISIONAMENTO'
          AND IN_Estado_Ordem = 'COMPLETED'
        ) AS a
        LEFT JOIN `delivery_zone.vw_ordem_origem`            AS o
          ON  a.ID_Access = o.ID_Access AND a.IN_TENANT = o.IN_Service_Provider
        GROUP BY
          a.ID_Access,
          a.ID_Reserva,
          o.IN_Service_Provider;
    END;
    
    TRUNCATE TABLE `gold_zone.tb_eng_hc_resources`;
    INSERT INTO `gold_zone.tb_eng_hc_resources` (
      EXTERNAL_CODE
      ,ID_EQUIPAMENTO
      ,ID_Endereco
      ,SK
      ,TRILHA_EQUIPAMENTO
      ,PORTAS
      ,PORTA_CTO
      ,OLT
      ,CTO
      ,SVLAN
      ,CVLAN
      ,TENANT
      ,CPE
      ,IN_CHAR_CPE_SN
      ,STATUS_CICLO_VIDA_CPE
      ,STATUS_OPERACIONAL_CPE
      ,IN_CHAR_CPE_MODEL
      ,TAXONOMIA_ONT
      ,IN_CHAR_CPE_VENDOR
      ,DATA_CICLO_VIDA_CPE
      ,STATUS_PROVISAO_CPE
      ,DATA_PROVISAO_CPE
      ,ORIGEM
      ,DT_FOTO
    )
    SELECT
      DISTINCT
      final_group_by.EXTERNAL_CODE  AS EXTERNAL_CODE,
      EQUIPMENT_ID                  AS ID_EQUIPAMENTO,
      CAST(ID_ADDRESS AS INT64)     AS ID_Endereco,
      CONCAT(ID_ACCESS,ID_Reserva)  AS SK,
      PIPE_TRAIL                    AS TRILHA_EQUIPAMENTO,
      PORTAS,
      PORTA_CTO,
      EQP_OLT                       AS OLT,
      EQP_CTO                       AS CTO,
      ARRAY_TO_STRING(
        ARRAY(
          SELECT CAST(value AS STRING) 
          FROM UNNEST(svlan_cvlan_array.SVLAN_ARRAY) AS value 
          ORDER BY value
        ), ', '
      ) AS SVLAN,
      ARRAY_TO_STRING(
        ARRAY(
          SELECT CAST(value AS STRING) 
          FROM UNNEST(svlan_cvlan_array.CVLAN_ARRAY) AS value 
          ORDER BY value
        ), ', '
      ) AS CVLAN,
      TENANT,
      ISP_EQP_NAME_CPE              AS CPE,
      SERIAL_NUMBER                 AS IN_CHAR_CPE_SN,
      STATUS_CICLO_VIDA_CPE,
      STATUS_OPERACIONAL_CPE,
      MODELO_CPE                    AS IN_CHAR_CPE_MODEL,
      TAXONOMIA_ONT,
      FABRICANTE_CPE                AS IN_CHAR_CPE_VENDOR,
      DATA_CICLO_VIDA_CPE,
      STATUS_PROVISAO_CPE,
      DATA_PROVISAO_CPE,
      ORIGEM,
      CURRENT_DATE()                AS DT_FOTO
    FROM final_group_by
    LEFT JOIN svlan_cvlan_array
      ON final_group_by.EXTERNAL_CODE = svlan_cvlan_array.EXTERNAL_CODE
    LEFT JOIN sk_access_reserve
    ON sk_access_reserve.Chave = final_group_by.CHAVE
    --chave composta criada para ajustar a falha de carda do tenant USETELECOM
      -- ON sk_access_reserve.ID_ACCESS = final_group_by.EXTERNAL_CODE
      -- AND sk_access_reserve.IN_Tenant = final_group_by.TENANT;
    qualify row_number() over ( partition by EXTERNAL_CODE,SK, TRILHA_EQUIPAMENTO order by EXTERNAL_CODE,SK, TRILHA_EQUIPAMENTO desc) = 1 
    ;
  EXCEPTION WHEN ERROR THEN 
    SELECT
      @@error.message,
      @@error.stack_trace,
      @@error.statement_text,
      @@error.formatted_stack_trace;
  END;
END;