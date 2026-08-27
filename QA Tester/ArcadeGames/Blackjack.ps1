function Start-ConsoleBlackjack {
    $palos = @("♠", "♥", "♦", "♣")
    $valores = @("2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A")

    function Obtener-Puntaje($mano) {
        $total = 0; $ases = 0
        foreach ($carta in $mano) {
            if ($carta -eq $null) { continue }
            switch ($carta.Valor) {
                "J" { $total += 10 }; "Q" { $total += 10 }; "K" { $total += 10 }; "A" { $total += 11; $ases++ }
                default { $total += [int]$carta.Valor }
            }
        }
        while ($total -gt 21 -and $ases -gt 0) { $total -= 10; $ases-- }
        return $total
    }

    function Obtener-LineaCarta($carta, $linea, $reverso) {
        if ($reverso) {
            switch ($linea) {
                0 { return ".---------." }; 1 { return "| * ~ * ~ |" }; 2 { return "| ~ CAS ~ |" }; 3 { return "| * INO * |" }; 4 { return "| ~ * ~ * |" }; 5 { return "| * ~ * ~ |" }; 6 { return "'---------'" }
            }
        } else {
            $v1 = $carta.Valor.PadRight(2, ' '); $v2 = $carta.Valor.PadLeft(2, ' '); $p = $carta.Palo
            switch ($linea) {
                0 { return ".---------." }; 1 { return "| $v1      |" }; 2 { return "|         |" }; 3 { return "|    $p    |" }; 4 { return "|         |" }; 5 { return "|      $v2 |" }; 6 { return "'---------'" }
            }
        }
    }

    function Imprimir-CartasCentradas($cartas, $ocultarUltima) {
        if ($cartas.Count -eq 0) { Write-Host "`n`n`n`n`n`n`n"; return }
        $anchoTotal = ($cartas.Count * 11) + ($cartas.Count - 1)
        $padding = " " * [math]::Max(0, (33 - ($anchoTotal / 2)))
        for ($lineIdx = 0; $lineIdx -lt 7; $lineIdx++) {
            Write-Host $padding -NoNewline
            for ($cIdx = 0; $cIdx -lt $cartas.Count; $cIdx++) {
                $c = $cartas[$cIdx]
                $reverso = ($ocultarUltima -and $cIdx -eq ($cartas.Count - 1))
                $col = if ($reverso) { "DarkCyan" } elseif ($c.Palo -match "[♥♦]") { "Red" } else { "White" }
                $lineTxt = Obtener-LineaCarta $c $lineIdx $reverso
                Write-Host "$lineTxt " -NoNewline -ForegroundColor $col
            }
            Write-Host ""
        }
    }

    function Mostrar-MesaCompleta($CartasJug, $CartasCas, $OcultarCas) {
        [Console]::Clear()
        Write-Host "=====================================================================" -ForegroundColor DarkGreen
        Write-Host "                AMERICAN BLACKJACK - PAYS 3 TO 2                     " -ForegroundColor Cyan
        Write-Host "=====================================================================" -ForegroundColor DarkGreen
        Write-Host "      .-------------------------------------------------------.      " -ForegroundColor DarkGreen
        Write-Host "     /                                                         \     " -ForegroundColor DarkGreen
        Write-Host "    /       Dealer must draw to 16, and stand on all 17s        \    " -ForegroundColor DarkGreen
        Write-Host "`n                              [ LA CASA ]" -ForegroundColor Yellow
        Imprimir-CartasCentradas $CartasCas $OcultarCas
        $pj = Obtener-Puntaje $CartasJug
        Write-Host "`n                              [ TU MANO ] (Total: $pj)" -ForegroundColor Green
        Imprimir-CartasCentradas $CartasJug $false
        Write-Host ""
    }

    while ($true) {
        $manoJugador = @(); $manoCasa = @()
        Mostrar-MesaCompleta $manoJugador $manoCasa $true
        Write-Host "[Crupier]: Repartiendo..." -ForegroundColor DarkGray
        Start-Sleep -Seconds 1

        $manoJugador += [PSCustomObject]@{ Valor = Get-Random $valores; Palo = Get-Random $palos }
        Mostrar-MesaCompleta $manoJugador $manoCasa $true; Start-Sleep -Milliseconds 700
        $manoCasa += [PSCustomObject]@{ Valor = Get-Random $valores; Palo = Get-Random $palos }
        Mostrar-MesaCompleta $manoJugador $manoCasa $true; Start-Sleep -Milliseconds 700
        $manoJugador += [PSCustomObject]@{ Valor = Get-Random $valores; Palo = Get-Random $palos }
        Mostrar-MesaCompleta $manoJugador $manoCasa $true; Start-Sleep -Milliseconds 700
        $manoCasa += [PSCustomObject]@{ Valor = Get-Random $valores; Palo = Get-Random $palos }
        Mostrar-MesaCompleta $manoJugador $manoCasa $true
        
        $totalJugador = Obtener-Puntaje $manoJugador

        while ($totalJugador -lt 21) {
            $accion = Read-Host "¿Pedir carta [p] o Plantarse [s]? (p/s)"
            if ($accion -eq 'p') {
                $manoJugador += [PSCustomObject]@{ Valor = Get-Random $valores; Palo = Get-Random $palos }
                Mostrar-MesaCompleta $manoJugador $manoCasa $true
                $totalJugador = Obtener-Puntaje $manoJugador
                if ($totalJugador -gt 21) { Write-Host "`n¡Te pasaste de 21! Has reventado." -ForegroundColor Red; break }
            } else { break }
        }

        if ($totalJugador -le 21) {
            Write-Host "`n[Crupier]: Te plantas. Revelando carta de la casa..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            Mostrar-MesaCompleta $manoJugador $manoCasa $false
            $totalCasa = Obtener-Puntaje $manoCasa

            while ($totalCasa -lt 17) {
                Start-Sleep -Seconds 1; Write-Host "[Crupier]: La casa pide carta..." -ForegroundColor Yellow; Start-Sleep -Seconds 1
                $manoCasa += [PSCustomObject]@{ Valor = Get-Random $valores; Palo = Get-Random $palos }
                Mostrar-MesaCompleta $manoJugador $manoCasa $false
                $totalCasa = Obtener-Puntaje $manoCasa
            }
            Write-Host ""
            if ($totalCasa -gt 21) { Write-Host "¡La casa revienta con $totalCasa! ¡GANASTE!" -ForegroundColor Green }
            elseif ($totalJugador -gt $totalCasa) { Write-Host "¡Felicidades! Ganas $totalJugador a $totalCasa." -ForegroundColor Green }
            elseif ($totalJugador -eq $totalCasa) { Write-Host "Empate ($totalJugador a $totalCasa). Recuperas apuesta." -ForegroundColor Yellow }
            else { Write-Host "La casa gana $totalCasa a $totalJugador. ¡Perdiste!" -ForegroundColor Red }
        }
        $repetir = Read-Host "`n¿Jugar otra mano? (s/n)"
        if ($repetir -ne 's') { break }
    }
}