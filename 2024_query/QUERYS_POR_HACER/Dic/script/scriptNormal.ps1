# Variables
$rutaOrigen = "C:\Users\ProgramadorJunior\Videos\prueba"  # Ruta local donde están los archivos
$rutaDestino = "C:\Users\ProgramadorJunior\OneDrive - dreampackgroup.com\prueba_backup"  # Ruta local sincronizada de OneDrive

# Obtener la fecha límite (hace 7 días)
$fechaLimite = (Get-Date).AddDays(-7)

# Subir archivos modificados en los últimos 7 días
Get-ChildItem -Path $rutaOrigen | Where-Object { $_.LastWriteTime -ge $fechaLimite } | ForEach-Object {
    Write-Host "Subiendo: $_.Name"
    try {
        Copy-Item -Path $_.FullName -Destination $rutaDestino -Force
        Write-Host "Archivo subido: $_.Name"
    } catch {
        Write-Host "Error al subir: $_.Name"
        Write-Host $_.Exception.Message
    }
}