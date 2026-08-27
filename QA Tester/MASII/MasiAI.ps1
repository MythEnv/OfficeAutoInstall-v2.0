function Invoke-MasiChat {
    param([string]$Mensaje, [string]$UrlApi)
    
    $bodyJson = @{ message = $Mensaje } | ConvertTo-Json
    try {
        Write-Host "   (Pensando...)" -ForegroundColor Gray -NoNewline
        $respuesta = Invoke-RestMethod -Uri $UrlApi -Method Post -Body $bodyJson -ContentType "application/json; charset=utf-8" -ErrorAction Stop
        Write-Host "`r`n[Instalador]: $($respuesta.reply)" -ForegroundColor Cyan
    } catch {
        Write-Host "`r`n[Instalador]: Buf, los discos estan trabajando a tope ahora mismo..." -ForegroundColor Cyan
    }
}