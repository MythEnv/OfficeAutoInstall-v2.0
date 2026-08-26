[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Mensaje de advertencia inicial
Clear-Host
Write-Host "==================================================================" -ForegroundColor Red
Write-Host "  [!] ADVERTENCIA: No te asustes, esto es parte del proceso..." -ForegroundColor Yellow
Write-Host "  [!] ¡TIENES QUE LEER EL README ANTES DE EJECUTAR ESTO!" -ForegroundColor Red
Write-Host "==================================================================" -ForegroundColor Red
Start-Sleep -Seconds 3

# Función para Lore RPG
function Write-LoreText {
    param([string]$Text, [int]$Delay = 25, [ConsoleColor]$Color = "Yellow")
    foreach ($char in $Text.ToCharArray()) {
        Write-Host $char -NoNewline -ForegroundColor $Color
        Start-Sleep -Milliseconds $Delay
    }
    Write-Host ""
}

# --- JUEGO 1: SNAKE ---
function Start-ConsoleSnake {
    [Console]::Clear()
    $width = 30
    $height = 15
    $snake = @(,[PSCustomObject]@{X=10;Y=5}, [PSCustomObject]@{X=9;Y=5}, [PSCustomObject]@{X=8;Y=5})
    $dir = "RIGHT"
    $food = [PSCustomObject]@{X = Get-Random -Minimum 1 -Maximum ($width - 1); Y = Get-Random -Minimum 1 -Maximum ($height - 1)}
    $score = 0
    $speed = 100

    while ($true) {
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            switch ($key.Key) {
                "LeftArrow"  { if ($dir -ne "RIGHT") { $dir = "LEFT" } }
                "RightArrow" { if ($dir -ne "LEFT")  { $dir = "RIGHT" } }
                "UpArrow"    { if ($dir -ne "DOWN")  { $dir = "UP" } }
                "DownArrow"  { if ($dir -ne "UP")    { $dir = "DOWN" } }
                "Escape"     { 
                    [Console]::Clear()
                    Write-Host "`nHas salido de Snake." -ForegroundColor Yellow
                    Start-Sleep -Seconds 1
                    return 
                }
            }
        }

        $head = $snake[0]
        $newHead = [PSCustomObject]@{X=$head.X; Y=$head.Y}
        switch ($dir) {
            "LEFT"  { $newHead.X-- }
            "RIGHT" { $newHead.X++ }
            "UP"    { $newHead.Y-- }
            "DOWN"  { $newHead.Y++ }
        }

        $colision = $false
        if ($newHead.X -lt 0 -or $newHead.X -ge $width -or $newHead.Y -lt 0 -or $newHead.Y -ge $height) { $colision = $true }
        foreach ($segment in $snake) { if ($segment.X -eq $newHead.X -and $segment.Y -eq $newHead.Y) { $colision = $true; break } }

        if ($colision) {
            [Console]::Clear()
            Write-Host "`n==========================================" -ForegroundColor Red
            Write-Host "   ¡GAME OVER! Tu serpiente no sobrevivió." -ForegroundColor Red
            Write-Host "   Puntaje final: $score" -ForegroundColor Yellow
            Write-Host "==========================================" -ForegroundColor Red
            Write-Host "1. Volver a jugar Snake"
            Write-Host "2. Volver al menú"
            $opcion = Read-Host "Elige (1-2)"
            if ($opcion -eq "1") { Start-ConsoleSnake; return }
            else { return }
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
        [Console]::SetCursorPosition(0, 0)
        [Console]::Write($output)
        Start-Sleep -Milliseconds $speed
    }
}

# --- JUEGO 2: BLACKJACK (CON ANIMACIÓN ASCII LENTA Y SUSPENSO) ---
function Start-ConsoleBlackjack {
    $palos = @("♠", "♥", "♦", "♣")
    $valores = @("2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A")

    function Obtener-Puntaje($mano) {
        $total = 0; $ases = 0
        foreach ($carta in $mano) {
            switch ($carta.Valor) {
                "J" { $total += 10 }; "Q" { $total += 10 }; "K" { $total += 10 }; "A" { $total += 11; $ases++ }
                default { $total += [int]$carta.Valor }
            }
        }
        while ($total -gt 21 -and $ases -gt 0) { $total -= 10; $ases-- }
        return $total
    }

    function Mostrar-Mesa($cartasJugador, $cartasCasa, $ocultarSegundaCartaCasa = $true) {
        Write-Host "`n  [ LA CASA ]" -ForegroundColor Yellow
        $l1 = "  "; $l2 = "  "; $l3 = "  "
        for ($i = 0; $i -lt $cartasCasa.Count; $i++) {
            if ($i -eq 1 -and $ocultarSegundaCartaCasa) {
                $l1 += "+-----+ "; $l2 += "|  ?  | "; $l3 += "+-----+ "
            } else {
                $v = $cartasCasa[$i].Valor.PadRight(2); $p = $cartasCasa[$i].Palo
                $colorCarta = if ($p -eq "♥" -or $p -eq "♦") { "Red" } else { "White" }
                $l1 += "+-----+ "; $l2 += "|$v $p | "; $l3 += "+-----+ "
            }
        }
        Write-Host $l1 -ForegroundColor White; Write-Host $l2 -ForegroundColor White; Write-Host $l3 -ForegroundColor White

        Write-Host "`n  [ TU MANO ] (Total: $(Obtener-Puntaje $cartasJugador))" -ForegroundColor Green
        $lj1 = "  "; $lj2 = "  "; $lj3 = "  "
        foreach ($carta in $cartasJugador) {
            $v = $carta.Valor.PadRight(2); $p = $carta.Palo
            $lj1 += "+-----+ "; $lj2 += "|$v $p | "; $lj3 += "+-----+ "
        }
        Write-Host $lj1 -ForegroundColor White; Write-Host $lj2 -ForegroundColor White; Write-Host $lj3 -ForegroundColor White
        Write-Host ""
    }

    # Motor de Animación ASCII mucho más lento
    function Animate-CartaASCII($CartasJug, $CartasCas, $NuevaCarta, $OcultarCas, $EsParaJug) {
        $v = $NuevaCarta.Valor.PadRight(2); $p = $NuevaCarta.Palo
        $f1 = @(".------.", "|#/\/\/|", "|/\/\/#|", "'------'")
        $f2 = @(" .----. ", " | // | ", " | // | ", " '----' ")
        $f3 = @("  .--.  ", "  | ||  ", "  | ||  ", "  '--'  ")
        $f4 = @(" .----. ", " | \\ | ", " | \\ | ", " '----' ")
        $f5 = @(".------.", "|$v    |", "|   $p  |", "'------'")
        
        $frames = @(,$f1, ,$f2, ,$f3, ,$f4, ,$f5)
        foreach ($frame in $frames) {
            [Console]::Clear()
            Write-Host "==================================================" -ForegroundColor DarkGreen
            Write-Host "        MESA DE BLACKJACK - ESTILO CASINO         " -ForegroundColor Cyan
            Write-Host "==================================================" -ForegroundColor DarkGreen
            Mostrar-Mesa $CartasJug $CartasCas $OcultarCas
            
            $tit = if ($EsParaJug) { "Repartiendo a tu mano..." } else { "La casa saca carta..." }
            Write-Host "  [$tit]`n" -ForegroundColor DarkGray
            foreach ($linea in $frame) { Write-Host "      $linea" -ForegroundColor Cyan }
            
            # ¡AQUÍ ESTÁ EL CAMBIO! Mucho más lento (350ms por frame) para mayor realismo y suspenso
            Start-Sleep -Milliseconds 350
        }
        Start-Sleep -Milliseconds 600
    }

    while ($true) {
        [Console]::Clear()
        $manoJugador = @([PSCustomObject]@{ Valor = Get-Random $valores; Palo = Get-Random $palos }, [PSCustomObject]@{ Valor = Get-Random $valores; Palo = Get-Random $palos })
        $manoCasa = @([PSCustomObject]@{ Valor = Get-Random $valores; Palo = Get-Random $palos }, [PSCustomObject]@{ Valor = Get-Random $valores; Palo = Get-Random $palos })

        Write-Host "==================================================" -ForegroundColor DarkGreen
        Write-Host "        MESA DE BLACKJACK - ESTILO CASINO         " -ForegroundColor Cyan
        Write-Host "==================================================" -ForegroundColor DarkGreen
        Mostrar-Mesa $manoJugador $manoCasa $true
        $totalJugador = Obtener-Puntaje $manoJugador

        while ($totalJugador -lt 21) {
            $accion = Read-Host "¿Pedir [p] o Plantarse [s]? (p/s)"
            if ($accion -eq 'p') {
                $c = [PSCustomObject]@{ Valor = Get-Random $valores; Palo = Get-Random $palos }
                Animate-CartaASCII $manoJugador $manoCasa $c $true $true
                $manoJugador += $c
                $totalJugador = Obtener-Puntaje $manoJugador
                if ($totalJugador -gt 21) {
                    [Console]::Clear()
                    Write-Host "==================================================" -ForegroundColor DarkGreen
                    Write-Host "        MESA DE BLACKJACK - ESTILO CASINO         " -ForegroundColor Cyan
                    Write-Host "==================================================" -ForegroundColor DarkGreen
                    Mostrar-Mesa $manoJugador $manoCasa $true
                    Write-Host "`n¡Te pasaste de 21! Has reventado." -ForegroundColor Red
                    break
                }
            } else { break }
            [Console]::Clear()
            Write-Host "==================================================" -ForegroundColor DarkGreen
            Write-Host "        MESA DE BLACKJACK - ESTILO CASINO         " -ForegroundColor Cyan
            Write-Host "==================================================" -ForegroundColor DarkGreen
            Mostrar-Mesa $manoJugador $manoCasa $true
        }

        if ($totalJugador -le 21) {
            Write-Host "`n[Crupier]: Te plantas con $totalJugador. Veamos la carta oculta..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            
            Animate-CartaASCII $manoJugador @($manoCasa[0]) $manoCasa[1] $false $false
            $totalCasa = Obtener-Puntaje $manoCasa

            while ($totalCasa -lt 17) {
                Start-Sleep -Seconds 1
                $c = [PSCustomObject]@{ Valor = Get-Random $valores; Palo = Get-Random $palos }
                Animate-CartaASCII $manoJugador $manoCasa $c $false $false
                $manoCasa += $c
                $totalCasa = Obtener-Puntaje $manoCasa
            }
            [Console]::Clear()
            Write-Host "==================================================" -ForegroundColor DarkGreen
            Write-Host "        MESA DE BLACKJACK - ESTILO CASINO         " -ForegroundColor Cyan
            Write-Host "==================================================" -ForegroundColor DarkGreen
            Mostrar-Mesa $manoJugador $manoCasa $false

            Write-Host ""
            if ($totalCasa -gt 21) { Write-Host "¡La casa revienta con $totalCasa! ¡GANASTE!" -ForegroundColor Green }
            elseif ($totalJugador -gt $totalCasa) { Write-Host "¡Felicidades! Ganas $totalJugador a $totalCasa." -ForegroundColor Green }
            elseif ($totalJugador -eq $totalCasa) { Write-Host "Empate ($totalJugador a $totalCasa). Recuperas tu apuesta." -ForegroundColor Yellow }
            else { Write-Host "La casa gana $totalCasa a $totalJugador. ¡Perdiste!" -ForegroundColor Red }
        }

        Write-Host ""
        $repetir = Read-Host "¿Otra mano? (s/n)"
        if ($repetir -ne 's') { break }
    }
}

# --- JUEGO 3: RULETA CON FÍSICAS REALES Y DISEÑO DE CARRUSEL ---
function Start-ConsoleRoulette {
    $rojos = @(1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36)
    $rueda = @(0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26)

    while ($true) {
        [Console]::Clear()
        Write-Host "==================================================" -ForegroundColor Magenta
        Write-Host "        RULETA EN VIVO - ESTILO APUESTA TOTAL     " -ForegroundColor Magenta
        Write-Host "==================================================" -ForegroundColor Magenta
        Write-Host "1. Color (rojo / negro)"
        Write-Host "2. Par / Impar"
        Write-Host "3. Docena (1: 1-12 | 2: 13-24 | 3: 25-36)"
        Write-Host "4. Número a Pleno (Ej: '11', 'Rojo 11', 'Negro 23')"
        
        $tipo = Read-Host "Selecciona opción (1-4)"
        $apuestaUsuario = $null

        if ($tipo -eq "1") { $apuestaUsuario = Read-Host "Elige color (rojo / negro)" }
        elseif ($tipo -eq "2") { $apuestaUsuario = Read-Host "Elige paridad (par / impar)" }
        elseif ($tipo -eq "3") { $apuestaUsuario = [int](Read-Host "Elige número de docena (1, 2 o 3)") }
        elseif ($tipo -eq "4") { 
            $str = Read-Host "Ingresa tu apuesta (Ej: Rojo 11, Negro 23)"
            if ($str -match '\d+') {
                $apuestaUsuario = [int]$matches[0]
                if ($apuestaUsuario -lt 0 -or $apuestaUsuario -gt 36) {
                    Write-Host "Número inválido. (Debe ser del 0 al 36)" -ForegroundColor Red
                    Start-Sleep -Seconds 2; continue
                }
            } else { Write-Host "Formato inválido." -ForegroundColor Red; Start-Sleep -Seconds 1; continue }
        } else { continue }

        [Console]::Clear()
        Write-Host "==================================================" -ForegroundColor Magenta
        Write-Host "               ¡NO VA MÁS! GIRANDO...             " -ForegroundColor Magenta
        Write-Host "==================================================" -ForegroundColor Magenta
        Write-Host ""
        $top = [Console]::CursorTop
        
        $posicion = Get-Random -Minimum 0 -Maximum $rueda.Count
        $vueltas = Get-Random -Minimum 45 -Maximum 65
        
        # Algoritmo de física: Empieza en 15ms y se multiplica simulando fricción
        $velocidad = 15.0 

        for ($v = 0; $v -lt $vueltas; $v++) {
            [Console]::SetCursorPosition(0, $top)
            Write-Host "       .----------------------------------------." -ForegroundColor DarkGray
            Write-Host -NoNewline "       |  " -ForegroundColor DarkGray

            $posicion = ($posicion + 1) % $rueda.Count
            
            # Dibujar 5 casillas de la ruleta
            for ($k = -2; $k -le 2; $k++) {
                $idx = ($posicion + $k + $rueda.Count) % $rueda.Count
                $n = $rueda[$idx]
                
                $col = if ($n -eq 0) { "Green" } elseif ($rojos -contains $n) { "Red" } else { "DarkGray" }
                $txt = $n.ToString().PadLeft(2, ' ')

                if ($k -eq 0) { 
                    Write-Host "[$txt]  " -NoNewline -ForegroundColor Black -BackgroundColor White 
                } else { 
                    Write-Host " $txt   " -NoNewline -ForegroundColor $col 
                }
            }
            Write-Host "|" -ForegroundColor DarkGray
            Write-Host "       '-------------------+--------------------'" -ForegroundColor DarkGray
            Write-Host "                          /|\                    " -ForegroundColor Yellow
            Write-Host "                         ( O )                   " -ForegroundColor White
            
            # Frenado exponencial: La velocidad de retardo crece un 7% cada frame
            $velocidad = $velocidad * 1.07 
            $delayFinal = [int][math]::Min([math]::Round($velocidad), 1200) # Máximo 1.2 seg por click al final
            Start-Sleep -Milliseconds $delayFinal
        }

        Write-Host "`n`n[Crupier]: La bola cae pesadamente..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2

        $res = $rueda[$posicion]
        $colRes = if ($res -eq 0) { "Verde" } elseif ($rojos -contains $res) { "Rojo" } else { "Negro" }
        $printColor = if ($res -eq 0) { "Green" } elseif ($rojos -contains $res) { "Red" } else { "Gray" }

        Write-Host "==================================================" -ForegroundColor Yellow
        Write-Host "   ¡NÚMERO GANADOR: [$res] ($colRes)!   " -ForegroundColor $printColor
        Write-Host "==================================================" -ForegroundColor Yellow

        $acerto = $false
        if ($tipo -eq "1" -and $apuestaUsuario.ToLower() -eq $colRes.ToLower()) { $acerto = $true }
        elseif ($tipo -eq "2" -and $res -ne 0 -and ($res % 2 -eq 0) -eq ($apuestaUsuario.ToLower() -eq "par")) { $acerto = $true }
        elseif ($tipo -eq "3" -and (($apuestaUsuario -eq 1 -and $res -ge 1 -and $res -le 12) -or ($apuestaUsuario -eq 2 -and $res -ge 13 -and $res -le 24) -or ($apuestaUsuario -eq 3 -and $res -ge 25 -and $res -le 36))) { $acerto = $true }
        elseif ($tipo -eq "4" -and $apuestaUsuario -eq $res) { $acerto = $true }

        if ($acerto) { Write-Host "`n ¡APUESTA GANADA! ¡Felicidades!" -ForegroundColor Green } 
        else { Write-Host "`n ¡Perdiste la apuesta! Suerte en la próxima." -ForegroundColor Red }

        Write-Host ""
        $repetir = Read-Host "¿Otra tirada? (s/n)"
        if ($repetir -ne 's') { break }
    }
}

# --- MENÚ ARCADE ---
function Show-ArcadeMenu {
    while ($true) {
        [Console]::Clear()
        Write-Host "==================================================" -ForegroundColor Yellow
        Write-Host "          CASINO VIRTUAL - MENÚ PRINCIPAL         " -ForegroundColor Yellow
        Write-Host "==================================================" -ForegroundColor Yellow
        Write-Host "1. Snake (Clásico de la serpiente)"
        Write-Host "2. Blackjack (Mesa de cartas realista)"
        Write-Host "3. Ruleta (Físicas de fricción realistas)"
        Write-Host "4. Volver al chat con Masi (Instalador)"
        Write-Host "=================================================="
        
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

# --- FLUJO PRINCIPAL ---
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Iniciando Simulador de Office (Linux)  " -ForegroundColor Cyan
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
                        (\  /_--/_\\_
                         `'-.
                          ,__)

        MythEnv - Sh1romsi
"@ -ForegroundColor White

Write-Host "Iniciando el proceso pesado. Toma asiento y trae un café...`n" -ForegroundColor Yellow

$proceso = Start-Process sleep -ArgumentList "240" -PassThru 
$urlApi = "https://cold-rain-150a.wenliangk.workers.dev"

Write-Host "`n[Instalador]: Hola, Soy Masi tu asistente IA e instalador, por el momento solo robare tus credenciales y te instalare un malware... jajaj es broma, solo instalare tu office, como va tu dia?" -ForegroundColor Cyan
Write-Host "*(Elige tu camino: escribe 'masi' para charlar o 'juegos' para abrir el casino)*" -ForegroundColor DarkGray

while (-not $proceso.HasExited) {
    $mensajeUsuario = Read-Host "`n[Tu]"
    if ($proceso.HasExited) { break }
    
    if ($mensajeUsuario -eq "juegos" -or $mensajeUsuario -eq "arcade") {
        Show-ArcadeMenu
        Write-Host "`n[Instalador]: ¡De vuelta en la terminal! ¿Qué tal la suerte o seguimos charlando?" -ForegroundColor Cyan
        continue
    }
    elseif ($mensajeUsuario -eq "masi") {
        Write-Host "`n[Instalador]: ¡Perfecto! Sigamos conversando por aquí." -ForegroundColor Cyan
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

Write-Host "`n[Instalador]: Disculpa, ya se horneo el pan." -ForegroundColor Yellow
Write-Host "`n¡Instalacion de Office terminada con exito!" -ForegroundColor Green

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "   Ejecutando configuracion final..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Activando Office de forma silenciosa, por favor espera..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
Write-Host "[SIMULACION]: Office activado exitosamente con Ohook (Licencia Permanente)." -ForegroundColor Green

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "   ¡Gracias por confiar en nosotros!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Read-Host "Presiona Enter para salir..."