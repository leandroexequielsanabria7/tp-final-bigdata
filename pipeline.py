import pandas as pd 
import duckdb
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data"/ "rrhh.sqlite"
OUTPUT_DIR = BASE_DIR / "outputs"
SQL_DIR = BASE_DIR / "sql"

def read_sql(fielname: str):
    try:
        path = SQL_DIR / fielname
        return path.read_text(encoding="utf-8")
    except Exception as e:
        print ("Error al leer el sql: ",str(e))
        return None

def count(table_name: str,con):
    try:
        return con.execute(f"SELECT COUNT(*) FROM {table_name}").fetchall()
    except Exception as e:
        print(f"Hubo un error al ejecutar el count ",str(e))


def main():
    conn = duckdb.connect("rrhh.duckdb")

    conn.execute(f"ATTACH OR REPLACE '{str(DATA_DIR)}' AS sqlite_conn (TYPE SQLITE, READ_ONLY);")

    print("####### Extraccion #######")

    conn.execute(read_sql("extract.sql"))

    print(f"Valores Extraidos: ",count(table_name="rrhh_raw",con=conn))

    print("####### Validacion #######")

    conn.execute(read_sql("validation.sql"))

    print(f"Valores Validados: ",count(table_name="rrhh_validos",con=conn))
    print(f"Valores Invalidos: ",count(table_name="rrhh_invalidos",con=conn))

    print("####### Transformacion #######")

    conn.execute(read_sql("transform.sql"))


    print(f"Valores Trnasformados: ",count("rrhh_transformados",con=conn))

    print("####### Carga #######")

    try:
        df_rrhh = conn.execute(read_sql("export.sql")).df()
    finally:
        conn.unregister("empleados_finales")

    print("Valores Exportados:", count(table_name="rrhh_final", con=conn))

    df_rrhh.to_parquet(str(OUTPUT_DIR / "rrhh_final.parquet"))
    


if __name__ == "__main__":
    main()
