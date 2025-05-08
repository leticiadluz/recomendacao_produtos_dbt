{{ config(materialized='view') }}

WITH base AS (
    SELECT DISTINCT
        ID_CLIENTE,
        NOME_CLIENTE,
        RUA,
        ESTADO,
        PAIS,
        NUMERO,
        CEP,
        DATA_NASCIMENTO
    FROM {{ source('recomendacao', 'TABELA_CLIENTES') }}
)

SELECT
    ID_CLIENTE AS cliente_id,
    NOME_CLIENTE AS nome,
    RUA AS rua,
    ESTADO AS estado,
    PAIS AS pais,
    
    CASE
        WHEN TRY_CAST(NUMERO AS INTEGER) = 0 THEN NULL
        WHEN TRY_CAST(NUMERO AS INTEGER) < 0 THEN ABS(TRY_CAST(NUMERO AS INTEGER))
        ELSE TRY_CAST(NUMERO AS INTEGER)
    END AS numero,

    CEP AS cep,
    DATA_NASCIMENTO AS data_nascimento
FROM base
