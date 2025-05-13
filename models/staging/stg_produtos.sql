{{ config(materialized='view') }}

SELECT DISTINCT
    ID_PRODUTO AS id_produto,
    NOME_PRODUTO AS nome_produto,
    DESCRICAO AS descricao,
    CATEGORIA AS categoria,
    PRECO AS preco
FROM {{ source('recomendacao', 'PRODUTOS_ESPORTIVOS') }}
