# Informe del Proyecto: Limpieza de Datos de Empleados (RRHH)

## ¿De qué se trata?

Este proyecto toma la información de los empleados de una empresa ficticia (**TecnoSur**), la revisa, corrige los errores que encuentra y guarda una versión final limpia y ordenada.

Se puede comparar con una **línea de producción en una fábrica**: entra materia prima con fallas, pasa por distintas estaciones de control y arreglo, y al final sale un producto terminado listo para usar.

---

## ¿Qué problema resuelve?

Los datos originales de los empleados tenían errores comunes, por ejemplo:

- Nombres escritos de forma desprolija (`  jUAN`, `PEREZ`).
- Empleados **sin email** cargado.
- Empleados **sin departamento** asignado.
- **Sueldos negativos o en cero**, algo que no tiene sentido.
- **Empleados repetidos** más de una vez.

Trabajar con datos así lleva a informes equivocados. El proyecto se encarga de dejarlos prolijos de forma automática.

---

## ¿Cómo funciona? (las 4 etapas)

El proceso se divide en cuatro pasos, uno detrás del otro:

### 1. Extracción — *"traer los datos"*
Se copian los datos de los empleados desde la base de datos original a un espacio de trabajo propio, sin modificar el original.

### 2. Validación — *"separar lo bueno de lo malo"*
Se revisa cada empleado y se lo separa en dos grupos:

| Grupo | Qué contiene |
|---|---|
| **Válidos** | Empleados con todos sus datos completos y correctos. |
| **Inválidos** | Empleados con algún dato faltante o incorrecto. A cada uno se le anota **el motivo** (por ejemplo: *"Email nulo o vacío"*). |

### 3. Transformación — *"arreglar lo que se puede"*
A los empleados con errores se les aplican correcciones:

| Problema | Cómo se corrige |
|---|---|
| Nombre o apellido mal escrito | Se quitan espacios de más y se deja la primera letra en mayúscula (`Juan Perez`). |
| Falta el email | Se arma automáticamente: `nombre.apellido` + número de empleado + `@tecnosur.com`. Ej: `ana.gomez2@tecnosur.com` |
| Falta el departamento | Se deduce a partir del cargo. Ej: un *Contador* va a **Finanzas**, un *Vendedor* a **Comercial**. |
| Sueldo negativo | Se lo pasa a positivo (`-500` → `500`). |

Después se juntan los empleados válidos con los ya corregidos, y se **eliminan los repetidos**, dejando un solo registro por empleado.

### 4. Carga — *"guardar el resultado"*
La lista final limpia se guarda en un archivo (`rrhh_final.parquet`), que es un formato liviano y rápido de leer, ideal para hacer análisis o reportes después.

---

## Resultados obtenidos

| Etapa | Cantidad de registros |
|---|---|
| Empleados extraídos | 2.575 |
| Empleados válidos | 2.160 |
| Empleados con errores (a corregir) | 415 |

Los 415 registros con errores no se descartaron: se corrigieron y se sumaron a la lista final.

---

## Automatización

El proyecto incluye una versión preparada para **Airflow**, una herramienta que funciona como un **despertador programado**: hace que todo el proceso se ejecute solo, **todos los días a las 2 de la mañana**, sin que nadie tenga que iniciarlo a mano.

Las cuatro etapas se ejecutan en orden, y cada una espera a que termine la anterior:

```
Extracción  →  Validación  →  Transformación  →  Carga
```

---

## Herramientas utilizadas

| Herramienta | Para qué se usó |
|---|---|
| **Python** | Para coordinar todo el proceso. |
| **SQL** | Para revisar y corregir los datos. |
| **DuckDB** | Como espacio de trabajo donde se procesan los datos. |
| **SQLite** | Base de datos donde están los datos originales. |
| **Airflow** | Para que el proceso se ejecute solo todos los días. |
| **Parquet** | Formato del archivo final. |

---

## Organización del proyecto

```
tp-final-bigdata/
├── pipeline.py          → Ejecuta todo el proceso de una vez
├── dag/dag_pipeline     → Versión automática con Airflow
├── sql/
│   ├── extract.sql      → Paso 1: traer los datos
│   ├── validation.sql   → Paso 2: separar válidos e inválidos
│   ├── transform.sql    → Paso 3: corregir los errores
│   └── export.sql       → Paso 4: armar la tabla final
└── outputs/
    └── rrhh_final.parquet → Resultado final
```

---

## Conclusión

El proyecto muestra cómo convertir datos desordenados en información confiable mediante un proceso claro y repetible. Separar el trabajo en etapas permite saber en qué paso está cada cosa y encontrar los problemas más rápido. Además, al estar automatizado, los datos se mantienen actualizados todos los días sin trabajo manual.
