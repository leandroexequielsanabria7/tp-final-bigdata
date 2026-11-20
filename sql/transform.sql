-- =====================================================================
-- transform.sql  (DuckDB)
-- Equivalente SQL de transform.py
-- Entrada : rrhh_validos, rrhh_rechazados
-- Salida  : rrhh_transformados (rechazados corregidos)
--           rrhh_corregidos    (validos + transformados, sin duplicados)
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1) Rechazados transformados -> rrhh_transformados
--    - nombre/apellido: trim + capitalize
--    - email nulo: nombre.apellido<numero>@tecnosur.com
--    - departamento nulo: se deduce del cargo
--    - salario <= 0: valor absoluto
--    - se elimina motivo_rechazo
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE rrhh_transformados AS
WITH base AS (
    SELECT
        * EXCLUDE (motivo_rechazo) REPLACE (
            upper(left(trim(nombre), 1))   || lower(substr(trim(nombre), 2))   AS nombre,
            upper(left(trim(apellido), 1)) || lower(substr(trim(apellido), 2)) AS apellido
        )
    FROM rrhh_invalidos
)
SELECT
    * REPLACE (
        -- completar_email
        COALESCE(
            email,
            lower(trim(nombre)) || '.' || lower(trim(apellido))
            || CAST(CAST(regexp_extract(id_empleado, '(\d+)$', 1) AS INTEGER) AS VARCHAR)
            || '@tecnosur.com'
        ) AS email,

        -- completar_departamentos
        COALESCE(
            departamento,
            CASE lower(trim(cargo))
                WHEN 'desarrollador'        THEN 'Tecnologia'
                WHEN 'analista de datos'    THEN 'Tecnologia'
                WHEN 'soporte tecnico'      THEN 'Tecnologia'
                WHEN 'contador'             THEN 'Finanzas'
                WHEN 'tesorero'             THEN 'Finanzas'
                WHEN 'ejecutivo de cuentas' THEN 'Comercial'
                WHEN 'vendedor'             THEN 'Comercial'
                WHEN 'reclutador'           THEN 'RRHH'
                WHEN 'generalista'          THEN 'RRHH'
            END
        ) AS departamento,

        -- corregir_salarios
        CASE
            WHEN CAST(salario AS DOUBLE) <= 0 THEN abs(CAST(salario AS DOUBLE))
            ELSE CAST(salario AS DOUBLE)
        END AS salario
    )
FROM base;


-- ---------------------------------------------------------------------
-- 2) Unión validos + transformados (equivale a pd.concat)
--    Se guarda el orden original para respetar keep='first'
-- ---------------------------------------------------------------------
CREATE OR REPLACE TEMP TABLE rrhh_union AS
SELECT
    * REPLACE (
        upper(left(trim(nombre), 1))   || lower(substr(trim(nombre), 2))   AS nombre,
        upper(left(trim(apellido), 1)) || lower(substr(trim(apellido), 2)) AS apellido
    ),
    1     AS _origen,
    rowid AS _fila
FROM rrhh_validos
UNION ALL BY NAME
SELECT *, 2 AS _origen, rowid AS _fila
FROM rrhh_transformados;


-- ---------------------------------------------------------------------
-- 3) Cantidad de filas duplicadas completas (df.duplicated().sum())
-- ---------------------------------------------------------------------
SELECT
    'Valores Duplicados eliminados' AS mensaje,
    (SELECT count(*) FROM rrhh_union)
  - (SELECT count(*) FROM (SELECT DISTINCT * EXCLUDE (_origen, _fila) FROM rrhh_union)) AS cantidad;


-- ---------------------------------------------------------------------
-- 4) Eliminar duplicados por id_empleado, conservando el primero
--    (drop_duplicates(subset=['id_empleado']))
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE rrhh_corregidos AS
SELECT * EXCLUDE (_origen, _fila)
FROM rrhh_union
QUALIFY row_number() OVER (PARTITION BY id_empleado ORDER BY _origen, _fila) = 1
ORDER BY _origen, _fila;

DROP TABLE rrhh_union;