function Start-ConsoleRoulette {
    $rojos = @(1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36)
    $rueda = @(0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26)

    function Draw-Tapete($Destacado = -1) {
        $r1 = @(3,6,9,12,15,18,21,24,27,30,33,36)
        $r2 = @(2,5,8,11,14,17,20,23,26,29,32,35)
        $r3 = @(1,4,7,10,13,16,19,22,25,28,31,34)

        function P($n) {
            $s = $n.ToString().PadLeft(2, ' ')
            if ($n -eq $Destacado) { Write-Host " $s " -NoNewline -ForegroundColor Black -BackgroundColor Yellow } 
            else {
                if ($rojos -contains $n) { Write-Host " $s " -NoNewline -ForegroundColor White -BackgroundColor Red } 
                else { Write-Host " $s " -NoNewline -ForegroundColor White -BackgroundColor Black }
            }
        }

        Write-Host "      +---+----+----+----+----+----+----+----+----+----+----+----+----+-------+" -ForegroundColor DarkGreen
        Write-Host "      |   |" -NoNewline -ForegroundColor DarkGreen
        foreach($n in $r1) { P $n; Write-Host "|" -NoNewline -ForegroundColor DarkGreen }
        Write-Host " 2to1  |" -ForegroundColor White

        Write-Host "      |   +----+----+----+----+----+----+----+----+----+----+----+----+-------+" -ForegroundColor DarkGreen
        Write-Host "      | " -NoNewline -ForegroundColor DarkGreen
        if ($Destacado -eq 0) { Write-Host "0" -NoNewline -ForegroundColor Black -BackgroundColor Yellow }
        else { Write-Host "0" -NoNewline -ForegroundColor White -BackgroundColor DarkGreen }
        Write-Host " |" -NoNewline -ForegroundColor DarkGreen
        foreach($n in $r2) { P $n; Write-Host "|" -NoNewline -ForegroundColor DarkGreen }
        Write-Host " 2to1  |" -ForegroundColor White

        Write-Host "      |   +----+----+----+----+----+----+----+----+----+----+----+----+-------+" -ForegroundColor DarkGreen
        Write-Host "      |   |" -NoNewline -ForegroundColor DarkGreen
        foreach($n in $r3) { P $n; Write-Host "|" -NoNewline -ForegroundColor DarkGreen }
        Write-Host " 2to1  |" -ForegroundColor White
        
        Write-Host "      +---+----+----+----+----+----+----+----+----+----+----+----+----+-------+" -ForegroundColor DarkGreen
        Write-Host "          |       1st 12      |       2nd 12      |       3rd 12      |" -ForegroundColor White
        Write-Host "          +---------+---------+---------+---------+---------+---------+" -ForegroundColor DarkGreen
        Write-Host "          | 1 to 18 |  EVEN   | " -NoNewline -ForegroundColor White
        Write-Host " RED " -NoNewline -ForegroundColor Red
        Write-Host " | " -NoNewline -ForegroundColor DarkGreen
        Write-Host "BLACK" -NoNewline -ForegroundColor DarkGray
        Write-Host " |   ODD   | 19 to 36|" -ForegroundColor White
        Write-Host "          +---------+---------+---------+---------+---------+---------+" -ForegroundColor DarkGreen -NoNewline
    }

    while ($true) {
        [Console]::Clear()
        Write-Host "==========================================================================" -ForegroundColor Magenta
        Write-Host "                      RULETA EUROPEA - APUESTAS                           " -ForegroundColor Magenta
        Write-Host "==========================================================================`n" -ForegroundColor Magenta
        Write-Host "Opciones de Apuesta:" -ForegroundColor Yellow
        Write-Host "1. Color (rojo/negro)           - Paga 1 a 1" -ForegroundColor White
        Write-Host "2. Par/Impar                    - Paga 1 a 1" -ForegroundColor White
        Write-Host "3. Docena (1-12, 13-24, 25-36)  - Paga 2 a 1" -ForegroundColor White
        Write-Host "4. Pleno (Ej: '23', 'Rojo 5')   - Paga 35 a 1`n" -ForegroundColor White
        
        $tipo = Read-Host "Selecciona opción de apuesta (1-4)"
        $apuestaUsuario = $null; $apuestaTexto = ""

        if ($tipo -eq "1") { $apuestaUsuario = Read-Host "Elige color (rojo / negro)"; $apuestaTexto = "COLOR $($apuestaUsuario.ToUpper())" }
        elseif ($tipo -eq "2") { $apuestaUsuario = Read-Host "Elige paridad (par / impar)"; $apuestaTexto = "PARIDAD $($apuestaUsuario.ToUpper())" }
        elseif ($tipo -eq "3") { $apuestaUsuario = [int](Read-Host "Elige número de docena (1, 2 o 3)"); $apuestaTexto = "DOCENA N° $apuestaUsuario" }
        elseif ($tipo -eq "4") { 
            $str = Read-Host "Ingresa tu apuesta (Ej: Rojo 11, Negro 23)"
            if ($str -match '\d+') {
                $apuestaUsuario = [int]$matches[0]
                if ($apuestaUsuario -lt 0 -or $apuestaUsuario -gt 36) { Write-Host "Inválido (0 al 36)." -ForegroundColor Red; Start-Sleep -Seconds 2; continue }
                $apuestaTexto = "PLENO AL NÚMERO $apuestaUsuario"
            } else { Write-Host "Formato inválido." -ForegroundColor Red; Start-Sleep -Seconds 1; continue }
        } else { continue }

        [Console]::Clear()
        Write-Host "==========================================================================" -ForegroundColor Magenta
        Write-Host "                   APUESTA CONFIRMADA: $apuestaTexto" -ForegroundColor Yellow
        Write-Host "                        ¡NO VA MÁS! LA BOLA GIRA...                       " -ForegroundColor Magenta
        Write-Host "==========================================================================" -ForegroundColor Magenta
        
        $coords = @{}
        for ($i=0; $i -lt 37; $i++) {
            $angle = $i * (2 * [math]::PI / 37) - ([math]::PI / 2)
            $x = 38 + [math]::Round(32 * [math]::Cos($angle)); $y = 12 + [math]::Round(7 * [math]::Sin($angle))
            $bx = 38 + [math]::Round(26 * [math]::Cos($angle)); $by = 12 + [math]::Round(5 * [math]::Sin($angle))
            $coords[$i] = @{ NumX = $x; NumY = $y; BallX = $bx; BallY = $by }
            $n = $rueda[$i]
            $col = if ($n -eq 0) { "Green" } elseif ($rojos -contains $n) { "Red" } else { "White" }
            try { [Console]::SetCursorPosition($x, $y); Write-Host $n.ToString().PadLeft(2, ' ') -ForegroundColor $col -NoNewline } catch {}
        }
        try {
            [Console]::SetCursorPosition(35, 10); Write-Host " .---. " -ForegroundColor DarkYellow -NoNewline
            [Console]::SetCursorPosition(35, 11); Write-Host "/  +  \" -ForegroundColor DarkYellow -NoNewline
            [Console]::SetCursorPosition(35, 12); Write-Host "|  O  |" -ForegroundColor Yellow -NoNewline
            [Console]::SetCursorPosition(35, 13); Write-Host "\  +  /" -ForegroundColor DarkYellow -NoNewline
            [Console]::SetCursorPosition(35, 14); Write-Host " '---' " -ForegroundColor DarkYellow -NoNewline
        } catch {}

        try { [Console]::SetCursorPosition(0, 21) } catch {}
        Draw-Tapete -1 

        $posicion = Get-Random -Minimum 0 -Maximum $rueda.Count
        $vueltasRapidas = 37 * 3 
        $vueltasFrenado = Get-Random -Minimum 20 -Maximum 40
        $vueltasTotales = $vueltasRapidas + $vueltasFrenado
        $velocidad = 15.0; $prevPos = -1

        for ($v = 0; $v -lt $vueltasTotales; $v++) {
            $posicion = ($posicion + 1) % $rueda.Count
            try {
                if ($prevPos -ge 0) { [Console]::SetCursorPosition($coords[$prevPos].BallX, $coords[$prevPos].BallY); Write-Host "  " -NoNewline }
                [Console]::SetCursorPosition($coords[$posicion].BallX, $coords[$posicion].BallY); Write-Host "O " -ForegroundColor Yellow -NoNewline
                [Console]::SetCursorPosition(0, 21); Draw-Tapete $rueda[$posicion]
            } catch {}
            $prevPos = $posicion

            if ($v -lt $vueltasRapidas) { $delayFinal = 15 } 
            else { $velocidad = $velocidad * 1.13; $delayFinal = [int][math]::Min([math]::Round($velocidad), 1200) }
            Start-Sleep -Milliseconds $delayFinal
        }

        $res = $rueda[$posicion]
        try { [Console]::SetCursorPosition(0, 31) } catch { Write-Host "`n" }
        Write-Host "`n[Crupier]: La bola ha caído..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2

        $colRes = if ($res -eq 0) { "Verde" } elseif ($rojos -contains $res) { "Rojo" } else { "Negro" }
        $printColor = if ($res -eq 0) { "Green" } elseif ($rojos -contains $res) { "Red" } else { "White" }

        Write-Host "==========================================================================" -ForegroundColor Yellow
        Write-Host "                      ¡NÚMERO GANADOR: [$res] ($colRes)!                  " -ForegroundColor $printColor
        Write-Host "==========================================================================" -ForegroundColor Yellow

        $acerto = $false
        if ($tipo -eq "1" -and $apuestaUsuario.ToLower() -eq $colRes.ToLower()) { $acerto = $true }
        elseif ($tipo -eq "2" -and $res -ne 0 -and ($res % 2 -eq 0) -eq ($apuestaUsuario.ToLower() -eq "par")) { $acerto = $true }
        elseif ($tipo -eq "3" -and (($apuestaUsuario -eq 1 -and $res -ge 1 -and $res -le 12) -or ($apuestaUsuario -eq 2 -and $res -ge 13 -and $res -le 24) -or ($apuestaUsuario -eq 3 -and $res -ge 25 -and $res -le 36))) { $acerto = $true }
        elseif ($tipo -eq "4" -and $apuestaUsuario -eq $res) { $acerto = $true }

        if ($acerto) { Write-Host " ¡APUESTA GANADA! ¡Felicidades, cobras en caja!" -ForegroundColor Green } 
        else { Write-Host " ¡Perdiste la apuesta! Suerte en la próxima." -ForegroundColor Red }

        Write-Host ""
        $repetir = Read-Host "¿Otra tirada de ruleta? (s/n)"
        if ($repetir -ne 's') { break }
    }
}