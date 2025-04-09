# import sqlite3
# import os
# from datetime import datetime, timedelta

# # Ruta a la carpeta y base de datos
# ruta_carpeta = r"C:\Users\ProgramadorJunior\OneDrive - dreampackgroup.com\Escritorio\ProJr\QUERY_GENERAL\2024_query\QUERYS_POR_HACER\Dic\script\data"
# ruta_db = os.path.join(ruta_carpeta, "pruebaMarcacion.db")

# """ 1.- CREAR LA TABLA tabla_marcaciones"""
# # Crear la carpeta si no existe
# if not os.path.exists(ruta_carpeta):
#     os.makedirs(ruta_carpeta)

# # Conectar a la base de datos (se crea automáticamente si no existe)
# conexion = sqlite3.connect(ruta_db)
# cursor = conexion.cursor()

# # Crear la tabla
# cursor.execute("""
# CREATE TABLE IF NOT EXISTS tabla_marcaciones (
#     id INTEGER PRIMARY KEY AUTOINCREMENT,
#     fecha DATE NOT NULL
# );
# """)


# """ 2.- INSERTAR REGISTRO EN LA TABLA """

# # Fechas de prueba
# hoy = datetime.now().date()
# ayer = hoy - timedelta(days=1)
# anteayer = hoy - timedelta(days=2)

# # Insertar registros de prueba
# registros = [
#     (hoy,),
#     (ayer,),
#     (anteayer,),
#     (hoy - timedelta(days=3),),  # 3 días antes
#     (hoy - timedelta(days=4),),  # 4 días antes
#     (hoy - timedelta(days=5),),  # 5 días antes
#     (hoy - timedelta(days=6),),  # 6 días antes
#     (hoy - timedelta(days=7),),  # 7 días antes
#     (hoy - timedelta(days=8),),  # 8 días antes
#     (hoy - timedelta(days=9),),  # 9 días antes
# ]

# cursor.executemany("INSERT INTO tabla_marcaciones (fecha) VALUES (?);", registros)


# """ 3.-  MOSTRAR REGISTROS"""
# # Consultar todos los registros
# cursor.execute("SELECT * FROM tabla_marcaciones;")
# registros = cursor.fetchall()

# # Mostrar los registros
# for registro in registros:
#     print(registro)

# # Cerrar la conexión
# conexion.close()


# """ PASO 1 Y 2   """
# # Guardar los cambios y cerrar la conexión
# conexion.commit()
# conexion.close()

# print(f"1.- Base de datos creada en: {ruta_db}")
# print("2.- Registros de prueba insertados correctamente.")















""" crear la bd """
# import sqlite3
# import os

# # Ruta a la carpeta y base de datos
# ruta_carpeta = r"C:\Users\ProgramadorJunior\OneDrive - dreampackgroup.com\Escritorio\ProJr\QUERY_GENERAL\2024_query\QUERYS_POR_HACER\Dic\script\data"
# ruta_db = os.path.join(ruta_carpeta, "pruebaMarcacion.db")

# # Crear la carpeta si no existe
# if not os.path.exists(ruta_carpeta):
#     os.makedirs(ruta_carpeta)

# # Conectar a la base de datos (se crea automáticamente si no existe)
# conexion = sqlite3.connect(ruta_db)
# cursor = conexion.cursor()

# # Crear la tabla
# cursor.execute("""
# CREATE TABLE IF NOT EXISTS tabla_marcaciones (
#     id INTEGER PRIMARY KEY AUTOINCREMENT,
#     fecha DATE NOT NULL
# );
# """)

# # Guardar los cambios y cerrar la conexión
# conexion.commit()
# conexion.close()

# print(f"Base de datos creada en: {ruta_db}")





""" ejcutar la data """


# import sqlite3
# import os
# from datetime import datetime, timedelta

# # Ruta a la carpeta y base de datos
# ruta_carpeta = r"C:\Users\ProgramadorJunior\OneDrive - dreampackgroup.com\Escritorio\ProJr\QUERY_GENERAL\2024_query\QUERYS_POR_HACER\Dic\script\data"
# ruta_db = os.path.join(ruta_carpeta, "pruebaMarcacion.db")

# # Conectar a la base de datos
# conexion = sqlite3.connect(ruta_db)
# cursor = conexion.cursor()

# # Fechas de prueba
# hoy = datetime.now().date()
# ayer = hoy - timedelta(days=1)
# anteayer = hoy - timedelta(days=2)

# # Insertar registros de prueba
# registros = [
#     (hoy,),
#     (ayer,),
#     (anteayer,),
#     (hoy - timedelta(days=3),),  # 3 días antes
#     (hoy - timedelta(days=4),),  # 4 días antes
#     (hoy - timedelta(days=5),),  # 5 días antes
#     (hoy - timedelta(days=6),),  # 6 días antes
#     (hoy - timedelta(days=7),),  # 7 días antes
#     (hoy - timedelta(days=8),),  # 8 días antes
#     (hoy - timedelta(days=9),),  # 9 días antes
# ]

# cursor.executemany("INSERT INTO tabla_marcaciones (fecha) VALUES (?);", registros)

# # Guardar los cambios y cerrar la conexión
# conexion.commit()
# conexion.close()

# print("Registros de prueba insertados correctamente.")


# """ leeer la bd """
import sqlite3

# Ruta a la base de datos
ruta_db = "C:\\Users\\ProgramadorJunior\\OneDrive - dreampackgroup.com\\Escritorio\\ProJr\\QUERY_GENERAL\\2024_query\\QUERYS_POR_HACER\\Dic\\script\\data\\pruebaMarcacion.db"

# Conectar a la base de datos
conexion = sqlite3.connect(ruta_db)
cursor = conexion.cursor()

# Consultar todos los registros
cursor.execute("SELECT * FROM tabla_marcaciones;")
registros = cursor.fetchall()

# Mostrar los registros
for registro in registros:
    print(registro)

# Cerrar la conexión
conexion.close()

""" elimino los registro mas antiguo  """
# import sqlite3
# from datetime import datetime, timedelta

# # Ruta a la base de datos
# ruta_db = "C:\\Users\\ProgramadorJunior\\OneDrive - dreampackgroup.com\\Escritorio\\ProJr\\QUERY_GENERAL\\2024_query\\QUERYS_POR_HACER\\Dic\\script\\data\\pruebaMarcacion.db"

# # Conectar a la base de datos
# conexion = sqlite3.connect(ruta_db)
# cursor = conexion.cursor()

# # Obtener la fecha de hoy, ayer y anteayer
# hoy = datetime.now().date()
# ayer = hoy - timedelta(days=1)
# anteayer = hoy - timedelta(days=2)

# # Consulta para eliminar registros antiguos (excepto hoy, ayer y anteayer)
# consulta = f"""
# DELETE FROM tabla_marcaciones
# WHERE fecha < '{anteayer}';
# """
# # Ejecutar la consulta
# cursor.execute(consulta)

# # Guardar los cambios y cerrar la conexión
# conexion.commit()
# conexion.close()

# print("Registros antiguos eliminados correctamente. Se conservan los registros de hoy, ayer y anteayer.")



""" eliminar todo la data de la tabla """

# import sqlite3

# # Ruta a la base de datos
# ruta_db = "C:\\Users\\ProgramadorJunior\\OneDrive - dreampackgroup.com\\Escritorio\\ProJr\\QUERY_GENERAL\\2024_query\\QUERYS_POR_HACER\\Dic\\script\\data\\pruebaMarcacion.db"

# # Conectar a la base de datos
# conexion = sqlite3.connect(ruta_db)
# cursor = conexion.cursor()

# # Vaciar la tabla (eliminar todos los registros)
# cursor.execute("DELETE FROM tabla_marcaciones;")

# # Guardar los cambios y cerrar la conexión
# conexion.commit()
# conexion.close()

# print("Todos los registros de la tabla han sido eliminados.")