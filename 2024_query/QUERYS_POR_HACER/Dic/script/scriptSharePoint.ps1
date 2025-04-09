# Variables
$usuario = "programador@dreampackgroup.com"  # Cambia esto por tu correo
$contrasena = "***"                # Cambia esto por tu contraseña
$rutaOrigen = "C:\Users\ProgramadorJunior\Videos\prueba"  # Ruta local donde están los archivos
$folderDestino = "/personal/henry_mendoza_dreampackgroup_com/Documents/Backup Bases de Datos"  # Ruta en SharePoint/OneDrive

# Convertir la contraseña a un formato seguro
$securePassword = ConvertTo-SecureString $contrasena -AsPlainText -Force
$credenciales = New-Object System.Management.Automation.PSCredential($usuario, $securePassword)

# Conectar a OneDrive (SharePoint)
Connect-PnPOnline -Url "https://netorgft9246066-my.sharepoint.com" -Credentials $credenciales

# Obtener la fecha límite (hace 7 días)
$fechaLimite = (Get-Date).AddDays(-7)

# Subir archivos modificados en los últimos 7 días
Get-ChildItem -Path $rutaOrigen | Where-Object { $_.LastWriteTime -ge $fechaLimite } | ForEach-Object {
    Write-Host "Subiendo: $_.Name"
    try {
        # Subir el archivo a OneDrive
        Add-PnPFile -Path $_.FullName -Folder $folderDestino -OverwriteIfAlreadyExists
        Write-Host "Archivo subido: $_.Name"
    } catch {
        Write-Host "Error al subir: $_.Name"
        Write-Host $_.Exception.Message
    }
}

# Desconectar la sesión
Disconnect-PnPOnline
