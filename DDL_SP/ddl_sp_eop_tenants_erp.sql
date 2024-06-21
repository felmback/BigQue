CREATE OR REPLACE PROCEDURE `fibrasil-datalake-dev.gold_zone.sp_eop_tenants_erp`()
BEGIN
  DECLARE VAR_DT_PARTITION DEFAULT CURRENT_DATE();
  SET VAR_DT_PARTITION = IFNULL((SELECT MAX(DATE(DT_PARTITION)) FROM `fibrasil-datalake-dev.gold_zone.tb_eop_tenants_erp`),'1900-01-01');

  CREATE TABLE IF NOT EXISTS  `fibrasil-datalake-dev.gold_zone.tb_eop_tenants_erp` 
  (
      CNPJ                            STRING OPTIONS(description="CNPJ do Tenant Ex: 12.823.984/0001-90"),
      COD_CADASTRO                    STRING OPTIONS(description="Código de cadastro do Tenant para acionamento do BKO Ex:9029."),
      TENANT                          STRING OPTIONS(description="Nome do Tenant. WSP, LOOP, etc."),
      PLANO_ESCOLHIDO                 STRING OPTIONS(description="É o plano de velocidade do HC. Ex: BASICO"),
      SISTEMA                         STRING OPTIONS(description="Sistema utilizado pelo Tenant Ex: ERP ou Portal."),
      DATA_INICIO                     DATE OPTIONS(description="Data do lançamento Comercial.Ex: 2023-09-01, 2023-10-01, etc."),
      DATA_ASSINATURA_CONTRATO        DATE OPTIONS(description="Data da assinatura do contrato com a Fibrasil.Ex: 2023-09-01, 2023-10-01, etc."),
      DATA_POS_VENDAS                 DATE OPTIONS(description="Data de passagem para o time Comercial.Ex: 2023-09-01, 2023-10-01, etc."),
      RESPONSAVEL_IMPLANTACAO         STRING OPTIONS(description="Time responsável pela implantação do tenant na Fibrasil Ex: DIEGO."),
      GESTAO_ATUAL                    STRING OPTIONS(description="Gestão atual do cliente EX: Implantação ou Pós Vendas Ex: Pós Vendas."),
      CPE                             STRING OPTIONS(description="Fabricante/Equipamento utilizado pelos Tenants EX: INTELBRAS (121AC) | ZTE (ZXHN_F670L_V9)."),
      TAKEUP                          STRING OPTIONS(description="Cliente possui Takeup Ex; sim/nao."),
      SETUP                           STRING OPTIONS(description="Cliente possui Setup Ex: Não."),
      FLAG_HABILITADO                 STRING OPTIONS(description="Status do Cliente Ex: 1 Cliente ativo ,= Cliente Suspenso."),
      CONSULTOR_VENDAS                STRING OPTIONS(description="Consultor de vendas responsável pela Tenant Ex: MAX."),
      DT_PARTITION                    DATE OPTIONS(description=".."),
      DT_FOTO                         DATE OPTIONS(description="Data em que houve a atualização das informações")  
  )
  OPTIONS(
    description="Tabela com as informações de cada tenant do EOP.",
    labels=[("eop", "tb_eop_tenants_erp")] 
  );

  INSERT INTO `fibrasil-datalake-dev.gold_zone.tb_eop_tenants_erp`
  (
    CNPJ,
    COD_CADASTRO,
    TENANT,
    PLANO_ESCOLHIDO,
    SISTEMA,
    DATA_INICIO,
    DATA_ASSINATURA_CONTRATO,
    DATA_POS_VENDAS,
    RESPONSAVEL_IMPLANTACAO,
    GESTAO_ATUAL,
    CPE,
    TAKEUP,
    SETUP,
    FLAG_HABILITADO,
    CONSULTOR_VENDAS,
    DT_PARTITION,
    DT_FOTO 
  )

  SELECT 
    CNPJ,
    COD_CADASTRO,
    TENANT,
    PLANO_ESCOLHIDO,
    SISTEMA,
    DATE(DATA_INICIO) AS DATA_INICIO,
    DATE(DATA_ASSINATURA_CONTRATO) AS DATA_ASSINATURA_CONTRATO,
    DATE(DATA_POS_VENDAS) AS DATA_POS_VENDAS,
    RESPONSAVEL_IMPLANTACAO,
    GESTAO_ATUAL,
    CPE,
    TAKEUP,
    SETUP,
    FLAG_HABILITADO,
    CONSULTOR_VENDAS,
    DATE(DT_PARTITION) AS DT_PARTITION,
  CURRENT_DATE() AS DT_FOTO
  FROM `fibrasil-datalake-dev.silver_zone.manual_eop_de_para_tenants_erp` 
  WHERE DATE(DT_PARTITION) >=VAR_DT_PARTITION
  ;
    EXCEPTION WHEN ERROR THEN 
        SELECT
          @@error.message,
          @@error.stack_trace,
          @@error.statement_text,
          @@error.formatted_stack_trace;

END;