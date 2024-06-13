CREATE OR REPLACE VIEW `delivery_zone.vw_hc_resources`(
    EXTERNAL_CODE           OPTIONS(description="Identificador do cliente, designador."),
    ID_EQUIPAMENTO          OPTIONS(description="Identificador do equipamento."),
    ID_ENDERECO             OPTIONS(description="Número identificador único referente a rua e o número da residência."),
    SK                      OPTIONS(description="Campo concatenado: 'ID_Access' +'ID_Reserva'."),
    TRILHA_EQUIPAMENTO      OPTIONS(description="End to end do equipamento no contexto ( OLT > CTO > SVLAN > CVLAN > CPE)."),
    PORTAS                  OPTIONS(description="Portas do Equipamento de Rede."),
    PORTA_CTO               OPTIONS(description="Portas da CTO."),
    OLT                     OPTIONS(description="(Optical Line Terminal) - A OLT é um componente central em redes de fibra óptica, especialmente em sistemas de PON (Passive Optical Network) . Suas principais funções incluem: Gerenciamento Óptico: Controla e gerencia a transmissão de dados na rede óptica. Conversão Óptica: Converte os sinais elétricos provenientes da rede de dados em sinais ópticos para transmissão na fibra óptica. Controle de Acesso: Fornece acesso a serviços de banda larga para usuários finais, conectando-se aos terminais ópticos dos assinantes."),
    CTO                     OPTIONS(description="Caixa de Terminação Óptica : Em uma configuração típica de PON (Passive Optical Network) , a CTO pode estar conectada à OLT e, dependendo da arquitetura específica da rede, também pode estar associada a splitters para distribuição do sinal óptico para os assinantes."),
    SVLAN                   OPTIONS(description="SVLAN (Service VLAN): Função: Separa diferentes serviços em uma rede. Uso: Permite a prestação de serviços específicos em uma rede compartilhada, mantendo a segregação entre esses serviços."),
    CVLAN                   OPTIONS(description="CVLAN (Customer VLAN): Função: Separa o tráfego de diferentes clientes em uma rede. Uso: Permite que vários clientes compartilhem a mesma infraestrutura de rede, mantendo seus dados isolados."),
    TENANT                  OPTIONS(description="Inquilino de Rede na FiBrasil."),
    CPE                     OPTIONS(description="Nome do equipamento da (CPE) - Customer Premises Equipment - Refere-se aos dispositivos de telecomunicações e equipamentos localizados nas instalações do cliente, geralmente em residências ou empresas. Esse equipamento é a interface entre a rede de serviço de telecomunicações e os dispositivos do cliente, facilitando a conectividade e o acesso aos serviços oferecidos pela operadora de telecomunicações."),   
    IN_CHAR_CPE_SN          OPTIONS(description="Número serial da CPE."),
    STATUS_CICLO_VIDA_CPE   OPTIONS(description="Ciclo de Vida, máquina de estado do CPE na rede FiBrasil."),
    STATUS_OPERACIONAL_CPE  OPTIONS(description="Estado Operacional do CPE."),
    IN_CHAR_CPE_MODEL       OPTIONS(description="Modelo da CPE."),
    TAXONOMIA_ONT           OPTIONS(description="Classificação ou categorização dos diferentes tipos de ONTs (Optical Network Terminals)."),
    IN_CHAR_CPE_VENDOR      OPTIONS(description="Fabricante da CPE."),
    DATA_CICLO_VIDA_CPE     OPTIONS(description="Data do Ciclo de Vida da CPE."),
    STATUS_PROVISAO_CPE     OPTIONS(description="Estado Provisionamento da CPE."),
    DATA_PROVISAO_CPE       OPTIONS(description="Data Provisionamento CPE."),
    ORIGEM                  OPTIONS(description="Sistema de Inventário Origem da informação."),
    DT_FOTO                 OPTIONS(description="Data da Foto do HC_Resource.")
)      
OPTIONS(
    description="View referente a tabela de recurso de HCs."
)
AS 
SELECT 
  EXTERNAL_CODE,
  ID_EQUIPAMENTO,
  ID_Endereco AS ID_ENDERECO,
  SK,
  TRILHA_EQUIPAMENTO,
  PORTAS,
  PORTA_CTO,
  OLT,
  CTO,
  SVLAN,
  CVLAN,
  TENANT,
  CPE,
  IN_CHAR_CPE_SN,
  STATUS_CICLO_VIDA_CPE,
  STATUS_OPERACIONAL_CPE,
  IN_CHAR_CPE_MODEL,
  TAXONOMIA_ONT,
  IN_CHAR_CPE_VENDOR,
  DATA_CICLO_VIDA_CPE,
  STATUS_PROVISAO_CPE,
  DATA_PROVISAO_CPE,
  ORIGEM,
  DT_FOTO
FROM `gold_zone.tb_eng_hc_resources`
order by EXTERNAL_CODE ,TRILHA_EQUIPAMENTO desc
