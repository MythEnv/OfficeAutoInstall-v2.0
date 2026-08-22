
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Solicitando permisos de administrador..." -ForegroundColor Yellow
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Iniciando la instalacion automatizada de Office..." -ForegroundColor Cyan

$tempDir = "C:\TempOfficeInstall"
if (!(Test-Path -Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

$urlSetup = "https://raw.githubusercontent.com/WenliangK/OfficeAutoInstall/main/setup.exe"
$urlConfig = "https://raw.githubusercontent.com/WenliangK/OfficeAutoInstall/main/configuration.xml"

$localSetup = "$tempDir\setup.exe"
$localConfig = "$tempDir\configuration.xml"

Write-Host "Descargando archivos desde GitHub..." -ForegroundColor White
Invoke-WebRequest -Uri $urlSetup -OutFile $localSetup
Invoke-WebRequest -Uri $urlConfig -OutFile $localConfig

Write-Host "Instalando Office. Esto puede tardar unos minutos, por favor espera..." -ForegroundColor Yellow
Start-Process -FilePath $localSetup -ArgumentList "/configure `"$localConfig`"" -Wait -NoNewWindow

Write-Host "Limpiando archivos temporales..." -ForegroundColor White
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "¡Instalacion completada con exito!" -ForegroundColor Green
Write-Host "Presiona cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")