{{ config(materialized='view') }}

SELECT *
FROM {{ source('recomendacao', 'STG_CLIENTES') }}
WHERE DATA_NASCIMENTO <= DATEADD(YEAR, -18, CURRENT_DATE)
