$projectPath = "c:\Users\jacko\.gemini\antigravity\playground\galactic-voyager\vision_therapy_app"

Write-Host "Limpiando archivos de compilación en: $projectPath"

# Carpetas a eliminar
$folders = @(
    "build",
    ".dart_tool",
    ".flutter-plugins",
    ".flutter-plugins-dependencies",
    "android\.gradle",
    "ios\Flutter\Generated.xcconfig",
    "ios\Flutter\flutter_export_environment.sh"
)

foreach ($folder in $folders) {
    $fullPath = Join-Path $projectPath $folder
    if (Test-Path $fullPath) {
        Write-Host "Eliminando: $fullPath"
        Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Limpieza completada."
