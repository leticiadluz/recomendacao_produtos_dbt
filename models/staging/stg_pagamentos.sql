{{ config(materialized='view') }}
SELECT DISTINCT
    ID_PAGAMENTO AS id_pagamento,
    TIPO_PAGAMENTO AS tipo_pagamento
FROM {{ source('recomendacao', 'TABELA_TIPOS_PAGAMENTO') }}
