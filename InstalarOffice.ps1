[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Solicitando permisos de administrador..." -ForegroundColor Yellow
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Write-LoreText {
    param([string]$Text, [int]$Delay = 25, [ConsoleColor]$Color = "Yellow")
    foreach ($char in $Text.ToCharArray()) {
        Write-Host $char -NoNewline -ForegroundColor $Color
        Start-Sleep -Milliseconds $Delay
    }
    Write-Host ""
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Iniciando Instalador de Office" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$tempDir = "C:\TempOfficeInstall"
if (!(Test-Path -Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

$urlSetup = "https://raw.githubusercontent.com/WenliangK/OfficeAutoInstall/main/setup.exe"
$localSetup = "$tempDir\setup.exe"

Write-LoreText "Conectando con los servidores para descargar el motor de instalacion..." 25 "White"
Invoke-WebRequest -Uri $urlSetup -OutFile $localSetup
Write-LoreText "Motor descargado con exito. El corazon de la suite ya esta en casa." 25 "Green"

$installedOffice = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -match "Microsoft Office" -and $_.DisplayName -notmatch "Update" -and $_.DisplayName -notmatch "Click-to-Run" }

if ($installedOffice) {
    Write-Host "`n[!] ATENCION: Se detectaron las siguientes instalaciones previas:" -ForegroundColor Yellow
    $installedOffice | ForEach-Object { Write-Host "  - $($_.DisplayName)" -ForegroundColor Red }
    
    $respuesta = Read-Host "`n¿Deseas desinstalar esto completamente antes de continuar (Tienes que hacerlo para poder continuar)? (S/N)"
    
    if ($respuesta -match "^[sS]") {
        Write-Host ""
        Write-LoreText "Detectando basura en el sistema... Esto pasa por dejar restos de instalaciones antiguas de Office por todos lados." 30 "Yellow"
        Write-LoreText "La razon por la que construi esto? Fue para automatizar este dolor de cabeza y no tener que perder horas haciendo clic en 'Siguiente' cada vez que formateas una PC." 30 "Cyan"
        Write-LoreText "Iniciando purga profunda del sistema... Tomate un respiro, esto tomara unos minutos." 30 "Yellow"

        $uninstallXml = "$tempDir\uninstall.xml"
        "<Configuration><Display Level=`"None`" AcceptEULA=`"TRUE`" /><Remove All=`"TRUE`" /></Configuration>" | Out-File -FilePath $uninstallXml -Encoding utf8
        
        Start-Process -FilePath $localSetup -ArgumentList "/configure `"$uninstallXml`"" -Wait -NoNewWindow
        
        Write-Host ""
        Write-LoreText "Purga completada. El sistema esta totalmente despejado." 30 "Green"
    } else {
        Write-Host "Omitiendo desinstalacion..." -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-LoreText "Escaneo completado: No hay rastros de versiones anteriores de Office." 30 "Green"
    Write-LoreText "Excelente, hiciste un trabajo impecable manteniendo todo limpio. Zona despejada." 30 "Cyan"
    Write-LoreText "Bueno, aqui vamos con todo. Preparando el arsenal para el despliegue..." 40 "Yellow"
}

$urlConfig = "https://raw.githubusercontent.com/WenliangK/OfficeAutoInstall/main/configuration.xml"
$localConfig = "$tempDir\configuration.xml"

Write-LoreText "Descargando configuracion de instalacion..." 25 "White"
Invoke-WebRequest -Uri $urlConfig -OutFile $localConfig

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

$proceso = Start-Process -FilePath $localSetup -ArgumentList "/configure `"$localConfig`"" -PassThru -NoNewWindow

$urlApi = "https://cold-rain-150a.wenliangk.workers.dev"

Write-Host "`n[Instalador]: Hola, Soy Masi tu asistente IA e instalador, por el momento solo robare tus credenciales y te instalare un malware... jajaj es broma, solo instalare tu office, como va tu dia?" -ForegroundColor Cyan

while (-not $proceso.HasExited) {
    $mensajeUsuario = Read-Host "`n[Tu]"
    
    if ($proceso.HasExited) { break }
    
    $bodyJson = @{ message = $mensajeUsuario } | ConvertTo-Json
    
    try {
        Write-Host "   (Pensando...)" -ForegroundColor Gray -NoNewline
        
        $webResponse = Invoke-WebRequest -Uri $urlApi -Method Post -Body $bodyJson -ContentType "application/json; charset=utf-8" -ErrorAction Stop
        $utf8Text = [System.Text.Encoding]::UTF8.GetString($webResponse.Content)
        $jsonRespuesta = $utf8Text | ConvertFrom-Json
        
        Write-Host "`r`n[Instalador]: $($jsonRespuesta.reply)" -ForegroundColor Cyan
    } catch {
        Write-Host "`r`n[Instalador]: Buf, los discos estan trabajando a tope ahora mismo..." -ForegroundColor Cyan
    }
    
    Start-Sleep -Seconds 1
}

Write-Host "`n[Instalador]: Disculpa, ya se horneo el pan." -ForegroundColor Yellow
Write-Host "`n"

Write-Host "`n¡Instalacion de Office terminada con exito!" -ForegroundColor Green

Write-Host "`nLimpiando archivos temporales..." -ForegroundColor White
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "   Ejecutando configuracion final..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host "`n[!] ATENCION: No te asustes por lo que vas a ver en pantalla..." -ForegroundColor Yellow
Write-Host "[!] Esto es parte del proceso... ¡Y TIENES QUE LEER EL README SI TENIAS DUDAS!" -ForegroundColor Red
Write-Host "Ejecutando en 3 segundos..." -ForegroundColor Cyan
Start-Sleep -Seconds 1
Write-Host "2..." -ForegroundColor Yellow
Start-Sleep -Seconds 1
Write-Host "1..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

Write-Host "Activando Office de forma silenciosa, por favor espera..." -ForegroundColor Yellow

iex "& { $(irm https://get.activated.win) } /Ohook"

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "   ¡Gracias por confiar en nosotros!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Presiona cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")