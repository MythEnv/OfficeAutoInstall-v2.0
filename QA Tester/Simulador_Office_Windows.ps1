[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Mensaje de advertencia inicial estilo sysadmin
Clear-Host
Write-Host "==================================================================" -ForegroundColor Red
Write-Host "  [!] MODO DESARROLLADOR: SIMULADOR WINDOWS INICIADO..." -ForegroundColor Yellow
Write-Host "  [!] Este script NO instala Office, solo simula los tiempos y UI." -ForegroundColor Red
Write-Host "==================================================================" -ForegroundColor Red
Start-Sleep -Seconds 3

# Funcion para efecto de escritura tipo videojuego (RPG)
function Write-LoreText {
    param([string]$Text, [int]$Delay = 25, [ConsoleColor]$Color = "Yellow")
    foreach ($char in $Text.ToCharArray()) {
        Write-Host $char -NoNewline -ForegroundColor $Color
        Start-Sleep -Milliseconds $Delay
    }
    Write-Host ""
}

# ========================================================================
#                    AUTO-CARGADOR DE MÓDULOS CROSS-PLATFORM
# ========================================================================

$JuegosDisponibles = $false
$RutaBase = if ([string]::IsNullOrEmpty($PSScriptRoot)) { (Get-Location).Path } else { $PSScriptRoot }

# 1. Cargar la IA Masi
$ModuloIA = Join-Path -Path $RutaBase -ChildPath "MASII\MasiAI.ps1"
if (Test-Path $ModuloIA) { . $ModuloIA }

# 2. Cargar dinámicamente el Arcade
$CarpetaArcade = Join-Path -Path $RutaBase -ChildPath "ArcadeGames"
if (Test-Path $CarpetaArcade) {
    Get-ChildItem -Path $CarpetaArcade -Filter "*.ps1" | ForEach-Object { . $_.FullName }
    if (Get-Command Show-ArcadeMenu -ErrorAction SilentlyContinue) {
        $JuegosDisponibles = $true
    }
}

# ========================================================================
#                    FLUJO PRINCIPAL DE SIMULACIÓN
# ========================================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Iniciando Simulador de Office (Windows)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-LoreText "Conectando con los servidores para descargar el motor de instalacion..." 25 "White"
Start-Sleep -Seconds 1
Write-LoreText "Motor descargado con exito. El corazon de la suite ya esta en casa." 25 "Green"

Write-Host ""
Write-LoreText "Escaneo completado: No hay rastros de versiones anteriores de Office." 30 "Green"
Write-LoreText "Excelente, hiciste un trabajo impecable manteniendo todo limpio. Zona despejada." 30 "Cyan"

Write-LoreText "Descargando configuracion de instalacion..." 25 "White"
Start-Sleep -Seconds 1

Write-Host @"
  ___  _____ _____ ___ ____ _____ 
 / _ \|  ___|  ___|_ _/ ___| ____|
| | | | |_  | |_   | | |   |  _|  
| |_| |  _| |  _|  | | |___| |___ 
 \___/|_|   |_|   |___\____|_____|
                                 (\_/)
                         .-""-.-.-' a\
                         /  \      _.--'
                        (\  /_---\_\_
                         `'-.
                          ,__)

        MythEnv - Sh1romsi
"@ -ForegroundColor White

Write-Host "Iniciando el proceso pesado. Toma asiento y trae un café...`n" -ForegroundColor Yellow

# Simulamos la instalación en Windows abriendo un proceso hijo invisible
$proceso = Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -Command `"Start-Sleep -Seconds 240`"" -PassThru
$urlApi = "https://cold-rain-150a.wenliangk.workers.dev"

Write-Host "`n[Instalador]: Hola, Soy Masi tu asistente IA e instalador, por el momento solo robare tus credenciales y te instalare un malware... jajaj es broma, solo instalare tu office, como va tu dia?" -ForegroundColor Cyan
Write-Host "*(Elige tu camino: escribe 'masi' para charlar conmigo o 'juegos' para abrir la feria de minijuegos)*" -ForegroundColor DarkGray

while (-not $proceso.HasExited) {
    $mensajeUsuario = Read-Host "`n[Tu]"
    if ($proceso.HasExited) { break }
    
    if ($mensajeUsuario -match "^(juegos|arcade|snake)$") {
        if ($JuegosDisponibles) {
            Show-ArcadeMenu
            Write-Host "`n[Instalador]: ¡De vuelta al chat! (La instalación sigue en segundo plano, pulsa Enter para actualizar estado o sigue hablando)." -ForegroundColor Cyan
        } else {
            Write-Host "`n[Instalador]: Ups, parece que no cargaste la subcarpeta 'ArcadeGames'. ¡Pero Masi sigue aquí!" -ForegroundColor Yellow
        }
        continue
    }

    if (Get-Command Invoke-MasiChat -ErrorAction SilentlyContinue) {
        Invoke-MasiChat -Mensaje $mensajeUsuario -UrlApi $urlApi
    } else {
        Write-Host "`n[Instalador (Offline)]: Módulo de IA no detectado en 'MASII'. Simulando instalación en silencio..." -ForegroundColor DarkGray
    }
    
    Start-Sleep -Seconds 1
}

# ========================================================================
#                    TRANSICIÓN Y SIMULACIÓN DE ACTIVACIÓN
# ========================================================================

Clear-Host
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "             ¡INSTALACIÓN DE OFFICE 100% COMPLETADA!              " -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "`n[Instalador]: Disculpa la interrupción, ya se horneó el pan." -ForegroundColor Yellow
Write-Host "`nLimpiando archivos temporales simulados..." -ForegroundColor White
Start-Sleep -Seconds 1

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "   Ejecutando configuracion final..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host "`n[!] ATENCION: Instalación completa, continuaré con la activación." -ForegroundColor Yellow
Write-Host "Ejecutando activación Ohook en 3 segundos..." -ForegroundColor Cyan
Start-Sleep -Seconds 1; Write-Host "2..." -ForegroundColor Yellow
Start-Sleep -Seconds 1; Write-Host "1..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

Write-Host "Activando Office de forma silenciosa, por favor espera..." -ForegroundColor Yellow
Start-Sleep -Seconds 3 
Write-Host "[SIMULACION]: Office activado exitosamente con Ohook (Licencia Permanente)." -ForegroundColor Green

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "   ¡Proceso de prueba finalizado! Todo funciona perfecto." -ForegroundColor Green
Write-Host "          by MythEnv & https://github.com/WenliangK" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")