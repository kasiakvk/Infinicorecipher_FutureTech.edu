<#
.SYNOPSIS
    Skrypt testowy dla naprawionego projektu InfiniCoreCipher

.DESCRIPTION
    Przeprowadza kompleksowe testy po naprawie projektu
#>

# Kolory
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Blue = "Blue"

function Write-TestStatus {
    param(
        [string]$Message,
        [string]$Status = "INFO",
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Status] $Message" -ForegroundColor $Color
}

function Test-Port {
    param([int]$Port, [string]$Service)
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$Port" -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-TestStatus "✅ $Service działa na porcie $Port" "OK" $Green
            return $true
        }
    } catch {
        # Sprawdź czy port jest otwarty innym sposobem
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $tcpClient.Connect("localhost", $Port)
            $tcpClient.Close()
            Write-TestStatus "✅ $Service odpowiada na porcie $Port" "OK" $Green
            return $true
        } catch {
            Write-TestStatus "❌ $Service nie odpowiada na porcie $Port" "ERROR" $Red
            return $false
        }
    }
    return $false
}

Write-Host "=== TEST NAPRAWIONEGO PROJEKTU ===" -ForegroundColor $Cyan
Write-Host ""

# Sprawdzenie czy jesteśmy w odpowiednim katalogu
if (-not (Test-Path "package.json")) {
    Write-TestStatus "❌ Nie znaleziono package.json w bieżącym katalogu" "ERROR" $Red
    Write-TestStatus "Przejdź do katalogu głównego projektu InfiniCoreCipher" "INFO" $Yellow
    exit 1
}

Write-TestStatus "🔍 ROZPOCZĘCIE TESTÓW" "INFO" $Cyan

# Test 1: Sprawdzenie struktury plików
Write-TestStatus "📁 TEST 1: STRUKTURA PLIKÓW" "INFO" $Yellow

$requiredFiles = @(
    "package.json",
    "frontend/package.json",
    "backend/package.json",
    "backend/server.js",
    "frontend/src/main.jsx",
    "frontend/src/App.jsx",
    "frontend/index.html",
    "frontend/vite.config.js"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-TestStatus "✅ $file" "OK" $Green
    } else {
        Write-TestStatus "❌ $file - BRAK" "ERROR" $Red
        $missingFiles += $file
    }
}

if ($missingFiles.Count -eq 0) {
    Write-TestStatus "✅ Wszystkie wymagane pliki istnieją" "OK" $Green
} else {
    Write-TestStatus "❌ Brakuje $($missingFiles.Count) plików" "ERROR" $Red
}

Write-Host ""

# Test 2: Sprawdzenie zależności
Write-TestStatus "📦 TEST 2: ZALEŻNOŚCI" "INFO" $Yellow

$nodeModulesPaths = @("node_modules", "frontend/node_modules", "backend/node_modules")
$missingNodeModules = @()

foreach ($path in $nodeModulesPaths) {
    if (Test-Path $path) {
        Write-TestStatus "✅ $path" "OK" $Green
    } else {
        Write-TestStatus "❌ $path - BRAK" "ERROR" $Red
        $missingNodeModules += $path
    }
}

if ($missingNodeModules.Count -gt 0) {
    Write-TestStatus "⚠️  Instalowanie brakujących zależności..." "WARNING" $Yellow
    try {
        $installProcess = Start-Process -FilePath "npm" -ArgumentList "run", "install:all" -Wait -PassThru -NoNewWindow
        if ($installProcess.ExitCode -eq 0) {
            Write-TestStatus "✅ Zależności zainstalowane pomyślnie" "OK" $Green
        } else {
            Write-TestStatus "❌ Błąd instalacji zależności (kod: $($installProcess.ExitCode))" "ERROR" $Red
        }
    } catch {
        Write-TestStatus "❌ Błąd podczas instalacji: $($_.Exception.Message)" "ERROR" $Red
    }
}

Write-Host ""

# Test 3: Test uruchomienia backendu
Write-TestStatus "🖥️ TEST 3: BACKEND" "INFO" $Yellow

Write-TestStatus "Uruchamianie backendu..." "INFO" $Blue
try {
    # Uruchom backend w tle
    $backendProcess = Start-Process -FilePath "npm" -ArgumentList "run", "dev:backend" -PassThru -WindowStyle Hidden
    
    # Czekaj na uruchomienie (max 30 sekund)
    $timeout = 30
    $elapsed = 0
    $backendRunning = $false
    
    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds 2
        $elapsed += 2
        
        # Sprawdź health endpoint
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -TimeoutSec 3 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                $healthData = $response.Content | ConvertFrom-Json
                Write-TestStatus "✅ Backend działa - Status: $($healthData.status)" "OK" $Green
                $backendRunning = $true
                break
            }
        } catch {
            Write-TestStatus "⏳ Czekanie na backend... ($elapsed/$timeout s)" "INFO" $Blue
        }
        
        # Sprawdź czy proces się nie zakończył
        if ($backendProcess.HasExited) {
            Write-TestStatus "❌ Backend zakończył się przedwcześnie (kod: $($backendProcess.ExitCode))" "ERROR" $Red
            break
        }
    }
    
    if (-not $backendRunning -and -not $backendProcess.HasExited) {
        Write-TestStatus "❌ Backend nie uruchomił się w czasie $timeout sekund" "ERROR" $Red
    }
    
    # Zatrzymaj proces backendu
    if (-not $backendProcess.HasExited) {
        $backendProcess.Kill()
        Write-TestStatus "🛑 Backend zatrzymany" "INFO" $Blue
    }
    
} catch {
    Write-TestStatus "❌ Błąd uruchomienia backendu: $($_.Exception.Message)" "ERROR" $Red
}

Write-Host ""

# Test 4: Test uruchomienia frontendu
Write-TestStatus "🌐 TEST 4: FRONTEND" "INFO" $Yellow

Write-TestStatus "Uruchamianie frontendu..." "INFO" $Blue
try {
    # Uruchom frontend w tle
    $frontendProcess = Start-Process -FilePath "npm" -ArgumentList "run", "dev:frontend" -PassThru -WindowStyle Hidden
    
    # Czekaj na uruchomienie (max 45 sekund - Vite może być wolniejszy)
    $timeout = 45
    $elapsed = 0
    $frontendRunning = $false
    
    while ($elapsed -lt $timeout) {
        Start-Sleep -Seconds 3
        $elapsed += 3
        
        # Sprawdź czy frontend odpowiada
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-TestStatus "✅ Frontend działa na http://localhost:3000" "OK" $Green
                $frontendRunning = $true
                break
            }
        } catch {
            Write-TestStatus "⏳ Czekanie na frontend... ($elapsed/$timeout s)" "INFO" $Blue
        }
        
        # Sprawdź czy proces się nie zakończył
        if ($frontendProcess.HasExited) {
            Write-TestStatus "❌ Frontend zakończył się przedwcześnie (kod: $($frontendProcess.ExitCode))" "ERROR" $Red
            break
        }
    }
    
    if (-not $frontendRunning -and -not $frontendProcess.HasExited) {
        Write-TestStatus "❌ Frontend nie uruchomił się w czasie $timeout sekund" "ERROR" $Red
    }
    
    # Zatrzymaj proces frontendu
    if (-not $frontendProcess.HasExited) {
        $frontendProcess.Kill()
        Write-TestStatus "🛑 Frontend zatrzymany" "INFO" $Blue
    }
    
} catch {
    Write-TestStatus "❌ Błąd uruchomienia frontendu: $($_.Exception.Message)" "ERROR" $Red
}

Write-Host ""

# Test 5: Test API endpoints
Write-TestStatus "🔌 TEST 5: API ENDPOINTS" "INFO" $Yellow

# Uruchom backend ponownie dla testów API
Write-TestStatus "Uruchamianie backendu dla testów API..." "INFO" $Blue
try {
    $apiTestBackend = Start-Process -FilePath "npm" -ArgumentList "run", "dev:backend" -PassThru -WindowStyle Hidden
    Start-Sleep -Seconds 10  # Daj czas na uruchomienie
    
    # Test health endpoint
    try {
        $healthResponse = Invoke-WebRequest -Uri "http://localhost:5000/health" -TimeoutSec 5
        if ($healthResponse.StatusCode -eq 200) {
            Write-TestStatus "✅ /health endpoint działa" "OK" $Green
            $healthData = $healthResponse.Content | ConvertFrom-Json
            Write-TestStatus "   Status: $($healthData.status)" "INFO" $Blue
        }
    } catch {
        Write-TestStatus "❌ /health endpoint nie działa" "ERROR" $Red
    }
    
    # Test API endpoint
    try {
        $apiResponse = Invoke-WebRequest -Uri "http://localhost:5000/api" -TimeoutSec 5
        if ($apiResponse.StatusCode -eq 200) {
            Write-TestStatus "✅ /api endpoint działa" "OK" $Green
            $apiData = $apiResponse.Content | ConvertFrom-Json
            Write-TestStatus "   Wersja API: $($apiData.version)" "INFO" $Blue
        }
    } catch {
        Write-TestStatus "❌ /api endpoint nie działa" "ERROR" $Red
    }
    
    # Zatrzymaj backend
    if (-not $apiTestBackend.HasExited) {
        $apiTestBackend.Kill()
        Write-TestStatus "🛑 Backend testowy zatrzymany" "INFO" $Blue
    }
    
} catch {
    Write-TestStatus "❌ Błąd testów API: $($_.Exception.Message)" "ERROR" $Red
}

Write-Host ""

# Podsumowanie
Write-TestStatus "📊 PODSUMOWANIE TESTÓW" "INFO" $Cyan
Write-TestStatus "======================" "INFO" $Cyan

$testResults = @{
    "Struktura plików" = ($missingFiles.Count -eq 0)
    "Zależności" = ($missingNodeModules.Count -eq 0)
    "Backend" = $backendRunning
    "Frontend" = $frontendRunning
}

$passedTests = 0
$totalTests = $testResults.Count

foreach ($test in $testResults.GetEnumerator()) {
    if ($test.Value) {
        Write-TestStatus "✅ $($test.Key)" "OK" $Green
        $passedTests++
    } else {
        Write-TestStatus "❌ $($test.Key)" "ERROR" $Red
    }
}

Write-Host ""
Write-TestStatus "📈 Wynik: $passedTests/$totalTests testów przeszło" "INFO" $(
    if ($passedTests -eq $totalTests) { $Green }
    elseif ($passedTests -ge ($totalTests * 0.75)) { $Yellow }
    else { $Red }
)

if ($passedTests -eq $totalTests) {
    Write-Host ""
    Write-TestStatus "🎉 WSZYSTKIE TESTY PRZESZŁY!" "OK" $Green
    Write-TestStatus "Projekt InfiniCoreCipher jest gotowy do użycia!" "OK" $Green
    Write-Host ""
    Write-TestStatus "🚀 URUCHOM PROJEKT:" "INFO" $Cyan
    Write-TestStatus "npm run dev" "INFO" $Green
    Write-Host ""
    Write-TestStatus "🌐 DOSTĘP:" "INFO" $Cyan
    Write-TestStatus "   Frontend: http://localhost:3000" "INFO" $Blue
    Write-TestStatus "   Backend:  http://localhost:5000" "INFO" $Blue
    Write-TestStatus "   API:      http://localhost:5000/api" "INFO" $Blue
    Write-TestStatus "   Health:   http://localhost:5000/health" "INFO" $Blue
} else {
    Write-Host ""
    Write-TestStatus "⚠️  PROJEKT WYMAGA DALSZEJ NAPRAWY" "WARNING" $Yellow
    Write-TestStatus "Uruchom ponownie Fix-InfiniCoreCipher-Scripts.ps1" "INFO" $Blue
}

Write-Host ""
Write-TestStatus "=== KONIEC TESTÓW ===" "INFO" $Cyan