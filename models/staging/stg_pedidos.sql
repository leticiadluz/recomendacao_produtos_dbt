{{ config(materialized='view') }}

SELECT
    ID_TRANSACAO AS id_transacao,
    ID_CLIENTE AS id_cliente,
    ID_PRODUTO AS id_produto,
    ID_PAGAMENTO AS id_pagamento,
    DATA_PEDIDO AS data_pedido,
    QUANTIDADE AS quantidade
FROM {{ source('recomendacao', 'TABELA_PEDIDOS') }}
WHERE ID_CLIENTE IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY ID_TRANSACAO, ID_PRODUTO
    ORDER BY QUANTIDADE DESC, DATA_PEDIDO DESC
) = 1
