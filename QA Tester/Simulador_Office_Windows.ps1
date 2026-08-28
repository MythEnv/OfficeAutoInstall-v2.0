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
#                    AUTO-CARGADOR HÍBRIDO (LOCAL / NUBE)
# ========================================================================

$JuegosDisponibles = $false
$EjecucionWeb = [string]::IsNullOrEmpty($PSScriptRoot)

Write-Host "`n[Sistema]: Iniciando rastreo de dependencias..." -ForegroundColor DarkGray

if ($EjecucionWeb) {
    Write-Host "[Sistema]: Ejecución en RAM detectada. Descargando módulos de GitHub..." -ForegroundColor Magenta
    
    # 1. Cargar MasiAI desde GitHub
    try {
        $iaRaw = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/WenliangK/OfficeAutoInstall/refs/heads/main/OAI/MASII/MasiAI.ps1"
        Invoke-Expression $iaRaw
        Write-Host "[Sistema]: Módulo IA [OK]" -ForegroundColor DarkGray
    } catch { Write-Host "[Error]: No se pudo conectar con la IA en la nube." -ForegroundColor Red }

    # 2. Cargar Arcade desde GitHub (Lista explícita)
    try {
        $listaJuegos = @("ArcadeMenu.ps1", "Snake.ps1", "Blackjack.ps1", "Ruleta.ps1", "SpaceInvaders.ps1", "Asteroids.ps1")
        $baseArcade = "https://raw.githubusercontent.com/WenliangK/OfficeAutoInstall/refs/heads/main/OAI/ArcadeGames/"
        
        foreach ($juego in $listaJuegos) {
            $juegoRaw = Invoke-RestMethod -Uri "$baseArcade$juego"
            Invoke-Expression $juegoRaw
        }
        
        if (Get-Command Show-ArcadeMenu -ErrorAction SilentlyContinue) {
            $JuegosDisponibles = $true
            Write-Host "[Sistema]: Módulo Arcade en la nube [OK]" -ForegroundColor DarkGray
        }
    } catch { 
        Write-Host "[Error]: Falló la inyección de los juegos desde la nube." -ForegroundColor Red 
    }

} else {
    Write-Host "[Sistema]: Ejecución local detectada. Buscando en carpetas físicas..." -ForegroundColor Magenta
    $RutaBase = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
    if (-not (Test-Path (Join-Path $RutaBase "ArcadeGames")) -and (Test-Path (Join-Path $RutaBase "QA Tester\ArcadeGames"))) {
        $RutaBase = Join-Path $RutaBase "QA Tester"
    }

    $ModuloIA = Join-Path -Path $RutaBase -ChildPath "MASII\MasiAI.ps1"
    if (Test-Path $ModuloIA) { . "$ModuloIA"; Write-Host "[Sistema]: Módulo IA Local [OK]" -ForegroundColor DarkGray }

    $CarpetaArcade = Join-Path -Path $RutaBase -ChildPath "ArcadeGames"
    if (Test-Path $CarpetaArcade) {
        $archivosJuegos = Get-ChildItem -Path $CarpetaArcade -Filter "*.ps1"
        foreach ($juego in $archivosJuegos) { . "$($juego.FullName)" }
        if (Get-Command Show-ArcadeMenu -ErrorAction SilentlyContinue) {
            $JuegosDisponibles = $true
            Write-Host "[Sistema]: Módulo Arcade Local [OK]" -ForegroundColor DarkGray
        }
    }
}
Write-Host ""
# ========================================================================
#                    FLUJO PRINCIPAL DE SIMULACIÓN
# ========================================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Iniciando Simulador de Office (Windows)" -ForegroundColor Cyan
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