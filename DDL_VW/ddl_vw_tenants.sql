


CREATE OR REPLACE VIEW `fibrasil-datalake-dev.delivery_zone.vw_tenants`
(
  `HASH`                                OPTIONS(description="Não informado"),
  CNPJ                                  OPTIONS(description="CNPJ do Tenant Ex: 12.823.984/0001-90"),      
  CLIENTE                               OPTIONS(description="Nome do Tenant. WSP, LOOP, etc."),
  PLANO_ESCOLHIDO                       OPTIONS(description="É o plano de velocidade do HC. Ex: BASICO"),
  CODIGO_IBGE                           OPTIONS(description="Código da cidade no IBGE. Ex: 2304202, 2503209, etc."),
  UF                                    OPTIONS(description="Unidade da federação. Ex: RS, SC, etc"),
  CIDADE                                OPTIONS(description="Nome da cidade. Ex: TERESINA, JUAZEIRO DO NORTE, etc."),
  COD_CADASTRO                          OPTIONS(description="Código de cadastro do Tenant para acionamento do BKO Ex:9029."),
  SISTEMA                               OPTIONS(description="Sistema utilizado pelo Tenant Ex: ERP ou Portal."),
  CONSULTOR_VENDAS                      OPTIONS(description="Consultor de vendas responsável pela Tenant Ex: MAX."),
  RESPONSAVEL_IMPLANTACAO               OPTIONS(description="Time responsável pela implantação do tenant na Fibrasil Ex: DIEGO."),
  GESTAO_ATUAL                          OPTIONS(description="Gestão atual do cliente EX: Implantação ou Pós Vendas Ex: Pós Vendas."),
  CPE                                   OPTIONS(description="Fabricante/Equipamento utilizado pelos Tenants EX: INTELBRAS (121AC) | ZTE (ZXHN_F670L_V9)."),
  FLAG_HABILITADO                       OPTIONS(description="Status do Cliente Ex: 1 Cliente ativo ,= Cliente Suspenso."),
  SETUP                                 OPTIONS(description="Cliente possui Setup Ex: Não."),
  TAKEUP                                OPTIONS(description="Cliente possui Takeup Ex; sim/nao."),
  DT_INICIO_RFI                         OPTIONS(description="Data de início da ocupação. Ex: 2023-09-01, 2023-10-01, etc."),
  DATA_INICIO                           OPTIONS(description="Data do lançamento Comercial.Ex: 2023-09-01, 2023-10-01, etc."),                              
  DATA_POS_VENDAS                       OPTIONS(description="Data de passagem para o time Comercial.Ex: 2023-09-01, 2023-10-01, etc."),
  DATA_ASSINATURA_CONTRATO              OPTIONS(description="Data da assinatura do contrato com a Fibrasil.Ex: 2023-09-01, 2023-10-01, etc."),
  DT_FOTO                               OPTIONS(description="Data em que houve a atualização das informações") 
)
OPTIONS(
  friendly_name="vw_tenants",
  description="Descrição do ativo de dado: Uma visão que representa a dimensão cidade tenant do protheus billing;\nDomínio de dado: Financeiro - fin;\nClassificação da informação: uso corporativo;\nGrupos de acesso: GCP_DL_PRD_BR_Data_Analytics_fin_Corporativo_Delivery;\nPeríodo de retenção: a definir;\nRelação com indicadores no glossário de negócio: já documentado;\nRelação com termos do glossário de negócio: já documentado;\nDatatype validado pela curadoria: a validar;\nCampos “Null” validado pelo curador: a validar;",
  labels=[("eop", "vw_tenants")]
)
AS (
  SELECT
  DISTINCT
  dimcid.HASH,
  de_para.CNPJ,
  dimcid.CLIENTE,
  dimcid.PLANO_ESCOLHIDO,
  dimcid.CODIGO_IBGE,
  dimcid.UF,
  dimcid.CIDADE,
  de_para.COD_CADASTRO,
  de_para.SISTEMA,
  de_para.CONSULTOR_VENDAS,
  de_para.RESPONSAVEL_IMPLANTACAO,
  de_para.GESTAO_ATUAL,
  de_para.CPE,
  de_para.FLAG_HABILITADO,
  de_para.SETUP,
  de_para.TAKEUP,
  dimcid.DT_INICIO_RFI,
  de_para.DATA_INICIO,
  de_para.DATA_POS_VENDAS,
  de_para.DATA_ASSINATURA_CONTRATO,
  dimcid.DT_FOTO
  FROM `fibrasil-datalake-dev.delivery_zone.vw_dimensao_cidade_tenant` dimcid
  LEFT JOIN `fibrasil-datalake-dev.delivery_zone.vw_de_para_tenants_erp` de_para on de_para.TENANT = dimcid.CLIENTE
)