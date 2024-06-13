CREATE OR REPLACE VIEW `fibrasil-datalake-dev.delivery_zone.vw_reclamacao_anatel`
      (
        PERIODO             OPTIONS(description="Ano,Mês em que foi registrado a solicitações de reclamação do Orgão Ex: 2024-04-01"),
        COD_MUNICIPIO       OPTIONS(description="ID de identificação atribuído pelo IBGE.Município onde foi registrado a acesso ao serviço Ex: 3509502,3550605"),
        UF                  OPTIONS(description="Sigla Estado onde foi registrado a solicitação. Ex: SP,RJ"),
        CIDADE              OPTIONS(description="Cidade onde foi registrado a solicitação. Ex: Campinas,Rio de Janeiro"),
        CANAL_ENTRADA       OPTIONS(description="Canal no qual foi registrado a solicitação Ex: Usuario WEB,Mobile App"),
        CONDICAO            OPTIONS(description="Status da solicitação Ex: Nova,Reaberta"),
        TIPO_ATENDIMENTO    OPTIONS(description="Tipo de atendimento feito na solictação Ex: Reclamação"),
        SERVICO             OPTIONS(description="Serviço utilizado que ocorreu a solicitação Ex: SCM(banda larga)"),
        CNPJ                OPTIONS(description="CNPJ da Operadora Ex: 66970229000167,02558157000162"),
        OPERADORAS          OPTIONS(description="Prestadorta de serviço Ex: Vivo,Claro"),
        ASSUNTO             OPTIONS(description="Assunto relatado no momento da solicitação Ex: Cobranca,Qualidade"),
        PROBLEMA            OPTIONS(description="Problema relatado no momento da solicitação Ex: Reparo,Lentidão"),
        SOLICITACOES        OPTIONS(description="Contagem dos registros feitos Ex: 1 ,2 etc."),
        DT_FOTO             OPTIONS(description="Data da Atualização das informações")
      )
 OPTIONS(
    description="View referente a tabela de Reclamação Anatel."
)
 AS

SELECT
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
FROM `fibrasil-datalake-dev.gold_zone.tb_reclamacoes_banda_larga_fixa`