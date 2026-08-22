if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Solicitando permisos de administrador..." -ForegroundColor Yellow
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
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

Write-Host "`nDescargando motor de instalacion..." -ForegroundColor White
Invoke-WebRequest -Uri $urlSetup -OutFile $localSetup

$installedOffice = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -match "Microsoft Office" -and $_.DisplayName -notmatch "Update" -and $_.DisplayName -notmatch "Click-to-Run" }

if ($installedOffice) {
    Write-Host "`n[!] ATENCION: Se detectaron las siguientes instalaciones previas:" -ForegroundColor Yellow
    $installedOffice | ForEach-Object { Write-Host "  - $($_.DisplayName)" -ForegroundColor Red }
    
    $respuesta = Read-Host "`n¿Deseas desinstalar esto completamente antes de continuar? (S/N)"
    
    if ($respuesta -match "^[sS]") {
        Write-Host "`nLimpiando instalaciones previas. Esto tomara unos minutos, espera..." -ForegroundColor Yellow
        $uninstallXml = "$tempDir\uninstall.xml"
        "<Configuration><Display Level=`"None`" AcceptEULA=`"TRUE`" /><Remove All=`"TRUE`" /></Configuration>" | Out-File -FilePath $uninstallXml -Encoding utf8
        
        Start-Process -FilePath $localSetup -ArgumentList "/configure `"$uninstallXml`"" -Wait -NoNewWindow
        Write-Host "Limpieza completada con exito." -ForegroundColor Green
    } else {
        Write-Host "Omitiendo desinstalacion..." -ForegroundColor Cyan
    }
} else {
    Write-Host "`nNo se detectaron instalaciones previas de Office. Todo limpio." -ForegroundColor Green
}

$urlConfig = "https://raw.githubusercontent.com/WenliangK/OfficeAutoInstall/main/configuration.xml"
$localConfig = "$tempDir\configuration.xml"

Write-Host "`nDescargando configuracion de instalacion..." -ForegroundColor White
Invoke-WebRequest -Uri $urlConfig -OutFile $localConfig

Write-Host @"

            (\_/)
         .-""-.-.-' a\
        /  \      _.--'
       (\  /_---\\_\_
        `'-.
         ,__)

MythEnv - Sh1romsi
       
 
"@ -ForegroundColor White


Write-Host "Iniciando el proceso pesado. Toma asiento...`n" -ForegroundColor Yellow


$proceso = Start-Process -FilePath $localSetup -ArgumentList "/configure `"$localConfig`"" -PassThru -NoNewWindow

$urlApi = "https://cold-rain-150a.wenliangk.workers.dev/"

Write-Host "`n[Instalador]: ¡Hey! Mientras descargo y acomodo todos estos archivos... ¿Qué tal va tu día?" -ForegroundColor Cyan

while (-not $proceso.HasExited) {
    $mensajeUsuario = Read-Host "`n[Tú]"
    
    if ($proceso.HasExited) { break }
    
    $bodyJson = @{ message = $mensajeUsuario } | ConvertTo-Json
    
    try {
        $respuesta = Invoke-RestMethod -Uri $urlApi -Method Post -Body $bodyJson -ContentType "application/json" -ErrorAction Stop
        
        Write-Host "`n[Instalador]: $($respuesta.reply)" -ForegroundColor Cyan
    } catch {
        Write-Host "`n[Instalador]: Buf, los discos están trabajando a tope ahora mismo..." -ForegroundColor Cyan
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

Write-Host "Activando Office de forma silenciosa, por favor espera..." -ForegroundColor Yellow

iex "& { $(irm https://get.activated.win) } /Ohook"

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "   ¡Gracias por confiar en nosotros!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Presiona cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")