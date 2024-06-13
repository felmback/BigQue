CREATE OR REPLACE VIEW `delivery_zone.vw_ordem_fase` (
    ID_Access          OPTIONS(description="Código identificador único do cliente."),
    ID_Reserva         OPTIONS(description="Número identificador único referente a reserva. OBS (views relacionadas: campo 'ID' da vw_reserve, utilizado para obter o ID_address da view vw_address, a qual será cruzada com vw_base_address para obter as informações do endereço)."),
    ID_Correlation     OPTIONS(description="Identificador da Correlação"),
    ID_Endereco        OPTIONS(description="Número identificador único referente a rua e o número da residência. OBS (views relacionadas: campo ID da vw_address, utlizado em casos de informações mais detalhadas sobre o endereço,exemplo:nome da rua, número da casa, etc.)"),
    ID_Endereco_Base   OPTIONS(description="Número identificador único referente a rua. OBS (views relacionadas: campo 'ID' da vw_base_address, utilizado em casos de informações mais macro do endereço, exemplo: cidade, UF, CNL, etc.)"),
    ID_Localidade      OPTIONS(description="Número identificador único da localidade. Ex: 85135039, etc."),
    IN_Estado_Ordem    OPTIONS(description="Status da ordem, Valor padrão: 'Completed'"),
    IN_TENANT          OPTIONS(description="Tenant, Ex: VIVO, SKY"),
    TP_Ordem           OPTIONS(description="Status da Ordem. Ex: Desemparelhamento, Ativação, etc."),
    Ordem_Origem       OPTIONS(description="Canal de entrada da ordem API/POTAL"),
    TS_Inicio_Ordem    OPTIONS(description="Data e hora de início da fase da ordem. Ex: 2009-12-01 13:02:01 UTC"),
    TS_Fim_Ordem       OPTIONS(description="Data e hora da fase da ordem. Ex: 2009-12-01 13:02:01 UTC"),
    TS_Ult_Atualizacao OPTIONS(description="Data e hora da última atualização da fase da ordem. Ex: 2009-12-01 13:02:01 UTC"),
    DT_FOTO            OPTIONS(description="Data de foto da ordem.")
)
OPTIONS(
    description="Uma visão que representa as ordens e suas fases. \nDomínio de Dado: Eficiência Operacional - eop \nPeríodo de retenção: a definir \nClassificação da Informação: a definir \nGrupo de Acesso:",
    labels=[("eficiencia_operacional", "eop")]
)AS SELECT DISTINCT
    fase.*
FROM `gold_zone.tb_eop_ordem_fase` fase
 WHERE IN_Estado_Ordem = "COMPLETED" 
ORDER BY id_access