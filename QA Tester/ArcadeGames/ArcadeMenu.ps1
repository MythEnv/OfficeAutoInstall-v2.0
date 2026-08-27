function Resize-Terminal {
    try {
        $ws = $Host.UI.RawUI.WindowSize; $bs = $Host.UI.RawUI.BufferSize; $changed = $false
        if ($ws.Width -lt 85) { $ws.Width = 85; $changed = $true }
        if ($ws.Height -lt 40) { $ws.Height = 40; $changed = $true }
        if ($changed) {
            if ($bs.Width -lt $ws.Width) { $bs.Width = $ws.Width }
            if ($bs.Height -lt $ws.Height) { $bs.Height = $ws.Height }
            $Host.UI.RawUI.BufferSize = $bs; $Host.UI.RawUI.WindowSize = $ws
        }
    } catch {}
}

function Show-ArcadeMenu {
    Resize-Terminal
    while ($true) {
        [Console]::Clear()
        Write-Host "========================================================" -ForegroundColor Yellow
        Write-Host "               CASINO VIRTUAL - MENÚ PRINCIPAL          " -ForegroundColor Yellow
        Write-Host "========================================================" -ForegroundColor Yellow
        Write-Host "1. Snake (Clásico de la serpiente)"
        Write-Host "2. American Blackjack (Tapete curvo y cartas 1 a 1)"
        Write-Host "3. Ruleta (Círculo Superior, Tapete Inferior y Marcado Real)"
        Write-Host "4. Volver al chat con Masi (Instalador)"
        Write-Host "========================================================"
        
        $op = Read-Host "Elige una opción (1-4)"
        switch ($op) {
            "1" { if (Get-Command Start-ConsoleSnake -ErrorAction SilentlyContinue) { Start-ConsoleSnake } }
            "2" { if (Get-Command Start-ConsoleBlackjack -ErrorAction SilentlyContinue) { Start-ConsoleBlackjack } }
            "3" { if (Get-Command Start-ConsoleRoulette -ErrorAction SilentlyContinue) { Start-ConsoleRoulette } }
            "4" { [Console]::Clear(); Write-Host "Saliendo... Volviendo al chat." -ForegroundColor Cyan; Start-Sleep -Seconds 1; return }
            default { Write-Host "Inválido o juego no instalado." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}