WITH pedidos AS (
    SELECT
        ip.id_transacao,
        ip.id_produto,
        sp.nome_produto
    FROM {{ ref('int_pedidos') }} ip
    JOIN {{ ref('stg_produtos') }} sp
        ON ip.id_produto = sp.id_produto
),

produtos_transacoes AS (
    SELECT
        id_transacao,
        LISTAGG(CAST(id_produto AS STRING), ', ') AS produtos,
        LISTAGG(nome_produto, ', ') AS nomes_produtos
    FROM pedidos
    GROUP BY id_transacao
)

SELECT *
FROM produtos_transacoes
