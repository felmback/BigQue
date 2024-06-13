CREATE OR REPLACE PROCEDURE `fibrasil-datalake-dev.gold_zone.sp_eng_hp`()
OPTIONS (description="Procedure criada para inserir os dadaos de HP na tabela tb_eng_hp")
BEGIN
    DECLARE VAR_DT_UPDATED DEFAULT CURRENT_DATETIME();
    DECLARE VAR_DT_CREATED DEFAULT CURRENT_DATETIME();
    BEGIN
        -- BUSCA A ÚLTIMA DATA DE PROCESSAMENTO DA TABELA DA GOLD
        SET VAR_DT_UPDATED = IFNULL((SELECT MAX(DATETIME(UPDATED_AT)) FROM `gold_zone.tb_eng_hp`),'1900-01-01');
        SET VAR_DT_CREATED = IFNULL((SELECT MAX(DATETIME(CREATED_AT)) FROM `gold_zone.tb_eng_hp`),'1900-01-01');
        SELECT VAR_DT_UPDATED;
        SELECT VAR_DT_CREATED;
    END;
    BEGIN
        -- SELECT DOS DADOS NOVOS QUE SERÃO INSERIDOS POSTERIORMENTE ONDE DATETIME(TMP.CREATED_AT) > A ÚLTIMA DATA DE PROCESSAMENTO DA TABELA DA GOLD;
        CREATE TEMP TABLE TABLE_DATA_NEW AS 
            SELECT
                ROW_NUMBER() OVER (PARTITION BY TMP.UNIQUE_ID ORDER BY TMP.UNIQUE_ID,TMP.UPDATED_AT DESC) AS rk,
                TMP.UNIQUE_ID,                          
                TMP.ID                  AS  SURVEY_ID,            
                AES.NAME                AS  EXTERNAL_ID,
                TMP.EQUIPMENT_ID,                        
                TMP.NAME                AS  NOME_SURVEY,                
                TMP.TIPO                AS  TIPO,                      
                CAST(LOC.IBGE AS INT64) AS  CODIGO_IBGE,
                ADDR.POSTCODE           AS  CEP,
                ADDR.STATE              AS  UF,
                ADDR.CITY               AS  MUNICIPIO,
                ADDR.LOCALITY           AS  LOCALIDADE,
                CAST(ADDR.CNL AS INT64) AS  CNL,
                ADDR.NAME               AS  SURVEY_ENDERECO,
                ADDR.NEIGHBORHOODS      AS  BAIRRO,
                ADDR.STREET_TYPE        AS  LOGRADOURO_TIPO,
                ADDR.STREET_TITLE       AS  LOGRADOURO_TITULO,
                ADDR.STREET_NAME        AS  LOGRADOURO_NOME,
                ADDR.STREET_NUMBER      AS  LOGRADOURO_NUMERO,
                ADDR.TYPE_COMPLEMENT_1  AS  COMPLEMENTO_01,
                ADDR.ARG_COMPLEMENT_1   AS  ARGUMENTO_01,
                ADDR.TYPE_COMPLEMENT_2  AS  COMPLEMENTO_02,
                ADDR.ARG_COMPLEMENT_2   AS  ARGUMENTO_02,
                ADDR.TYPE_COMPLEMENT_3  AS  COMPLEMENTO_03,
                ADDR.ARG_COMPLEMENT_3   AS  ARGUMENTO_03,
                TMP.LATITUDE            AS  LATITUDE,              
                TMP.LONGITUDE           AS  LONGITUDE,            
                CASE
                    WHEN END_COMPL_CLASS.BUSINESS_RESIDENCIA_COMPLE = 'surveyResidentialClassification'
                    THEN END_COMPL_CLASS.LABEL_VALUE
                END AS CLASSIFICACAO_RESIDENCIAL,
                CASE
                    WHEN END_COMPL_CLASS.BUSINESS_RESIDENCIA_COMPLE = 'surveyBusinessClassification'
                    THEN END_COMPL_CLASS.LABEL_VALUE
                END AS  CLASSIFICACAO_NEGOCIO,
                CAST(TMP.CLIENT_UNIT_QTY AS INT64)     AS  TOTAL_UCS,      
                CAST(TMP.RESIDENCY_UNIT_QTY AS INT64)  AS  UC_RESIDENCIAL,
                CAST(TMP.COMMERCE_UNIT_QTY AS INT64)   AS  UC_COMERCIAL,
                CAST(TMP.INDUSTRY_UNIT_QTY AS INT64)   AS  UC_INDUSTRIAL,
                CAST(TMP.OFFICE_UNIT_QTY AS INT64)     AS  UC_ESCRITORIO,
                TMP.FLOOR_QTY           AS  PISOS,              
                CASE
                    WHEN (TMP.TIPO = 'MDU')
                    THEN COALESCE(CEAV.VALUE, 'EM PROSPECÇÃO')
                    ELSE NULL
                END AS  ESTADO, 
                CASE
                    WHEN (TMP.DEFINED_FRACTION = '1' )
                        THEN 'SIM' 
                    WHEN (TMP.DEFINED_FRACTION = '0' )
                        THEN 'NAO' 
                END AS  FRACOES_DEFINIDAS,
                TMP.TOTAL_FRACTIONS         AS TOTAL_FRACOES,
                NULL                        AS FLAG_MANCHA,
                NULL                        AS FLAG_LIMITROFE,
                TMP.CREATED_AT,
                TMP.UPDATED_AT,
                UPPER(TMP.INVOKE_CONTEXT) AS INVOKE_CONTEXT
            FROM `gold_zone.tb_eng_survey`                          AS TMP  
            INNER JOIN `gold_zone.tb_eng_endereco`                  AS ADDR
                ON ADDR.ID_ADDRESS = TMP.ID_ADDRESS
                AND ADDR.PRIMARY = 1
            LEFT JOIN `silver_zone.netwin_osp_equipment`            AS PDO
             ON PDO.ID = TMP.EQUIPMENT_ID
            LEFT JOIN `silver_zone.netwin_ns_res_ins_node_mirror_sbd` as NM
                ON PDO.ID = NM.ID_OSP
                AND NM.ENTITY_ISP = 'AC_GEN_INS_EQUIPAMENTO'
            LEFT JOIN `silver_zone.netwin_isp_ins_equipamento_sbd` as IEQ
                ON IEQ.ID_BD_EQUIPAMENTO = NM.ID_ISP
            LEFT JOIN `silver_zone.netwin_cat_state`                       AS CTO_CAT_OPE  
                ON CTO_CAT_OPE.ID = IEQ.OPERATIONAL_STATE_ID
            LEFT JOIN `silver_zone.netwin_cat_state`                       AS CTO_CAT_USA  
                ON CTO_CAT_USA.ID = IEQ.USAGE_STATE_ID
            LEFT JOIN `gold_zone.vwm_eng_munic_Location_uf`         AS LOC
                ON TMP.ID_DEFAULT_LIMIT = LOC.ID_LOCALIDADE
            INNER JOIN `silver_zone.netwin_address_external_system` AS AES
                ON AES.ID_ADDRESS = ADDR.ID_ADDRESS
            LEFT JOIN `gold_zone.tb_eng_Endereco_Complemento_Class` AS END_COMPL_CLASS
                ON END_COMPL_CLASS.LABEL_ID = TMP.ID_RESIDENTIAL_CLASS
            LEFT JOIN `silver_zone.netwin_cat_enum_attribute_value` AS CEAV
                ON TMP.REQUEST_META_DATA = CAST(CEAV.ID AS STRING)
            LEFT JOIN `silver_zone.netwin_cat_enum_attribute_value` AS CEAV_1
                ON TMP.DEFINED_FRACTION = CAST(CEAV_1.ID AS STRING)
            WHERE
                DATETIME(TMP.CREATED_AT) > VAR_DT_CREATED;

        -- TODOS OS DADOS DA ENTIDADE QUE FORAM ATUALIZADOS, SENDO (TMP.UPDATED_AT) >= A ÚLTIMA DATA DE PROCESSAMENTO DA TABELA DA GOLD
        CREATE TEMP TABLE TABLE_DATA_UPDATED AS 
            SELECT
                ROW_NUMBER() OVER (PARTITION BY TMP.UNIQUE_ID ORDER BY TMP.UNIQUE_ID,TMP.UPDATED_AT DESC) AS rk,
                TMP.UNIQUE_ID,                          
                TMP.ID                  AS  SURVEY_ID,            
                AES.NAME                AS  EXTERNAL_ID,
                TMP.EQUIPMENT_ID,                        
                TMP.NAME                AS  NOME_SURVEY,                
                TMP.TIPO                AS  TIPO,                      
                CAST(LOC.IBGE AS INT64) AS  CODIGO_IBGE,
                ADDR.POSTCODE           AS  CEP,
                ADDR.STATE              AS  UF,
                ADDR.CITY               AS  MUNICIPIO,
                ADDR.LOCALITY           AS  LOCALIDADE,
                CAST(ADDR.CNL AS INT64) AS  CNL,
                ADDR.NAME               AS  SURVEY_ENDERECO,
                ADDR.NEIGHBORHOODS      AS  BAIRRO,
                ADDR.STREET_TYPE        AS  LOGRADOURO_TIPO,
                ADDR.STREET_TITLE       AS  LOGRADOURO_TITULO,
                ADDR.STREET_NAME        AS  LOGRADOURO_NOME,
                ADDR.STREET_NUMBER      AS  LOGRADOURO_NUMERO,
                ADDR.TYPE_COMPLEMENT_1  AS  COMPLEMENTO_01,
                ADDR.ARG_COMPLEMENT_1   AS  ARGUMENTO_01,
                ADDR.TYPE_COMPLEMENT_2  AS  COMPLEMENTO_02,
                ADDR.ARG_COMPLEMENT_2   AS  ARGUMENTO_02,
                ADDR.TYPE_COMPLEMENT_3  AS  COMPLEMENTO_03,
                ADDR.ARG_COMPLEMENT_3   AS  ARGUMENTO_03,
                TMP.LATITUDE            AS  LATITUDE,              
                TMP.LONGITUDE           AS  LONGITUDE,            
                CASE
                    WHEN END_COMPL_CLASS.BUSINESS_RESIDENCIA_COMPLE = 'surveyResidentialClassification'
                    THEN END_COMPL_CLASS.LABEL_VALUE
                END AS CLASSIFICACAO_RESIDENCIAL,
                CASE
                    WHEN END_COMPL_CLASS.BUSINESS_RESIDENCIA_COMPLE = 'surveyBusinessClassification'
                    THEN END_COMPL_CLASS.LABEL_VALUE
                END AS  CLASSIFICACAO_NEGOCIO,
                CAST(TMP.CLIENT_UNIT_QTY AS INT64)     AS  TOTAL_UCS,      
                CAST(TMP.RESIDENCY_UNIT_QTY AS INT64)  AS  UC_RESIDENCIAL,
                CAST(TMP.COMMERCE_UNIT_QTY AS INT64)   AS  UC_COMERCIAL,
                CAST(TMP.INDUSTRY_UNIT_QTY AS INT64)   AS  UC_INDUSTRIAL,
                CAST(TMP.OFFICE_UNIT_QTY AS INT64)     AS  UC_ESCRITORIO,
                TMP.FLOOR_QTY           AS  PISOS,              
                CASE
                    WHEN (TMP.TIPO = 'MDU')
                    THEN COALESCE(CEAV.VALUE, 'EM PROSPECÇÃO')
                    ELSE NULL
                END AS  ESTADO, 
                CASE
                    WHEN (TMP.DEFINED_FRACTION = '1' )
                        THEN 'SIM' 
                    WHEN (TMP.DEFINED_FRACTION = '0' )
                        THEN 'NAO' 
                END AS  FRACOES_DEFINIDAS,
                TMP.TOTAL_FRACTIONS     AS TOTAL_FRACOES,
                NULL                    AS FLAG_MANCHA,
                NULL                    AS FLAG_LIMITROFE,
                TMP.CREATED_AT,
                TMP.UPDATED_AT,
                UPPER(TMP.INVOKE_CONTEXT) AS INVOKE_CONTEXT
            FROM `gold_zone.tb_eng_survey`                          AS TMP  
            INNER JOIN `gold_zone.tb_eng_endereco`                  AS ADDR
                ON ADDR.ID_ADDRESS = TMP.ID_ADDRESS
                AND ADDR.PRIMARY = 1
            LEFT JOIN `silver_zone.netwin_osp_equipment`            AS PDO
                ON PDO.ID = TMP.EQUIPMENT_ID
            LEFT JOIN `silver_zone.netwin_ns_res_ins_node_mirror_sbd` as NM
                ON PDO.ID = NM.ID_OSP
                AND NM.ENTITY_ISP = 'AC_GEN_INS_EQUIPAMENTO'
            LEFT JOIN `silver_zone.netwin_isp_ins_equipamento_sbd` as IEQ
                ON IEQ.ID_BD_EQUIPAMENTO = NM.ID_ISP
            LEFT JOIN `silver_zone.netwin_cat_state`                       AS CTO_CAT_OPE  
                ON CTO_CAT_OPE.ID = IEQ.OPERATIONAL_STATE_ID
            LEFT JOIN `silver_zone.netwin_cat_state`                       AS CTO_CAT_USA  
                ON CTO_CAT_USA.ID = IEQ.USAGE_STATE_ID
            LEFT JOIN `gold_zone.vwm_eng_munic_Location_uf`         AS LOC
                ON TMP.ID_DEFAULT_LIMIT = LOC.ID_LOCALIDADE
            INNER JOIN `silver_zone.netwin_address_external_system` AS AES
                ON AES.ID_ADDRESS = ADDR.ID_ADDRESS
            LEFT JOIN `gold_zone.tb_eng_Endereco_Complemento_Class` AS END_COMPL_CLASS
                ON END_COMPL_CLASS.LABEL_ID = TMP.ID_RESIDENTIAL_CLASS
            LEFT JOIN `silver_zone.netwin_cat_enum_attribute_value` AS CEAV
                ON TMP.REQUEST_META_DATA = CAST(CEAV.ID AS STRING)
            LEFT JOIN `silver_zone.netwin_cat_enum_attribute_value` AS CEAV_1
                ON TMP.DEFINED_FRACTION = CAST(CEAV_1.ID AS STRING)
            WHERE (DATETIME(TMP.UPDATED_AT) > VAR_DT_UPDATED AND DATETIME(TMP.CREATED_AT) <= VAR_DT_CREATED);

        -- TRAZ AS CHAVES DOS DADOS ATUALZIADOS COM SUA ULTIMA DATA DE ATUALIZAÇÃO NA GOLD, ONDE POSTERIORMENTE SERÁ REALIZADO O FECHAMENTO DA DT_FIM_VIGENCIA
        CREATE TEMP TABLE TABLE_DATA_ULTIMA AS 
            SELECT DISTINCT
                A.UNIQUE_ID,
                A.MUNICIPIO,
                B.UPDATED_AT
            FROM
                (SELECT DISTINCT 
                    *
                FROM TABLE_DATA_UPDATED AS UP
                ORDER BY UPDATED_AT DESC
            ) AS A
            -- INNER JOIN COM A TABELA DA GOLD 
            INNER JOIN (
                SELECT DISTINCT
                    *,
                    ROW_NUMBER() OVER(PARTITION BY UNIQUE_ID ORDER BY UNIQUE_ID, UPDATED_AT DESC) AS ORDEM
                FROM `gold_zone.tb_eng_hp` 
            ) AS B
                ON A.UNIQUE_ID = B.UNIQUE_ID
                AND B.ORDEM = A.rk
                AND REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE(LOWER(TRIM(concat(A.MUNICIPIO))), "[àáâãäå]", "a"), "[éèëê]", "e"), "[íìï]", "i" ), "[óòôõö]", "o" ), "[úùûü]", "u" ), "ç", "c" ), " ", "" ), "[-_@ ]", "" ) = REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE(LOWER(TRIM(concat(B.MUNICIPIO))), "[àáâãäå]", "a"), "[éèëê]", "e"), "[íìï]", "i" ), "[óòôõö]", "o" ), "[úùûü]", "u" ), "ç", "c" ), " ", "" ), "[-_@ ]", "" );


    END;

    -- BLOCO PARA TRATAR OS NOVOS REGISTROS
    BEGIN
        -- INSERE OS NOVOS REGISTROS NA TABELA GOLD
        INSERT INTO `gold_zone.tb_eng_hp` (UNIQUE_ID, SURVEY_ID, EXTERNAL_ID, EQUIPMENT_ID, NOME_SURVEY, TIPO, CODIGO_IBGE, CEP, UF, MUNICIPIO, LOCALIDADE, CNL, SURVEY_ENDERECO, BAIRRO, LOGRADOURO_TIPO, LOGRADOURO_TITULO, LOGRADOURO_NOME, LOGRADOURO_NUMERO, COMPLEMENTO_01, ARGUMENTO_01, COMPLEMENTO_02, ARGUMENTO_02, COMPLEMENTO_03, ARGUMENTO_03, LATITUDE, LONGITUDE, CLASSIFICACAO_RESIDENCIAL, CLASSIFICACAO_NEGOCIO, TOTAL_UCS, UC_RESIDENCIAL, UC_COMERCIAL, UC_INDUSTRIAL, UC_ESCRITORIO, PISOS, ESTADO, FRACOES_DEFINIDAS, TOTAL_FRACOES, FLAG_MANCHA, FLAG_LIMITROFE, CREATED_AT, UPDATED_AT,INVOKE_CONTEXT, DT_INI_VIGENCIA, DT_FIM_VIGENCIA, DT_FOTO)
        SELECT DISTINCT * except (rk), CURRENT_DATE() AS DT_INI_VIGENCIA, PARSE_DATE("%Y-%m-%d","2100-12-31") AS DT_FIM_VIGENCIA, CURRENT_DATE() AS DT_FOTO 
        FROM TABLE_DATA_NEW
        WHERE rk = 1;
    
    EXCEPTION WHEN ERROR THEN
        SELECT
            @@error.message,
            @@error.stack_trace,
            @@error.statement_text,
            @@error.formatted_stack_trace;

    END;

 
    -- BLOCO PARA REALIZAR O TRATAMENTO DOS DADOS QUE FORAM ATUALIZADOS
    BEGIN
        -- FECHA A VIGÊNCIA DAS ENTIDADES QUE ESTÃO SENDO ATUALIZADAS
        UPDATE `gold_zone.tb_eng_hp` AS T
        SET DT_FIM_VIGENCIA = CURRENT_DATE()
        FROM TABLE_DATA_ULTIMA ALT
        WHERE T.UNIQUE_ID = ALT.UNIQUE_ID 
            AND T.UPDATED_AT = ALT.UPDATED_AT
            AND REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE(LOWER(TRIM(concat(T.MUNICIPIO))), "[àáâãäå]", "a"), "[éèëê]", "e"), "[íìï]", "i" ), "[óòôõö]", "o" ), "[úùûü]", "u" ), "ç", "c" ), " ", "" ), "[-_@ ]", "" ) = REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE(LOWER(TRIM(concat(ALT.MUNICIPIO))), "[àáâãäå]", "a"), "[éèëê]", "e"), "[íìï]", "i" ), "[óòôõö]", "o" ), "[úùûü]", "u" ), "ç", "c" ), " ", "" ), "[-_@ ]", "" );

    EXCEPTION WHEN ERROR THEN
        SELECT
            @@error.message,
            @@error.stack_trace,
            @@error.statement_text,
            @@error.formatted_stack_trace;

    END;
    
    BEGIN

        -- INSERE OS DADOS QUE FORAM ATUALIZADOS
        INSERT INTO `gold_zone.tb_eng_hp` (UNIQUE_ID, SURVEY_ID, EXTERNAL_ID, EQUIPMENT_ID, NOME_SURVEY, TIPO, CODIGO_IBGE, CEP, UF, MUNICIPIO, LOCALIDADE, CNL, SURVEY_ENDERECO, BAIRRO, LOGRADOURO_TIPO, LOGRADOURO_TITULO, LOGRADOURO_NOME, LOGRADOURO_NUMERO, COMPLEMENTO_01, ARGUMENTO_01, COMPLEMENTO_02, ARGUMENTO_02, COMPLEMENTO_03, ARGUMENTO_03, LATITUDE, LONGITUDE, CLASSIFICACAO_RESIDENCIAL, CLASSIFICACAO_NEGOCIO, TOTAL_UCS, UC_RESIDENCIAL, UC_COMERCIAL, UC_INDUSTRIAL, UC_ESCRITORIO, PISOS, ESTADO, FRACOES_DEFINIDAS, TOTAL_FRACOES, FLAG_MANCHA, FLAG_LIMITROFE, CREATED_AT, UPDATED_AT,INVOKE_CONTEXT, DT_INI_VIGENCIA, DT_FIM_VIGENCIA, DT_FOTO)
        SELECT DISTINCT UP.* EXCEPT (rk),CURRENT_DATE() AS DT_INI_VIGENCIA,PARSE_DATE("%Y-%m-%d","2100-12-31") AS DT_FIM_VIGENCIA, CURRENT_DATE() AS DT_FOTO 
        FROM TABLE_DATA_UPDATED AS UP
        WHERE rk = 1;

    EXCEPTION WHEN ERROR THEN
        SELECT
            @@error.message,
            @@error.stack_trace,
            @@error.statement_text,
            @@error.formatted_stack_trace;

    END;

    BEGIN

        -- INSERE OS DADOS QUE FORAM ATUALIZADOS E POSSUEM REGISTROS COM MESMO UNIQUE_ID
        INSERT INTO `gold_zone.tb_eng_hp` (UNIQUE_ID, SURVEY_ID, EXTERNAL_ID, EQUIPMENT_ID, NOME_SURVEY, TIPO, CODIGO_IBGE, CEP, UF, MUNICIPIO, LOCALIDADE, CNL, SURVEY_ENDERECO, BAIRRO, LOGRADOURO_TIPO, LOGRADOURO_TITULO, LOGRADOURO_NOME, LOGRADOURO_NUMERO, COMPLEMENTO_01, ARGUMENTO_01, COMPLEMENTO_02, ARGUMENTO_02, COMPLEMENTO_03, ARGUMENTO_03, LATITUDE, LONGITUDE, CLASSIFICACAO_RESIDENCIAL, CLASSIFICACAO_NEGOCIO, TOTAL_UCS, UC_RESIDENCIAL, UC_COMERCIAL, UC_INDUSTRIAL, UC_ESCRITORIO, PISOS, ESTADO, FRACOES_DEFINIDAS, TOTAL_FRACOES, FLAG_MANCHA, FLAG_LIMITROFE, CREATED_AT, UPDATED_AT,INVOKE_CONTEXT, DT_INI_VIGENCIA, DT_FIM_VIGENCIA, DT_FOTO)
        SELECT DISTINCT UP.* EXCEPT (rk),CURRENT_DATE() AS DT_INI_VIGENCIA,CURRENT_DATE() AS DT_FIM_VIGENCIA, CURRENT_DATE() AS DT_FOTO 
        FROM TABLE_DATA_UPDATED AS UP
        WHERE rk > 1;

    EXCEPTION WHEN ERROR THEN
        SELECT
            @@error.message,
            @@error.stack_trace,
            @@error.statement_text,
            @@error.formatted_stack_trace;

    END;

    -- DADOS QUE SERAM ATUALIZADOS VERIFICANDO SE ESTÃO CONTIDOS NO CONJUNTO POLIGONAL DA MANCHA
    CREATE TEMP TABLE TABLE_DATA_WITH_FLAG_MANCHA AS 
        SELECT
            TDN.UNIQUE_ID,                          
            TDN.SURVEY_ID,            
            TDN.EXTERNAL_ID,
            TDN.EQUIPMENT_ID,                        
            TDN.NOME_SURVEY,                
            TDN.TIPO,                      
            TDN.CODIGO_IBGE,
            TDN.CEP,
            TDN.UF,
            TDN.MUNICIPIO,
            TDN.LOCALIDADE,
            TDN.CNL,
            TDN.SURVEY_ENDERECO,
            TDN.BAIRRO,
            TDN.LOGRADOURO_TIPO,
            TDN.LOGRADOURO_TITULO,
            TDN.LOGRADOURO_NOME,
            TDN.LOGRADOURO_NUMERO,
            TDN.COMPLEMENTO_01,
            TDN.ARGUMENTO_01,
            TDN.COMPLEMENTO_02,
            TDN.ARGUMENTO_02,
            TDN.COMPLEMENTO_03,
            TDN.ARGUMENTO_03, 
            TDN.LATITUDE,              
            TDN.LONGITUDE,            
            TDN.CLASSIFICACAO_RESIDENCIAL,
            TDN.CLASSIFICACAO_NEGOCIO,
            TDN.TOTAL_UCS,      
            TDN.UC_RESIDENCIAL,
            TDN.UC_COMERCIAL,
            TDN.UC_INDUSTRIAL,
            TDN.UC_ESCRITORIO,
            TDN.PISOS,              
            TDN.ESTADO, 
            TDN.FRACOES_DEFINIDAS,
            TDN.TOTAL_FRACOES,
            CASE
                WHEN ST_CONTAINS((mancha.geometry), ST_GEOGPOINT( CAST(TDN.LONGITUDE AS FLOAT64), CAST(TDN.LATITUDE AS FLOAT64))) = true
                THEN 1
                ELSE 0
            END AS FLAG_MANCHA,
            TDN.FLAG_LIMITROFE,
            TDN.CREATED_AT,
            TDN.UPDATED_AT,
            UPPER(TDN.INVOKE_CONTEXT) AS INVOKE_CONTEXT
        FROM `gold_zone.tb_eng_hp` AS TDN
        LEFT JOIN `silver_zone.manual_eng_mancha_cobertura_fibrasil` AS mancha
            ON REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE(LOWER(TRIM(concat(TDN.MUNICIPIO))), "[àáâãäå]", "a"), "[éèëê]", "e"), "[íìï]", "i" ), "[óòôõö]", "o" ), "[úùûü]", "u" ), "ç", "c" ), " ", "" ), "[-_@ ]", "" ) = REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE(LOWER(TRIM(concat(mancha.Name))), "[àáâãäå]", "a"), "[éèëê]", "e"), "[íìï]", "i" ), "[óòôõö]", "o" ), "[úùûü]", "u" ), "ç", "c" ), " ", "" ), "[-_@ ]", "" ) 
            AND UPPER(TDN.UF) = regexp_replace(UPPER(mancha.UF)," ","");

    -- BLOCO QUE REALIZA A TRATATIVA DOS DADOS CONTIDOS E NÃO CONTIDOS NO CONJUNTO POLIGONAL DA MANCHA
    BEGIN
        -- ATUALIZA A FLAG_MANCHA DA MANCHA SE PERTENCE OU NÃO A MANCHA
        UPDATE `gold_zone.tb_eng_hp` AS HP
        SET
            HP.FLAG_MANCHA = TDWF.FLAG_MANCHA
        FROM TABLE_DATA_WITH_FLAG_MANCHA AS TDWF
        WHERE HP.UNIQUE_ID = TDWF.UNIQUE_ID 
            AND (HP.SURVEY_ID = TDWF.SURVEY_ID OR TDWF.SURVEY_ID IS NULL) 
            AND REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE(LOWER(TRIM(concat(HP.MUNICIPIO))), "[àáâãäå]", "a"), "[éèëê]", "e"), "[íìï]", "i" ), "[óòôõö]", "o" ), "[úùûü]", "u" ), "ç", "c" ), " ", "" ), "[-_@ ]", "" )  = REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE(LOWER(TRIM(concat(TDWF.MUNICIPIO))), "[àáâãäå]", "a"), "[éèëê]", "e"), "[íìï]", "i" ), "[óòôõö]", "o" ), "[úùûü]", "u" ), "ç", "c" ), " ", "" ), "[-_@ ]", "" )   
            AND (HP.EXTERNAL_ID  = TDWF.EXTERNAL_ID OR TDWF.EXTERNAL_ID IS NULL) 
            AND (HP.EQUIPMENT_ID = TDWF.EQUIPMENT_ID OR TDWF.EQUIPMENT_ID IS NULL)
            AND HP.UPDATED_AT = TDWF.UPDATED_AT;
    
    EXCEPTION WHEN ERROR THEN
        SELECT
            @@error.message,
            @@error.stack_trace,
            @@error.statement_text,
            @@error.formatted_stack_trace;
    END;


    -- DADOS QUE SERAM ATUALIZADOS VERIFICANDO A FLAG_LIMITROFE COM A CONDIÇÃO DE ESTAREM FORA DA MANCHA
    CREATE TEMP TABLE TABLE_DATA_WITH_FLAG_LIMITROFE AS 
        SELECT
            TDN.UNIQUE_ID,                          
            TDN.SURVEY_ID,            
            TDN.EXTERNAL_ID,
            TDN.EQUIPMENT_ID,                        
            TDN.NOME_SURVEY,                
            TDN.TIPO,                      
            TDN.CODIGO_IBGE,
            TDN.CEP,
            TDN.UF,
            TDN.MUNICIPIO,
            TDN.LOCALIDADE,
            TDN.CNL,
            TDN.SURVEY_ENDERECO,
            TDN.BAIRRO,
            TDN.LOGRADOURO_TIPO,
            TDN.LOGRADOURO_TITULO,
            TDN.LOGRADOURO_NOME,
            TDN.LOGRADOURO_NUMERO,
            TDN.COMPLEMENTO_01,
            TDN.ARGUMENTO_01,
            TDN.COMPLEMENTO_02,
            TDN.ARGUMENTO_02,
            TDN.COMPLEMENTO_03,
            TDN.ARGUMENTO_03, 
            TDN.LATITUDE,              
            TDN.LONGITUDE,            
            TDN.CLASSIFICACAO_RESIDENCIAL,
            TDN.CLASSIFICACAO_NEGOCIO,
            TDN.TOTAL_UCS,      
            TDN.UC_RESIDENCIAL,
            TDN.UC_COMERCIAL,
            TDN.UC_INDUSTRIAL,
            TDN.UC_ESCRITORIO,
            TDN.PISOS,              
            TDN.ESTADO, 
            TDN.FRACOES_DEFINIDAS,
            TDN.TOTAL_FRACOES,
            TDN.FLAG_MANCHA,
            CASE
                WHEN 
                    (CTO_CAT_OPE.NAME = 'ENABLED' 
                    AND CTO_CAT_USA.NAME = 'INSTALLED' 
                    AND TDN.SURVEY_ID IS NOT NULL 
                    AND TDN.EQUIPMENT_ID IS NOT NULL
                    AND TDN.MUNICIPIO IS NOT NULL
                    AND TDN.FLAG_MANCHA = 0) 
                THEN 1
                ELSE 0
            END AS FLAG_LIMITROFE,
            TDN.CREATED_AT,
            TDN.UPDATED_AT,
            UPPER(TDN.INVOKE_CONTEXT) AS INVOKE_CONTEXT
        FROM `gold_zone.tb_eng_hp` AS TDN
        LEFT JOIN `silver_zone.manual_eng_mancha_cobertura_fibrasil` AS mancha
            ON REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE(LOWER(TRIM(concat(TDN.MUNICIPIO))), "[àáâãäå]", "a"), "[éèëê]", "e"), "[íìï]", "i" ), "[óòôõö]", "o" ), "[úùûü]", "u" ), "ç", "c" ), " ", "" ), "[-_@ ]", "" ) = REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE(LOWER(TRIM(concat(mancha.Name))), "[àáâãäå]", "a"), "[éèëê]", "e"), "[íìï]", "i" ), "[óòôõö]", "o" ), "[úùûü]", "u" ), "ç", "c" ), " ", "" ), "[-_@ ]", "" ) 
            AND UPPER(TDN.UF) = regexp_replace(UPPER(mancha.UF)," ","")
        LEFT JOIN `silver_zone.netwin_osp_equipment`            AS PDO
            ON PDO.ID = TDN.EQUIPMENT_ID
        LEFT JOIN `silver_zone.netwin_ns_res_ins_node_mirror_sbd` as NM
            ON PDO.ID = NM.ID_OSP
            AND NM.ENTITY_ISP = 'AC_GEN_INS_EQUIPAMENTO'
        LEFT JOIN `silver_zone.netwin_isp_ins_equipamento_sbd` as IEQ
            ON IEQ.ID_BD_EQUIPAMENTO = NM.ID_ISP
        LEFT JOIN `silver_zone.netwin_cat_state`                       AS CTO_CAT_OPE  
            ON CTO_CAT_OPE.ID = IEQ.OPERATIONAL_STATE_ID
        LEFT JOIN `silver_zone.netwin_cat_state`                       AS CTO_CAT_USA  
            ON CTO_CAT_USA.ID = IEQ.USAGE_STATE_ID;

    -- BLOCO QUE REALIZA A TRATATIVA DOS DADOS CONTIDOS E NÃO CONTIDOS NO CONJUNTO POLIGONAL DA MANCHA
    BEGIN
        -- ATUALIZA A FLAG_MANCHA DA MANCHA SE PERTENCE OU NÃO A MANCHA
        UPDATE `gold_zone.tb_eng_hp` AS HP
        SET
            HP.FLAG_LIMITROFE = TDWF.FLAG_LIMITROFE
        FROM TABLE_DATA_WITH_FLAG_LIMITROFE AS TDWF
        WHERE HP.UNIQUE_ID = TDWF.UNIQUE_ID 
            AND (HP.SURVEY_ID = TDWF.SURVEY_ID OR TDWF.SURVEY_ID IS NULL) 
            AND REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE(LOWER(TRIM(concat(HP.MUNICIPIO))), "[àáâãäå]", "a"), "[éèëê]", "e"), "[íìï]", "i" ), "[óòôõö]", "o" ), "[úùûü]", "u" ), "ç", "c" ), " ", "" ), "[-_@ ]", "" )  = REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE( REGEXP_REPLACE(LOWER(TRIM(concat(TDWF.MUNICIPIO))), "[àáâãäå]", "a"), "[éèëê]", "e"), "[íìï]", "i" ), "[óòôõö]", "o" ), "[úùûü]", "u" ), "ç", "c" ), " ", "" ), "[-_@ ]", "" )   
            AND (HP.EXTERNAL_ID  = TDWF.EXTERNAL_ID OR TDWF.EXTERNAL_ID IS NULL) 
            AND (HP.EQUIPMENT_ID = TDWF.EQUIPMENT_ID OR TDWF.EQUIPMENT_ID IS NULL)
            AND HP.UPDATED_AT = TDWF.UPDATED_AT;
    
    EXCEPTION WHEN ERROR THEN
        SELECT
            @@error.message,
            @@error.stack_trace,
            @@error.statement_text,
            @@error.formatted_stack_trace;
    END;

    BEGIN 
        INSERT INTO `gold_zone.tb_eng_hp_total` (
            UF,
            Municipio,
            HP,
            HP_TOTAL,
            HP_COMERCIALIZAVEL,
            HP_COM_LIMITROFE,
            HP_MS,
            DT_FOTO
        )
        SELECT
            hpt.UF,
            hpt.Municipio,
            SUM(hpt.HP) AS HP,
            SUM(hpt.HP_TOTAL) AS HP_TOTAL,
            SUM(hpc.HP_COMERCIALIZAVEL) AS HP_COMERCIALIZAVEL,
            SUM(hpc.HP_TOTAL_LIMITROFE) AS HP_TOTAL_LIMITROFE,
            SUM(hpc.HP_MS) AS HP_MS,
            CURRENT_DATE() AS DT_FOTO
        FROM `delivery_zone.vw_hp_total` as hpt
        LEFT JOIN `delivery_zone.vw_hp_comercializavel` as hpc
            ON hpt.UNIQUE_ID = hpc.UNIQUE_ID
            AND hpt.SURVEY_ID = hpc.SURVEY_ID
        GROUP BY
            hpt.UF,
            hpt.Municipio
        ORDER BY
            hpt.UF,
            hpt.Municipio;
        
    EXCEPTION WHEN ERROR THEN 
        SELECT
        @@error.message,
        @@error.stack_trace,
        @@error.statement_text,
        @@error.formatted_stack_trace;
    END;

END;