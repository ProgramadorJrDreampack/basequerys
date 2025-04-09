import sqlite3
from datetime import datetime, timedelta

# Ruta a la base de datos SQLite (ajusta esta ruta según tu configuración)
ruta_db = "/ruta/a/tu/base_de_datos.db"  # Cambia esto por la ruta correcta

# Conectar a la base de datos
conexion = sqlite3.connect(ruta_db)
cursor = conexion.cursor()

# Obtener la fecha de hoy, ayer y anteayer
hoy = datetime.now().date()
ayer = hoy - timedelta(days=1)
anteayer = hoy - timedelta(days=2)

# Consulta para eliminar registros antiguos (excepto hoy, ayer y anteayer)
consulta = f"""
DELETE FROM tabla_marcaciones
WHERE fecha < '{anteayer}';
"""
# Ejecutar la consulta
cursor.execute(consulta)

# Guardar los cambios y cerrar la conexión
conexion.commit()
conexion.close()

print("Registros antiguos eliminados correctamente. Se conservan los registros de hoy, ayer y anteayer.")