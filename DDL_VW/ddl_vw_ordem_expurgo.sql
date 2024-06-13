CREATE OR REPLACE VIEW `delivery_zone.vw_ordem_expurgo` (
    ID_Access          OPTIONS(description="Identificador único dos clientes. Ex: “MUN-202345154449”, “20014“, “5”, etc."),
    Tenant             OPTIONS(description="O nome do tenant. Ex: SKY, WSP, etc.")
)
OPTIONS(
    description="Descrição do ativo de dado: uma visão que representa todo as ordens consideradas de expurgo; \nDomínio de dado: Eficiência operacional - eop; \nClassificação da informação: uso corporativo; \nGrupos de acesso: GCP_DL_PRD_BR_Data_Analytics_eop_Corporativo_Delivery; \nPeríodo de retenção: a definir; \nRelação com indicadores no glossário de negócio: já documentado; \nRelação com termos do glossário de negócio: já documentado; \nDatatype validado pela curadoria: a validar; \nCampos “Null” validado pelo curador: a validar;",
    labels=[("eficiencia_operacional", "eop")]
)AS SELECT
    `access` as ID_Access,
    tenant as Tenant
 FROM silver_zone.manual_eop_tb_expurgos