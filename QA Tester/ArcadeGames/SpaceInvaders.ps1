function Start-ConsoleSpaceInvaders {
    [Console]::Clear()
    $width = 50; $height = 20
    $playerX = [math]::Floor($width / 2)
    $bullets = @()
    $enemies = @()
    $score = 0; $speed = 50; $tick = 0
    $enemyDir = 1; $enemyStepDown = $false

    # Generar enjambre alienígena
    for ($y = 2; $y -le 5; $y += 2) {
        for ($x = 5; $x -le 35; $x += 4) {
            $enemies += [PSCustomObject]@{X=$x; Y=$y; Alive=$true}
        }
    }

    while ($true) {
        # --- INPUTS ---
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            switch ($key.Key) {
                "LeftArrow"  { if ($playerX -gt 1) { $playerX-- } }
                "RightArrow" { if ($playerX -lt ($width - 2)) { $playerX++ } }
                "Spacebar"   { $bullets += [PSCustomObject]@{X=$playerX; Y=($height - 2)} }
                "Escape"     { [Console]::Clear(); Write-Host "`nSaliendo de Space Invaders..." -ForegroundColor Yellow; Start-Sleep -Seconds 1; return }
            }
        }

        # --- LÓGICA DE BALAS ---
        $newBullets = @()
        foreach ($b in $bullets) {
            $b.Y--
            $hit = $false
            foreach ($e in $enemies) {
                if ($e.Alive -and $e.X -eq $b.X -and $e.Y -eq $b.Y) {
                    $e.Alive = $false; $hit = $true; $score += 10; break
                }
            }
            if (-not $hit -and $b.Y -gt 0) { $newBullets += $b }
        }
        $bullets = $newBullets

        # --- LÓGICA DE ENEMIGOS ---
        $tick++
        if ($tick -ge 5) {
            $tick = 0
            $moveDownNow = $false
            if ($enemyStepDown) {
                foreach ($e in $enemies) { if ($e.Alive) { $e.Y++ } }
                $enemyStepDown = $false
                $enemyDir *= -1
            } else {
                foreach ($e in $enemies) {
                    if ($e.Alive) {
                        $e.X += $enemyDir
                        if ($e.X -le 1 -or $e.X -ge ($width - 2)) { $moveDownNow = $true }
                    }
                }
                if ($moveDownNow) { $enemyStepDown = $true }
            }
        }

        # --- CONDICIONES DE VICTORIA / DERROTA ---
        $aliveCount = ($enemies | Where-Object { $_.Alive }).Count
        $gameOver = $false
        foreach ($e in $enemies) { if ($e.Alive -and $e.Y -ge ($height - 2)) { $gameOver = $true; break } }

        if ($gameOver -or $aliveCount -eq 0) {
            [Console]::Clear()
            Write-Host "========================================" -ForegroundColor Magenta
            if ($gameOver) { Write-Host "   LA TIERRA HA SIDO INVADIDA... " -ForegroundColor Red }
            else { Write-Host "   ¡HAS SALVADO LA GALAXIA! " -ForegroundColor Green }
            Write-Host "   Puntaje final: $score" -ForegroundColor Yellow
            Write-Host "========================================" -ForegroundColor Magenta
            Read-Host "Presiona Enter para volver al menú..."
            return
        }

        # --- RENDERIZADO ---
        $output = "Puntaje: $score | Flechas: Mover | Espacio: Disparar | ESC: Salir`n"
        for ($y = 0; $y -lt $height; $y++) {
            $line = ""
            for ($x = 0; $x -lt $width; $x++) {
                if ($y -eq 0 -or $y -eq ($height - 1)) { $line += "=" }
                elseif ($x -eq 0 -or $x -eq ($width - 1)) { $line += "|" }
                elseif ($y -eq ($height - 2) -and $x -eq $playerX) { $line += "A" } # Jugador
                else {
                    $drawn = $false
                    foreach ($e in $enemies) { if ($e.Alive -and $e.X -eq $x -and $e.Y -eq $y) { $line += "W"; $drawn = $true; break } }
                    if (-not $drawn) {
                        foreach ($b in $bullets) { if ($b.X -eq $x -and $b.Y -eq $y) { $line += "|"; $drawn = $true; break } }
                    }
                    if (-not $drawn) { $line += " " }
                }
            }
            $output += $line + "`n"
        }
        [Console]::SetCursorPosition(0, 0); [Console]::Write($output)
        Start-Sleep -Milliseconds $speed
    }
}