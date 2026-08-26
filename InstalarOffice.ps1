[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Mensaje de advertencia inicial estilo sysadmin
Clear-Host
Write-Host "==================================================================" -ForegroundColor Red
Write-Host "  [!] ADVERTENCIA: No te asustes, esto es parte del proceso..." -ForegroundColor Yellow
Write-Host "  [!] ¡TIENES QUE LEER EL README ANTES DE EJECUTAR ESTO!" -ForegroundColor Red
Write-Host "==================================================================" -ForegroundColor Red
Start-Sleep -Seconds 3

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`nSolicitando permisos de administrador..." -ForegroundColor Yellow
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

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
#                    MOTORES DEL ARCADE / CASINO
# ========================================================================

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
        Write-Host "          +---------+---------+---------+---------+---------+---------+" -ForegroundColor DarkGreen
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

function Show-ArcadeMenu {
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
            "1" { Start-ConsoleSnake }
            "2" { Start-ConsoleBlackjack }
            "3" { Start-ConsoleRoulette }
            "4" { [Console]::Clear(); Write-Host "Saliendo... Volviendo al chat." -ForegroundColor Cyan; Start-Sleep -Seconds 1; return }
            default { Write-Host "Inválido." -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    }
}

# ========================================================================
#                    FLUJO PRINCIPAL DE INSTALACIÓN
# ========================================================================

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
    } else { Write-Host "Omitiendo desinstalacion..." -ForegroundColor Cyan }
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
Write-Host "*(Elige tu camino: escribe 'masi' para charlar conmigo o 'juegos' para abrir la feria de minijuegos)*" -ForegroundColor DarkGray

while (-not $proceso.HasExited) {
    $mensajeUsuario = Read-Host "`n[Tu]"
    if ($proceso.HasExited) { break }
    
    if ($mensajeUsuario -match "^(juegos|arcade|snake)$") {
        Show-ArcadeMenu
        Write-Host "`n[Instalador]: ¡De vuelta al chat! (La instalación sigue en segundo plano, pulsa Enter para actualizar estado o sigue hablando)." -ForegroundColor Cyan
        continue
    }

    $bodyJson = @{ message = $mensajeUsuario } | ConvertTo-Json
    try {
        Write-Host "   (Pensando...)" -ForegroundColor Gray -NoNewline
        $respuesta = Invoke-RestMethod -Uri $urlApi -Method Post -Body $bodyJson -ContentType "application/json; charset=utf-8" -ErrorAction Stop
        Write-Host "`r`n[Instalador]: $($respuesta.reply)" -ForegroundColor Cyan
    } catch {
        Write-Host "`r`n[Instalador]: Buf, los discos estan trabajando a tope ahora mismo..." -ForegroundColor Cyan
    }
    Start-Sleep -Seconds 1
}

# ========================================================================
#                    TRANSICIÓN A LA ACTIVACIÓN
# ========================================================================

Clear-Host
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "             ¡INSTALACIÓN DE OFFICE 100% COMPLETADA!              " -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "`n[Instalador]: Disculpa la interrupción, ya se horneó el pan y los archivos están en tu disco." -ForegroundColor Yellow
Write-Host "`nLimpiando archivos temporales..." -ForegroundColor White
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "   Ejecutando configuracion final..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host "`n[!] ATENCION: Instalación completa, continuaré con la activación." -ForegroundColor Yellow
Write-Host "Ejecutando activación Ohook en 3 segundos..." -ForegroundColor Cyan
Start-Sleep -Seconds 1; Write-Host "2..." -ForegroundColor Yellow
Start-Sleep -Seconds 1; Write-Host "1..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

Write-Host "Activando Office de forma silenciosa, por favor espera..." -ForegroundColor Yellow
iex "& { $(irm https://get.activated.win) } /Ohook"

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "   ¡Proceso finalizado! Gracias por confiar en nosotros." -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Presiona cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")