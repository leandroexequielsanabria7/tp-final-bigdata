CREATE OR REPLACE TABLE rrhh_invalidos AS
SELECT *,CONCAT_WS(' | ',
        CASE
            WHEN nombre IS NULL OR TRIM(nombre) = ''
            THEN 'Nombre nulo o vacio'
        END,

        CASE
            WHEN apellido IS NULL OR TRIM(apellido) = ''
            THEN 'Apellido nulo o vacio'
        END,

        CASE
            WHEN email IS NULL OR TRIM(email) = ''
            THEN 'Email nulo o vacio'
        END,

        CASE
            WHEN departamento IS NULL OR TRIM(departamento) = ''
            THEN 'Departamento nulo o vacio'
        END,

        CASE
            WHEN cargo IS NULL OR TRIM(cargo) = ''
            THEN 'Cargo nulo o vacio'
        END,

        CASE
            WHEN salario IS NULL OR salario <= 0
            THEN 'Salario nulo o invalido'
        END,

        CASE
            WHEN modalidad IS NULL OR TRIM(modalidad) = ''
            THEN 'Modalidad nula o vacia'
        END

    ) AS motivo_rechazo
FROM rrhh_raw
WHERE
    nombre IS NULL OR TRIM(nombre) = ''
    OR apellido IS NULL OR TRIM(apellido) = ''
    OR email IS NULL OR TRIM(email) = ''
    OR departamento IS NULL OR TRIM(departamento) = ''
    OR cargo IS NULL OR TRIM(cargo) = ''
    OR salario IS NULL OR salario <= 0
    OR modalidad IS NULL OR TRIM(modalidad) = '';


CREATE OR REPLACE TABLE rrhh_validos AS
SELECT *
FROM rrhh_raw
WHERE
    nombre IS NOT NULL AND TRIM(nombre) <> ''
    AND apellido IS NOT NULL AND TRIM(apellido) <> ''
    AND email IS NOT NULL AND TRIM(email) <> ''
    AND departamento IS NOT NULL
    AND TRIM(departamento) <> ''
    AND cargo IS NOT NULL
    AND TRIM(cargo) <> ''
    AND salario IS NOT NULL
    AND salario > 0
    AND modalidad IS NOT NULL
    AND TRIM(modalidad) <> '';