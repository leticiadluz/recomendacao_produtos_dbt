{{ config(materialized='view') }}

WITH pedidos_validos AS (
    SELECT *
    FROM {{ ref('stg_pedidos') }}
    WHERE data_pedido >= '2024-01-01'
)

SELECT P.*
FROM pedidos_validos P
LEFT JOIN {{ ref('stg_produtos') }} PROD
    ON P.id_produto = PROD.id_produto
WHERE PROD.id_produto IS NOT NULL
