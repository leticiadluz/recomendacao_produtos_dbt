# Recomendação de Produtos com Análise de Cesta de Mercado: Transformação dos Dados com dbt Core

https://www.youtube.com/watch?v=mBrk5hvqc84 20 min

# 1 Introdução
Como mencionado anteriormente, após a ingestão inicial dos dados no Snowflake, as transformações são realizadas com o dbt Core (Data Build Tool), uma ferramenta especializada em transformação de dados baseada em SQL, que permite construir pipelines modulares, auditáveis e versionadas.

No contexto deste projeto, o dbt é responsável por aplicar as transformações necessárias para preparar os dados para análises posteriores, como a aplicação do algoritmo Apriori. Isso inclui tarefas como filtragem, agregação, renomeação e reestruturação dos dados.

Adotamos uma arquitetura de transformação baseada na abordagem ELT (Extract, Load, Transform), na qual os dados são inicialmente extraídos e carregados no Snowflake e posteriormente transformados dentro do próprio data warehouse utilizando o dbt. Essa abordagem permite melhor aproveitamento da escalabilidade do Snowflake e facilita a rastreabilidade e versionamento das transformações.

O fluxo de transformação segue a estrutura em camadas recomendada pela comunidade dbt:

- Staging: limpeza, padronização e renomeação de colunas provenientes dos dados brutos. Exemplos incluem normalização de nomes de produtos, eliminação de nulos e tipagem de colunas.

- Intermediate: estruturação dos dados em um formato analítico intermediário, com joins entre tabelas, pivotagens e agregações por transaction_id.

- Marts: geração das tabelas finais, já otimizadas para o consumo analítico. 

Essa separação em camadas facilita a manutenção, melhora a legibilidade do código SQL e favorece a colaboração entre times 

  Referência: [How we structure our dbt projects](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview)

# 2 Configurações necessárias

1-  A primeira parte que precisa ser feita é confirmar se o arquivo profiles.yml foi gerado corretamente. Esse arquivo é gerado automaticamente quando você roda o comando **dbt init**. 
```bash
recomendacao_produtos_dbt:
  outputs:
    dev:
      account: suaconta
      database: seubanco
      password: suasenha
      role: suarole
      schema: seuschema
      threads: especifiqueumvalor
      type: snowflake
      user: seuusuario
      warehouse: COMPUTE_WH
  target: dev
```

Durante a criação do projeto, o dbt solicita as informações de conexão com o banco de dados, como tipo de banco (ex: Snowflake), usuário, senha, warehouse, entre outros.
Essas informações são então salvas no arquivo profiles.yml. O arquivo  para usuários Windows fica localizado em: C:\Users\SeuUsuario\.dbt\profiles.yml. Esse arquivo é essencial porque é ele que permite ao dbt se conectar ao banco de dados e executar os modelos.

2 - O segundo passo é verificar se o arquivo dbt_project.yml foi criado. Esse arquivo é criado automaticamente e parcialmente preenchido quando rodamos o comando dbt init. Ele fica salvo na raiz da pasta do projeto e é nele que você define as principais configurações do seu projeto dbt, como:
- Nome do projeto
- Caminhos das pastas (models, seeds, snapshots, etc.)
- Nome do profile que será usado (que deve bater com o profiles.yml)
- Materialização padrão dos modelos (ex: view, table)
- Estrutura de camadas (staging, intermediate, marts)

Exemplo de dbt_project.yml configurado corretamente:

```bash
name: 'recomendacao_produtos_dbt'     # Nome do projeto
version: '1.0.0'                      # Versão do projeto 

profile: 'recomendacao_produtos_dbt'  # Nome deve ser igual ao usado no profiles.yml

# Caminhos das pastas onde o dbt vai buscar os arquivos
model-paths: ["models"]               # Modelos (transformações em SQL)
analysis-paths: ["analyses"]          # Análises temporárias em SQL
test-paths: ["tests"]                 # Testes customizados
seed-paths: ["seeds"]                 # Dados fixos 
macro-paths: ["macros"]               # Funções reutilizáveis em Jinja
snapshot-paths: ["snapshots"]         # Tabelas de histórico 


clean-targets:
  - "target"
  - "dbt_packages"

# Configuração de como os modelos serão criados por camada
models:
  recomendacao_produtos_dbt:          # Nome da pasta do projeto 
    staging:                          # Subpasta dentro de models
      +materialized: view             # Como será materializado
    intermediate:
      +materialized: view
    marts:
      +materialized: table

```

3 - O terceiro passo é verificar (ou criar) o arquivo packages.yml. Esse arquivo não é criado automaticamente pelo dbt init, mas você pode criá-lo manualmente na raiz do projeto. O packages.yml serve para adicionar extensões ao dbt, como pacotes públicos com macros reutilizáveis, testes prontos e utilitários avançados. Exemplo de packages.yml com o dbt_utils:

```bash
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
```
Depois de criar o packages.yml, execute o comando:

```bash
dbt deps
```
Assim como requirements.txt no Python, o packages.yml define as dependências do seu projeto e deve ser versionado no Git. A pasta dbt_packages/ gerada não precisa ser versionada, pois será recriada com dbt deps.

4 - O quarto passo é organizar corretamente a pasta models/. 
Essa é a principal pasta do seu projeto dbt, onde você coloca os modelos SQL que transformam os dados. Por padrão, o dbt procura os arquivos .sql e schema.yml dentro da pasta models/. Estrutura recomendada:

```bash
models/
├── staging/                  # Camada de entrada 
│   ├── clientes/
│   │   ├── stg_clientes.sql
│   │   └── schema.yml
│   └── ...
├── intermediate/            # Camada com lógica de limpeza/tratamento
│   ├── clientes/
│   │   ├── int_clientes.sql
│   │   └── schema.yml
├── marts/                   # Camada final, consumo analítico
│   ├── ...
```

 Exemplo stg_clientes.sql, onde colocamos as tranformações que iremos realizar: 

```bash
 {{ config(materialized='view') }}

SELECT
  ID_CLIENTE AS cliente_id,
  NOME_CLIENTE AS nome,
  CEP,
  NUMERO
FROM {{ source('recomendacao', 'TABELA_CLIENTES') }}
```

Exemplo schema.yml para staging, aqui colocamos os testes que faremos:

```bash
version: 2

sources:
  - name: recomendacao
    database: RECOMENDACAO_ANALISE
    schema: PUBLIC
    tables:
      - name: TABELA_CLIENTES

models:
  - name: stg_clientes
    description: "Modelo de staging para clientes"
    columns:
      - name: cliente_id
        description: "ID do cliente"
        tests:
          - not_null
          - unique
```
# 3 - Iniciando o projeto:

 1 - **Para iniciar o projeto, precisamos materializar os primeiros dados.** Depois de criar a estrutura inicial do projeto dbt e os arquivos da camada staging (como o stg_clientes.sql e seu schema.yml), o próximo passo é executar o modelo para que ele seja materializado no banco de dados (neste caso, como uma view no Snowflake).  Isso é feito com o comando:
 
 
```bash
dbt run --select stg_clientes
```
 Esse comando executa o modelo e cria a view STG_CLIENTES no Snowflake, refletindo as transformações definidas no SQL.

 2 – **Validar a qualidade dos dados com testes.** Após materializar a view, é importante verificar se os dados estão consistentes com as regras definidas em schema.yml. Para isso, utilizamos o comando:

```bash
dbt test --select stg_clientes
```

Ao executar os testes do modelo stg_clientes, foram identificados os seguintes problemas nos dados brutos:
- IDs de clientes duplicados, o que causou falha no teste de unique.
- Campos cep com valores nulos, falhando no teste de not_null.
- Coluna numero com valores <= 0, que violaram a regra definida no teste expression_is_true

**Decisão de tratamento neste momento:** Como neste estágio do projeto, o objetivo é apenas estruturar a camada de staging e não corrigir completamente os dados, optei por fazer apenas dois ajustes mínimos para garantir que a modelagem continue sem erros críticos:
- Remoção duplicidade de IDs: usando DISTINCT, mantenho apenas um registro por cliente_id
- Substituição de valores negativos na coluna numero: Se for negativo, converto para positivo e se for zero, substituo por NULL.

Essas correções são pontuais e têm o único objetivo de permitir a continuidade da modelagem, o tratamento completo será feito na camada intermediate.

**Importante, o comando dbt run materializa os dados no banco de dados mesmo que os testes definidos no schema.yml tenham falhado. Ou seja, a criação da view ou tabela não depende da aprovação nos testes, os testes servem apenas para alertar sobre problemas nos dados, mas não bloqueiam a execução do modelo.**

2 - Aplicamos as correções diretamente no modelo stg_clientes.sql, realizando a remoção de duplicidades e a substituição de valores negativos na coluna numero. Em seguida, executamos novamente o comando dbt run.

Esse comando recompila o modelo atualizado e substitui a view anterior no Snowflake por uma nova versão, já contendo as correções realizadas. A view STG_CLIENTES passa então a refletir os dados padronizados e validados conforme as novas regras definidas no modelo.

![alt text](imagens/view_stg.png)
imagem não foi lida
