from zk import ZK, const
from datetime import datetime, timedelta
from tabulate import tabulate

conn = None
zk = ZK("192.168.170.216", port=4370, timeout=5)
try:
    print("Conexión al dispositivo")
    conn = zk.connect()

    print("Deshabilitando el dispositivo...")
    conn.disable_device()

    print ("********** Información del dispositivo **********")
    print ("   Current Time            : %s" % conn.get_time())
    print ("   Firmware Version        : %s" % conn.get_firmware_version())
    print ("   Device Name             : %s" % conn.get_device_name())
    print ("   Serial Number           : %s" % conn.get_serialnumber())
    print ("   Mac Address             : %s" % conn.get_mac())
    print ("   Face Algorithm Version  : %s" % conn.get_face_version())
    print ("   Finger Algorithm        : %s" % conn.get_fp_version())
    print ("   Platform Information    : %s" % conn.get_platform())

    network_info = conn.get_network_params()
    print ("********** Información de red **********")
    print ("   IP                      : %s" % network_info.get('ip'))
    print ("   Netmask                 : %s" % network_info.get('mask'))
    print ("   Gateway                 : %s" % network_info.get('gateway'))

    print ("********** Información de la memoria **********")
    conn.read_sizes()
    print ("   User        (used/max)  : %s/%s" % (conn.users, conn.users_cap))
    print ("   Fingerprint (used/max)  : %s/%s" % (conn.fingers, conn.fingers_cap))

    # Obtener la fecha límite para los últimos 7 días
    fecha_limite = datetime.now() - timedelta(days=7)

    # Obtener y mostrar usuarios
    users = conn.get_users()
    user_dict = {user.user_id: user.name for user in users}  # Crear un diccionario

    # Obtener todos los registros de asistencia
    attendance_records = conn.get_attendance()

    # Filtrar los registros de los últimos 7 días
    registros_ultimos_7_dias = [
        record for record in attendance_records if record.timestamp > fecha_limite
    ]


    # Get attendances (will return list of Attendance object)
    sorted_attendances = attendance_records.get_sorted_attendance(by_date=False)  # means sorting by uid
    limited_attendances = attendance_records.get_limited_attendance(
        users=[1, 2],  # only UIDs 1, 2
        start=datetime(2022, 1, 10, 12, 42),  # from 2022,1,10 12:42:00
        end=datetime(2022, 1, 11)  # to 2022,1,11
    )

   

    # Crear una lista para la tabla
    tabla_registros = []
    for record in registros_ultimos_7_dias:
        user_name = user_dict.get(record.user_id, "Unknown")
        tabla_registros.append([
            record.uid,
            record.user_id,
            user_name,
            record.timestamp,
            record.status,
            record.punch
        ])

    # Encabezados para la tabla
    encabezados = ["UID", "User ID", "Name", "Timestamp", "Status", "Punch"]

    # Generar la tabla como texto
    tabla_texto = tabulate(tabla_registros, headers=encabezados, tablefmt="grid")

    # Mostrar la tabla
    print("\n--- Registros de Asistencia de los últimos 7 días ---")
    # print(tabla_texto)

    # Guardar la tabla en un archivo
    with open("registros_asistencia_ultimos_7_dias.txt", "w") as file:
        file.write(tabla_texto)

except Exception as e:
    print("Proceso terminado: {}".format(e))
finally:
    if conn:
        conn.disconnect()



# from zk import ZK, const
# from datetime import datetime, timedelta
# from tabulate import tabulate

# conn = None
# zk = ZK("192.168.170.216", port=4370, timeout=5)
# try:
#     print("Conexión al dispositivo")
#     conn = zk.connect()

#     print("Deshabilitando el dispositivo...")
#     conn.disable_device()

#     # Obtener la fecha límite para los últimos 7 días
#     fecha_limite = datetime.now() - timedelta(days=7)

#     # Obtener y mostrar usuarios
#     users = conn.get_users()
#     user_dict = {user.user_id: user.name for user in users}  # Crear un diccionario

#     # Obtener todos los registros de asistencia
#     attendance_records = conn.get_attendance()

#     # Filtrar los registros de los últimos 7 días
#     registros_ultimos_7_dias = [
#         record for record in attendance_records if record.timestamp > fecha_limite
#     ]

#     # Crear una lista para la tabla
#     tabla_registros = []
#     for record in registros_ultimos_7_dias:
#         user_name = user_dict.get(record.user_id, "Unknown")
#         tabla_registros.append([
#             record.uid,
#             record.user_id,
#             user_name,
#             record.timestamp,
#             record.status,
#             record.punch
#         ])

#     # Encabezados para la tabla
#     encabezados = ["UID", "User ID", "Name", "Timestamp", "Status", "Punch"]

#     # Mostrar la tabla
#     print("\n--- Registros de Asistencia de los últimos 7 días ---")
#     print(tabulate(tabla_registros, headers=encabezados, tablefmt="grid"))

#     # Guardar los registros de los últimos 7 días en un archivo
#     with open("registros_asistencia_ultimos_7_dias.txt", "w") as file:
#         file.write("UID\t\t\t\t\t\tUserId\t\t\t\t\t\tName\t\t\t\t\t\t\t\t\tTimestamp\t\t\t\t\t\t\tStatus\t\t\t\t\t\t\tPunch\n")
#         for record in registros_ultimos_7_dias:
#             user_name = user_dict.get(record.user_id, "Unknown")
#             file.write(f"{record.uid}\t\t\t\t\t{record.user_id}\t\t\t\t\t{user_name}\t\t\t\t\t\t\t\t\t{record.timestamp}\t\t\t\t\t\t\t{record.status}\t\t\t\t\t\t\t{record.punch}\n")

# except Exception as e:
#     print("Proceso terminado: {}".format(e))
# finally:
#     if conn:
#         conn.disconnect()





# ******************ESTE SI CONECTO********************************************************

""" from zk import ZK, const

conn = None
zk = ZK("192.168.170.216", port=4370, timeout=5)
try:
    print("Conexión al dispositivo ...")
    conn = zk.connect()
    print("Disabling device ..")
    conn.disable_device()
    print("Firmware Version: : {}".format(conn.get_firmware_version()))
    # print"--- Get User --"
    users = conn.get_users()
    # print("users", users)
    for user in users:
        privilege = 'User'
        if user.privilege == const.USER_ADMIN:
            privilege = 'Admin'

        print(f"{user.uid}\t\t{user.name}\t\t{privilege}")


    # Obtener y mostrar registros de asistencia
    attendance_records = conn.get_attendance()
    print("\n--- Registros de Asistencia ---")
    print("UID\tTimestamp")
    for record in attendance_records:
        print(f"{record.uid}\t\t{record.timestamp}")

        # print('*'*50)
        # print("  UID        : #{}".format(user.uid))
        # print("  Name       : {}".format(user.name))
        # print("  Privilege  : {}".format(privilege))
        # # print("  Password   : {}".format(user.password))
        # # print("  Group ID   : {}".format(user.group_id))
        # print("  User  ID   : {}".format(user.user_id))

    # print("Voice Test ...")
    # conn.test_voice()
    # print('Enabling device ...')
    # conn.enable_device()
except Exception as e:
    print("Process terminate : {}".format(e))
finally:
    if conn:
        conn.disconnect() """


# *************************ESTE SI CONECTO*********************************************

""" from zk import ZK, const
from datetime import datetime, timedelta

conn = None
zk = ZK("192.168.170.216", port=4370, timeout=5)
try:
    print("Conexión al dispositivo")
    conn = zk.connect()

    print("Deshabilitando el dispositivo...")
    conn.disable_device()

    # print("Firmware Version: : {}".format(conn.get_firmware_version()))

    print ("********** Información del dispositivo **********")
    print ("   Current Time            : %s" % conn.get_time())
    print ("   Firmware Version        : %s" % conn.get_firmware_version())
    print ("   Device Name             : %s" % conn.get_device_name())
    print ("   Serial Number           : %s" % conn.get_serialnumber())
    print ("   Mac Address             : %s" % conn.get_mac())
    print ("   Face Algorithm Version  : %s" % conn.get_face_version())
    print ("   Finger Algorithm        : %s" % conn.get_fp_version())
    print ("   Platform Information    : %s" % conn.get_platform())

    network_info = conn.get_network_params()
    print ("********** Información de red **********")
    print ("   IP                      : %s" % network_info.get('ip'))
    print ("   Netmask                 : %s" % network_info.get('mask'))
    print ("   Gateway                 : %s" % network_info.get('gateway'))

    print ("********** Información de la memoria **********")
    conn.read_sizes()
    print ("   User        (used/max)  : %s/%s" % (conn.users, conn.users_cap))
    print ("   Fingerprint (used/max)  : %s/%s" % (conn.fingers, conn.fingers_cap))

    # Obtener y mostrar usuarios
    users = conn.get_users()
    user_dict = {user.user_id: user.name for user in users}  # Crear un diccionario

    # Obtener la fecha límite para los últimos 7 días
    fecha_limite = datetime.now() - timedelta(days=7)
    print("fecha_limite", fecha_limite)

    # print("\n--- Usuarios ---")
    # print("UID\t\tName\t\tPrivilege")

    for user in users:
        privilege = 'User'
        if user.privilege == const.USER_ADMIN:
            privilege = 'Admin'
        # print(f"{user.uid}\t\t{user.name}\t\t{privilege}")

    # Obtener todos los registros de asistencia
    attendance_records = conn.get_attendance()
    # print("\n--- Registros de Asistencia ---")

     # Filtrar los registros de los últimos 7 días
    registros_ultimos_7_dias = [
        record for record in attendance_records if record.timestamp > fecha_limite
    ]

    print("registros_ultimos_7_dias", registros_ultimos_7_dias)

    # Guardar los registros de los últimos 7 días en un archivo
    with open("registros_asistencia_ultimos_7_dias.txt", "w") as file:
        file.write("UID\t\t\t\t\t\tUserId\t\t\t\t\t\tName\t\t\t\t\t\t\t\t\tTimestamp\t\t\t\t\t\t\tStatus\t\t\t\t\t\t\tPunch\n")
        for record in registros_ultimos_7_dias:
            user_name = user_dict.get(record.user_id, "Unknown")
            attributes = vars(record) 
            print("asistencia atributos", attributes)
            file.write(f"{record.uid}\t\t\t\t\t{record.user_id}\t\t\t\t\t{user_name}\t\t\t\t\t\t\t\t\t{record.timestamp}\t\t\t\t\t\t\t{record.status}\t\t\t\t\t\t\t{record.punch}\n") """

    
    # # Abrir un archivo en modo escritura
    # with open("registros_asistencia.txt", "w") as file:
    #     file.write("UID\t\t\t\t\t\tName\t\t\t\t\tTimestamp\n")
    #     for record in attendance_records:
    #         user_name = user_dict.get(record.user_id, "Unknown")  # Buscar el nombre del usuario en el diccionario
    #         # print(f"{record.uid}\t\t\t\t{user_name}\t\t\t\t{record.timestamp}")
    #         # attributes = vars(record) 
    #         # print("asistencia atributos", attributes)
    #         file.write(f"{record.uid}\t\t\t\t{user_name}\t\t\t\t{record.timestamp}\n")  # Escribir cada registro en el archivo

""" except Exception as e:
    print("Proceso terminado: {}".format(e))
finally:
    if conn:
        conn.disconnect() """



# **********************************************************************************

""" from zk import ZK, const
import datetime

conn = None
zk = ZK("192.168.170.216", port=4370, timeout=5)
try:
    print("Conexión al dispositivo ...")
    conn = zk.connect()
    print("Deshabilitando el dispositivo ...")
    conn.disable_device()
    print("Firmware Version: : {}".format(conn.get_firmware_version()))

    # Obtener registros de asistencia
    attendance_records = conn.get_attendance()
    
    # Calcular la fecha límite (una semana antes de hoy)
    today = datetime.datetime.now()
    one_week_ago = today - datetime.timedelta(days=7)

    # Eliminar registros más antiguos que una semana
    for record in attendance_records:
        if record.timestamp < one_week_ago:
            # Aquí se asume que hay una función delete_attendance(uid) o similar
            # Debes reemplazarlo con la función correcta según tu biblioteca
            print(f"Eliminando registro antiguo: UID {record.user_id}, Timestamp {record.timestamp}")
            conn.delete_attendance(record.uid)  # Cambia esto según la función correcta

except Exception as e:
    print("Proceso terminado: {}".format(e))
finally:
    if conn:
        conn.disconnect()
 """






# from zk import ZK, const
# import datetime

# conn = None
# zk = ZK("192.168.170.216", port=4370, timeout=5)
# try:
#     print("Conexión al dispositivo ...")
#     conn = zk.connect()
#     print("Deshabilitando el dispositivo ...")
#     conn.disable_device()
#     print("Firmware Version: : {}".format(conn.get_firmware_version()))

#     # Obtener registros de asistencia
#     attendance_records = conn.get_attendance()
    
#     # Calcular la fecha límite (una semana antes de hoy)
#     today = datetime.datetime.now()
#     one_week_ago = today - datetime.timedelta(days=7)

#     # Filtrar registros que se conservarán
#     records_to_keep = []
#     for record in attendance_records:
#         if record.timestamp >= one_week_ago:
#             records_to_keep.append(record)

#     # Limpiar todos los registros de asistencia
#     conn.clear_attendance()
    
#     # Reinsertar los registros que se desean conservar
#     for record in records_to_keep:
#         # Aquí asumo que hay un método para reintegrar los registros, esto depende de tu implementación.
#         # Si no hay un método específico, necesitarás guardar los datos relevantes en otro lugar o 
#         # gestionar la reintegración manualmente.
#         print(f"Reinsertando registro: UID {record.user_id}, Timestamp {record.timestamp}")
#         # Aquí deberías implementar la lógica para reintegrar el registro.

# except Exception as e:
#     print("Proceso terminado: {}".format(e))
# finally:
#     if conn:
#         conn.disconnect()



        

