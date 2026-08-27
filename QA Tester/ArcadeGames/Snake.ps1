function Start-ConsoleSnake {
    [Console]::Clear()
    $width = 30; $height = 15
    $snake = @(,[PSCustomObject]@{X=10;Y=5}, [PSCustomObject]@{X=9;Y=5}, [PSCustomObject]@{X=8;Y=5})
    $dir = "RIGHT"
    $food = [PSCustomObject]@{X = Get-Random -Minimum 1 -Maximum ($width - 1); Y = Get-Random -Minimum 1 -Maximum ($height - 1)}
    $score = 0; $speed = 100

    while ($true) {
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            switch ($key.Key) {
                "LeftArrow"  { if ($dir -ne "RIGHT") { $dir = "LEFT" } }
                "RightArrow" { if ($dir -ne "LEFT")  { $dir = "RIGHT" } }
                "UpArrow"    { if ($dir -ne "DOWN")  { $dir = "UP" } }
                "DownArrow"  { if ($dir -ne "UP")    { $dir = "DOWN" } }
                "Escape"     { [Console]::Clear(); Write-Host "`nHas salido de Snake." -ForegroundColor Yellow; Start-Sleep -Seconds 1; return }
            }
        }
        $head = $snake[0]; $newHead = [PSCustomObject]@{X=$head.X; Y=$head.Y}
        switch ($dir) { "LEFT" { $newHead.X-- }; "RIGHT" { $newHead.X++ }; "UP" { $newHead.Y-- }; "DOWN" { $newHead.Y++ } }

        $colision = $false
        if ($newHead.X -lt 0 -or $newHead.X -ge $width -or $newHead.Y -lt 0 -or $newHead.Y -ge $height) { $colision = $true }
        foreach ($segment in $snake) { if ($segment.X -eq $newHead.X -and $segment.Y -eq $newHead.Y) { $colision = $true; break } }

        if ($colision) {
            [Console]::Clear()
            Write-Host "`n==========================================" -ForegroundColor Red
            Write-Host "   ¡GAME OVER! Tu serpiente no sobrevivió." -ForegroundColor Red
            Write-Host "   Puntaje final: $score" -ForegroundColor Yellow
            Write-Host "==========================================" -ForegroundColor Red
            Write-Host "1. Volver a jugar Snake`n2. Volver al menú"
            $opcion = Read-Host "Elige (1-2)"
            if ($opcion -eq "1") { Start-ConsoleSnake; return } else { return }
        }
        $snake = @($newHead) + $snake[0..($snake.Length - 2)]
        if ($newHead.X -eq $food.X -and $newHead.Y -eq $food.Y) {
            $score += 10; $snake += $snake[-1]
            $food = [PSCustomObject]@{X = Get-Random -Minimum 1 -Maximum ($width - 1); Y = Get-Random -Minimum 1 -Maximum ($height - 1)}
        }
        $output = "Puntaje: $score | Flechas: Moverse | ESC: Salir`n"
        for ($y = 0; $y -lt $height; $y++) {
            $line = ""
            for ($x = 0; $x -lt $width; $x++) {
                if ($x -eq 0 -or $x -eq ($width - 1) -or $y -eq 0 -or $y -eq ($height - 1)) { $line += "#" } 
                elseif ($x -eq $food.X -and $y -eq $food.Y) { $line += "@" } 
                else {
                    $isSnake = $false
                    foreach ($segment in $snake) { if ($segment.X -eq $x -and $segment.Y -eq $y) { $isSnake = $true; break } }
                    if ($isSnake) { $line += "O" } else { $line += " " }
                }
            }
            $output += $line + "`n"
        }
        [Console]::SetCursorPosition(0, 0); [Console]::Write($output); Start-Sleep -Milliseconds $speed
    }
}