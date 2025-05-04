# Recomendação de Produtos com Análise de Cesta de Mercado: Transformação dos Dados com dbt

Como mencionado anteriormente, após a ingestão inicial dos dados no Snowflake, as transformações são realizadas com o dbt Core (Data Build Tool), uma ferramenta especializada em transformação de dados baseada em SQL, que permite construir pipelines modulares, auditáveis e versionadas.

No contexto deste projeto, o dbt é responsável por aplicar as transformações necessárias para preparar os dados para análises posteriores, como a aplicação do algoritmo Apriori. Isso inclui tarefas como filtragem, agregação, renomeação e reestruturação dos dados.

Adotamos uma arquitetura de transformação baseada na abordagem ELT (Extract, Load, Transform), na qual os dados são inicialmente extraídos e carregados no Snowflake e posteriormente transformados dentro do próprio data warehouse utilizando o dbt. Essa abordagem permite melhor aproveitamento da escalabilidade do Snowflake e facilita a rastreabilidade e versionamento das transformações.

O fluxo de transformação segue a estrutura em camadas recomendada pela comunidade dbt:

- Staging: limpeza, padronização e renomeação de colunas provenientes dos dados brutos. Exemplos incluem normalização de nomes de produtos, eliminação de nulos e tipagem de colunas.

- Intermediate: estruturação dos dados em um formato analítico intermediário, com joins entre tabelas, pivotagens e agregações por transaction_id.

- Marts: geração das tabelas finais, já otimizadas para o consumo analítico. 

Essa separação em camadas facilita a manutenção, melhora a legibilidade do código SQL e favorece a colaboração entre times 

  Referência: [How we structure our dbt projects](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview)


https://www.youtube.com/watch?v=mBrk5hvqc84 20 min