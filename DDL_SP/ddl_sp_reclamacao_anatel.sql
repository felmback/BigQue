CREATE OR REPLACE PROCEDURE `fibrasil-datalake-dev.gold_zone.sp_anatel_reclamacao`()
BEGIN
 BEGIN
    DECLARE VAR_DT_PERIDO DEFAULT CURRENT_DATE();
    BEGIN
      SET VAR_DT_PERIDO = IFNULL((SELECT MAX(DATE(PERIODO)) FROM `fibrasil-datalake-dev.gold_zone.tb_reclamacoes_banda_larga_fixa`),'1900-01-01');
      SELECT VAR_DT_PERIDO;

    END;

      CREATE TABLE IF NOT EXISTS `fibrasil-datalake-dev.gold_zone.tb_reclamacoes_banda_larga_fixa`
      (
        PERIODO             DATE OPTIONS(description="Ano,Mês em que foi registrado a solicitações de reclamação do Orgão Ex: 2024-04-01"),
        COD_MUNICIPIO       INT64 OPTIONS(description="ID de identificação atribuído pelo IBGE.Município onde foi registrado a acesso ao serviço Ex: 3509502,3550605"),
        UF                  STRING OPTIONS(description="Sigla Estado onde foi registrado a solicitação. Ex: SP,RJ"),
        CIDADE              STRING OPTIONS(description="Cidade onde foi registrado a solicitação. Ex: Campinas,Rio de Janeiro"),
        CANAL_ENTRADA       STRING OPTIONS(description="Canal no qual foi registrado a solicitação Ex: Usuario WEB,Mobile App"),
        CONDICAO            STRING OPTIONS(description="Status da solicitação Ex: Nova,Reaberta"),
        TIPO_ATENDIMENTO    STRING OPTIONS(description="Tipo de atendimento feito na solictação Ex: Reclamação"),
        SERVICO             STRING OPTIONS(description="Serviço utilizado que ocorreu a solicitação Ex: SCM(banda larga)"),
        CNPJ                STRING OPTIONS(description="CNPJ da Operadora Ex: 66970229000167,02558157000162"),
        OPERADORAS          STRING OPTIONS(description="Prestadorta de serviço Ex: Vivo,Claro"),
        ASSUNTO             STRING OPTIONS(description="Assunto relatado no momento da solicitação Ex: Cobranca,Qualidade"),
        PROBLEMA            STRING OPTIONS(description="Problema relatado no momento da solicitação Ex: Reparo,Lentidão"),
        SOLICITACOES        INT64 OPTIONS(description="Contagem dos registros feitos Ex: 1 ,2 etc."),
        DT_FOTO             DATE OPTIONS(description="Data da Atualização das informações")
      )
      OPTIONS(
        description="Tabela que armazena informações de solictações(reclamação) na Anatel.",
        labels=[("tb_reclamacoes_banda_larga_fixa", "eop")]
      );

    INSERT INTO `fibrasil-datalake-dev.gold_zone.tb_reclamacoes_banda_larga_fixa`
    (
      PERIODO,
      COD_MUNICIPIO,
      UF,
      CIDADE,
      CANAL_ENTRADA,
      CONDICAO,
      TIPO_ATENDIMENTO,
      SERVICO,
      CNPJ,
      OPERADORAS,
      ASSUNTO,
      PROBLEMA,
      SOLICITACOES,
      DT_FOTO    
    )
    SELECT
      DATE(CONCAT(rec.ANO_MES,'-','01')) AS  PERIODO,
      CASE WHEN SAFE_CAST (rec.COD_MUNICIPIO AS INT64 ) IS NULL THEN -1
          ELSE CAST(rec.COD_MUNICIPIO AS INT64)
          END  AS COD_MUNICIPIO,
      rec.UF,
      rec.CIDADE,
      rec.CANAL_ENTRADA,
      rec.CONDICAO,
      rec.TIPO_ATENDIMENTO,
      rec.SERVICO,
      de_para.cnpj AS CNPJ,
      rec.OPERADORAS,
      rec.ASSUNTO,
      rec.PROBLEMA,
      CAST(rec.SOLICITACOES AS INT64) AS SOLICITACOES,
      DATE(CURRENT_DATE()) AS DT_FOTO
    FROM `fibrasil-datalake-dev.silver_zone.anatel_dados_abertos_consumidor_reclamacoes` rec
    LEFT JOIN `fibrasil-datalake-dev.gold_zone.anatel_de_para_operadoras` de_para ON de_para.de_operadoras = rec.OPERADORAS
    WHERE DATE(CONCAT(rec.ANO_MES,'-','01')) > VAR_DT_PERIDO
    ORDER BY rec.COD_MUNICIPIO DESC
    ;
    EXCEPTION WHEN ERROR THEN 
        SELECT
          @@error.message,
          @@error.stack_trace,
          @@error.statement_text,
          @@error.formatted_stack_trace;
  END;
  BEGIN
      
        INSERT INTO `fibrasil-datalake-dev.gold_zone.tb_ctrl_volumetria`
        (
            TABELA,
            CHAVE,
            INDICADOR,
            VOLUME_DISTINTO,
            VOLUME_TOTAL,
            MAX_DATA_DADOS,
            DT_FOTO
        )
        
        SELECT
            'gold_zone_tb_acessos_banda_larga_fixa' AS TABELA,
            'CNPJ' as CHAVE,
            'RECLAMACAO_BANDA_LARGA' AS INDICADOR,
            COUNT(DISTINCT CNPJ) AS VOLUME_DISTINTO,
            SUM(SOLICITACOES) AS VOLUME_TOTAL,
            CAST(MAX(PERIODO) AS STRING) AS MAX_DATA_DADOS,
            FORMAT_TIMESTAMP("%Y-%m-%d %H:%M", TIMESTAMP_ADD(CURRENT_DATETIME(), INTERVAL -3 HOUR)) AS DT_FOTO
      FROM `fibrasil-datalake-dev.gold_zone.tb_reclamacoes_banda_larga_fixa` 
      WHERE PERIODO = (SELECT MAX(PERIODO) FROM `fibrasil-datalake-dev.gold_zone.tb_reclamacoes_banda_larga_fixa` );

      EXCEPTION WHEN ERROR THEN 
          SELECT
            @@error.message,
            @@error.stack_trace,
            @@error.statement_text,
            @@error.formatted_stack_trace;
      END;
END;

