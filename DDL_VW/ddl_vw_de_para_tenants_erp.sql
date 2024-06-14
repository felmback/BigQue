CREATE OR REPLACE VIEW `fibrasil-datalake-dev.delivery_zone.vw_de_para_tenants_erp` 
(
    CNPJ                            OPTIONS(description="CNPJ do Tenant Ex: 12.823.984/0001-90"),
    COD_CADASTRO                    OPTIONS(description="Código de cadastro do Tenant para acionamento do BKO Ex:9029."),
    TENANT                          OPTIONS(description="Nome do Tenant. WSP, LOOP, etc."),
    PLANO_ESCOLHIDO                 OPTIONS(description="É o plano de velocidade do HC. Ex: BASICO"),
    SISTEMA                         OPTIONS(description="Sistema utilizado pelo Tenant Ex: ERP ou Portal."),
    DATA_INICIO                     OPTIONS(description="Data do lançamento Comercial.Ex: 2023-09-01, 2023-10-01, etc."),
    DATA_ASSINATURA_CONTRATO        OPTIONS(description="Data da assinatura do contrato com a Fibrasil.Ex: 2023-09-01, 2023-10-01, etc."),
    DATA_POS_VENDAS                 OPTIONS(description="Data de passagem para o time Comercial.Ex: 2023-09-01, 2023-10-01, etc."),
    RESPONSAVEL_IMPLANTACAO         OPTIONS(description="Time responsável pela implantação do tenant na Fibrasil Ex: DIEGO."),
    GESTAO_ATUAL                    OPTIONS(description="Gestão atual do cliente EX: Implantação ou Pós Vendas Ex: Pós Vendas."),
    CPE                             OPTIONS(description="Fabricante/Equipamento utilizado pelos Tenants EX: INTELBRAS (121AC) | ZTE (ZXHN_F670L_V9)."),
    TAKEUP                          OPTIONS(description="Cliente possui Takeup Ex; sim/nao."),
    SETUP                           OPTIONS(description="Cliente possui Setup Ex: Não."),
    FLAG_HABILITADO                 OPTIONS(description="Status do Cliente Ex: 1 Cliente ativo ,= Cliente Suspenso."),
    CONSULTOR_VENDAS                OPTIONS(description="Consultor de vendas responsável pela Tenant Ex: MAX."),
    DT_FOTO                         OPTIONS(description="Data em que houve a atualização das informações")  
)
OPTIONS( description="View com as informações de cada tenant do EOP.", labels=[("eop", "vw_de_para_tenants_erp")] )
AS (
SELECT 
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
CURRENT_DATE() AS DT_FOTO
FROM `fibrasil-datalake-dev.gold_zone.tb_eop_tenants_erp`
WHERE DT_PARTITION = (SELECT MAX(a.DT_PARTITION) FROM `fibrasil-datalake-dev.gold_zone.tb_eop_tenants_erp` a)
)