
CREATE OR REPLACE VIEW `delivery_zone.vw_viabilidade_cto` 
(
  EQUIPMENT_ID          OPTIONS(description="Identificador do equipamento (CTO)."),
  CTO_NAME              OPTIONS(description="Nome do Equimamento"),
  STATUS_CTO            OPTIONS(description="Indica se o equipamento está com viabilidade(AVAILABLE) ou sem viabilidade(NOT-AVAILABLE) "),
  REASON_CODE           OPTIONS(description="Indica o código de erro para o status  = NOT-AVAILABLE "),
  REASON                OPTIONS(description="Descrição do código de erro (REASON_CODE) "),
  ESTADO_OPERACIONAL    OPTIONS(description="Indica qual o estado operacional do equipamento(Serviço/Fora de Serviço)"),
  CICLO_DE_VIDA         OPTIONS(description="Indica o estado físico do equipamento(Instalado/Desistalado)"),
  TIPO                  OPTIONS(description="Indica o tipo  do equipamento instalado (SDU>> RESIDENCIAL MDU >> PREDIAL)"),
  MODELO                OPTIONS(description="Indica o modelo da CTO"),
  FABRICANTE            OPTIONS(description="Indica o fabricante da CTO"),
  ARMARIO               OPTIONS(description="Central Abastecedora / Armário "),
  CEP                   OPTIONS(description="Identificador do código postal do endereço (CEP) "),
  ENDERECO              OPTIONS(description="Endereço do"),
  MUNICIPIO             OPTIONS(description="Descrição do endereço do equipamento"),
  LOCALIDADE            OPTIONS(description="Descrição do endereço do equipamento"),
  UF                    OPTIONS(description="Descrição da localidade do equipamento"),
  LATITUDE              OPTIONS(description="Latitude do equipamento"),
  LONGITUDE             OPTIONS(description="Logitudedo equipamento"),
  CAPACIDADE            OPTIONS(description="Identificador do número total de portas do equipamento"),
  PORTAS_LIVRES         OPTIONS(description="Identificador do número total de portas livres do equipamento"),
  PORTAS_OCUPADAS       OPTIONS(description="Identificador do número total de portas reservadas do equipamento"),
  PORTAS_RESERVADAS     OPTIONS(description="Identificador do número total de portas ocupadas do equipamento"),
  PORTAS_CATIVAS        OPTIONS(description="Identificador do número total de portas cativas do equipamento"),
  DT_FOTO               OPTIONS(description="Identificador da data em que o dados foram atualizados")
)
OPTIONS( friendly_name="vw_viabilidade_cto", description="", labels=[("eng", "engenharia")] ) 
AS ( 
SELECT 
EQUIPMENT_ID,
CTO_NAME,
STATUS_CTO,
REASON_CODE,
REASON,
ESTADO_OPERACIONAL,
CICLO_DE_VIDA,
TIPO,
MODELO,
FABRICANTE,
ARMARIO,
CEP,
ENDERECO,
MUNICIPIO,
LOCALIDADE,
UF,
LATITUDE,
LONGITUDE,
CAPACIDADE,
PORTAS_LIVRES,
PORTAS_OCUPADAS,
PORTAS_RESERVADAS,
PORTAS_CATIVAS,
DT_FOTO
FROM `gold_zone.tb_viabilidade_cto`
)