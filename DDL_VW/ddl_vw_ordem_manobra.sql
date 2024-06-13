CREATE OR REPLACE VIEW `delivery_zone.vw_ordem_manobra` (
    ID_Access          OPTIONS(description="Código identificador único do cliente."),
    ID_Reserva         OPTIONS(description="Número identificador único referente a reserva. OBS (views relacionadas: campo 'ID' da vw_reserve, utilizado para obter o ID_address da view vw_address, a qual será cruzada com vw_base_address para obter as informações do endereço)."),
    SK                 OPTIONS(description="Campo concatenado: 'ID_Access' + 'ID_Reserva'."),
    ID_Endereco        OPTIONS(description="Número identificador único referente a rua e o número da residência. OBS (views relacionadas: campo ID da vw_address, utlizado em casos de informações mais detalhadas sobre o endereço,exemplo:nome da rua, número da casa, etc.)."),
    ID_Endereco_Base   OPTIONS(description="Número identificador único referente a rua. OBS (views relacionadas: campo 'ID' da vw_base_address, utilizado em casos de informações mais macro do endereço, exemplo: cidade, UF, CNL, etc.)."),
    ID_Localidade      OPTIONS(description="Número identificador único da localidade. Ex: 85135039, etc."),
    IN_Estado_Ordem    OPTIONS(description="Status da ordem, Valor padrão: 'Completed'"),
    IN_TENANT          OPTIONS(description="Tenant, Ex: VIVO, SKY"),
    TP_Ordem           OPTIONS(description="Valor padrão 'MANOBRA'."),
    TS_Inicio_Ordem    OPTIONS(description="Data e hora de início do fim do processo de manobra. Ex: 2009-12-01 13:02:01 UTC"),
    TS_Fim_Ordem       OPTIONS(description="Data e hora da última atualização do processo de manobra. Ex: 2009-12-01 13:02:01 UTC"),
    TS_Ult_Atualizacao OPTIONS(description="Data e hora da última atualização do processo de manobra. Ex: 2009-12-01 13:02:01 UTC"),
    DT_FOTO            OPTIONS(description="Data de foto da ordem da manobra. Ex: 2009-12-01 13:02:01 UTC")
)
OPTIONS(
    description="Uma visão que representa as ordens do tipo MANOBRA. \nDomínio de Dado: Eficiência Operacional - eop \nPeríodo de retenção: a definir \nClassificação da Informação: a definir",
    labels=[("eficiencia_operacional", "eop")]
)AS SELECT 
    ID_Access
    ,ID_Reserva
    ,concat(ID_Access,ID_Reserva) AS SK
    ,ID_Endereco
    ,ID_Endereco_Base
    ,ID_Localidade
    ,IN_Estado_Ordem
    ,IN_TENANT
    ,TP_Ordem
    ,TS_Inicio_Ordem
    ,TS_Fim_Ordem
    ,TS_Ult_Atualizacao
    ,DT_FOTO                                
FROM `delivery_zone.vw_ordem_fase`
WHERE TP_Ordem = 'MANOBRA'
AND IN_Estado_Ordem = 'COMPLETED'