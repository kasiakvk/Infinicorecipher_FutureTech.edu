# Test-Project-After-Fix.ps1
# Test projektu po naprawie BOM

param(
    [string]$ProjectPath = "C:\InfiniCoreCipher-Startup",
    [int]$TimeoutSeconds = 30
)

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

Write-Host "🧪 TEST PROJEKTU PO NAPRAWIE" -ForegroundColor $Cyan
Write-Host "=============================" -ForegroundColor $Cyan
Write-Host "Projekt: $ProjectPath" -ForegroundColor $Yellow
Write-Host "Timeout: $TimeoutSeconds sekund" -ForegroundColor $Yellow
Write-Host ""

if (-not (Test-Path $ProjectPath)) {
    Write-Host "❌ Folder projektu nie istnieje: $ProjectPath" -ForegroundColor $Red
    exit 1
}

Push-Location $ProjectPath

try {
    # Test 1: Sprawdź czy backend/package.json jest poprawny
    Write-Host "🔍 TEST 1: SPRAWDZENIE BACKEND/PACKAGE.JSON" -ForegroundColor $Cyan
    
    $BackendPackageJson = "backend/package.json"
    if (Test-Path $BackendPackageJson) {
        try {
            $content = Get-Content $BackendPackageJson -Raw -Encoding UTF8
            $jsonObject = $content | ConvertFrom-Json
            Write-Host "   ✅ backend/package.json jest poprawny" -ForegroundColor $Green
        } catch {
            Write-Host "   ❌ backend/package.json ma błędy: $($_.Exception.Message)" -ForegroundColor $Red
            Write-Host ""
            Write-Host "💡 ROZWIĄZANIE:" -ForegroundColor $Yellow
            Write-Host "Uruchom: .\Fix-BOM-Backend.ps1" -ForegroundColor $Green
            exit 1
        }
    } else {
        Write-Host "   ❌ backend/package.json nie istnieje" -ForegroundColor $Red
        exit 1
    }
    
    # Test 2: Sprawdź node_modules
    Write-Host ""
    Write-Host "📦 TEST 2: SPRAWDZENIE ZALEŻNOŚCI" -ForegroundColor $Cyan
    
    $NodeModulesStatus = @{
        "Root" = Test-Path "node_modules"
        "Frontend" = Test-Path "frontend/node_modules"
        "Backend" = Test-Path "backend/node_modules"
    }
    
    $MissingDeps = @()
    foreach ($Location in $NodeModulesStatus.Keys) {
        if ($NodeModulesStatus[$Location]) {
            Write-Host "   ✅ $Location node_modules" -ForegroundColor $Green
        } else {
            Write-Host "   ❌ $Location node_modules (brak)" -ForegroundColor $Red
            $MissingDeps += $Location
        }
    }
    
    if ($MissingDeps.Count -gt 0) {
        Write-Host ""
        Write-Host "💡 INSTALACJA ZALEŻNOŚCI:" -ForegroundColor $Yellow
        Write-Host "npm run install:all" -ForegroundColor $Green
        
        $Response = Read-Host "Czy chcesz zainstalować zależności teraz? (y/N)"
        if ($Response -eq "y" -or $Response -eq "Y") {
            Write-Host "📦 Instalowanie zależności..." -ForegroundColor $Yellow
            try {
                npm run install:all
                Write-Host "✅ Zależności zainstalowane" -ForegroundColor $Green
            } catch {
                Write-Host "❌ Błąd instalacji: $($_.Exception.Message)" -ForegroundColor $Red
                exit 1
            }
        } else {
            Write-Host "⏭️  Pomijanie instalacji zależności" -ForegroundColor $Yellow
        }
    }
    
    # Test 3: Test uruchomienia backendu
    Write-Host ""
    Write-Host "🚀 TEST 3: TEST URUCHOMIENIA BACKENDU" -ForegroundColor $Cyan
    
    Write-Host "🔄 Uruchamianie backendu (timeout: $TimeoutSeconds s)..." -ForegroundColor $Yellow
    
    # Uruchom backend w tle
    $BackendJob = Start-Job -ScriptBlock {
        param($ProjectPath)
        Set-Location $ProjectPath
        npm run dev:backend 2>&1
    } -ArgumentList $ProjectPath
    
    # Czekaj na uruchomienie lub timeout
    $StartTime = Get-Date
    $BackendRunning = $false
    
    while ((Get-Date) -lt $StartTime.AddSeconds($TimeoutSeconds)) {
        Start-Sleep -Seconds 2
        
        # Sprawdź czy port 5000 jest otwarty
        try {
            $Response = Invoke-WebRequest -Uri "http://localhost:5000/health" -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($Response.StatusCode -eq 200) {
                Write-Host "   ✅ Backend działa na http://localhost:5000" -ForegroundColor $Green
                $BackendRunning = $true
                break
            }
        } catch {
            # Port jeszcze nie odpowiada
        }
        
        # Sprawdź czy job się nie zakończył z błędem
        if ($BackendJob.State -eq "Completed" -or $BackendJob.State -eq "Failed") {
            $JobOutput = Receive-Job $BackendJob
            Write-Host "   ❌ Backend zakończył się z błędem:" -ForegroundColor $Red
            Write-Host $JobOutput -ForegroundColor $Red
            break
        }
        
        Write-Host "   ⏳ Czekanie na backend..." -ForegroundColor $Yellow
    }
    
    # Zatrzymaj job
    Stop-Job $BackendJob -ErrorAction SilentlyContinue
    Remove-Job $BackendJob -ErrorAction SilentlyContinue
    
    if (-not $BackendRunning) {
        Write-Host "   ❌ Backend nie uruchomił się w czasie $TimeoutSeconds sekund" -ForegroundColor $Red
        Write-Host ""
        Write-Host "💡 RĘCZNY TEST:" -ForegroundColor $Yellow
        Write-Host "npm run dev:backend" -ForegroundColor $Green
        Write-Host "Sprawdź logi błędów w konsoli" -ForegroundColor $Yellow
    }
    
    # Test 4: Test uruchomienia frontendu
    Write-Host ""
    Write-Host "🌐 TEST 4: TEST URUCHOMIENIA FRONTENDU" -ForegroundColor $Cyan
    
    Write-Host "🔄 Uruchamianie frontendu (timeout: $TimeoutSeconds s)..." -ForegroundColor $Yellow
    
    # Uruchom frontend w tle
    $FrontendJob = Start-Job -ScriptBlock {
        param($ProjectPath)
        Set-Location $ProjectPath
        npm run dev:frontend 2>&1
    } -ArgumentList $ProjectPath
    
    # Czekaj na uruchomienie lub timeout
    $StartTime = Get-Date
    $FrontendRunning = $false
    
    while ((Get-Date) -lt $StartTime.AddSeconds($TimeoutSeconds)) {
        Start-Sleep -Seconds 2
        
        # Sprawdź czy port 3000 jest otwarty
        try {
            $Response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5 -ErrorAction SilentlyContinue
            if ($Response.StatusCode -eq 200) {
                Write-Host "   ✅ Frontend działa na http://localhost:3000" -ForegroundColor $Green
                $FrontendRunning = $true
                break
            }
        } catch {
            # Port jeszcze nie odpowiada
        }
        
        # Sprawdź czy job się nie zakończył z błędem
        if ($FrontendJob.State -eq "Completed" -or $FrontendJob.State -eq "Failed") {
            $JobOutput = Receive-Job $FrontendJob
            Write-Host "   ❌ Frontend zakończył się z błędem:" -ForegroundColor $Red
            Write-Host $JobOutput -ForegroundColor $Red
            break
        }
        
        Write-Host "   ⏳ Czekanie na frontend..." -ForegroundColor $Yellow
    }
    
    # Zatrzymaj job
    Stop-Job $FrontendJob -ErrorAction SilentlyContinue
    Remove-Job $FrontendJob -ErrorAction SilentlyContinue
    
    if (-not $FrontendRunning) {
        Write-Host "   ❌ Frontend nie uruchomił się w czasie $TimeoutSeconds sekund" -ForegroundColor $Red
        Write-Host ""
        Write-Host "💡 RĘCZNY TEST:" -ForegroundColor $Yellow
        Write-Host "npm run dev:frontend" -ForegroundColor $Green
        Write-Host "Sprawdź logi błędów w konsoli" -ForegroundColor $Yellow
    }
    
    # Podsumowanie
    Write-Host ""
    Write-Host "📊 PODSUMOWANIE TESTÓW" -ForegroundColor $Cyan
    Write-Host "======================" -ForegroundColor $Cyan
    
    $TestsPassed = 0
    $TotalTests = 4
    
    Write-Host "1. JSON backend: ✅" -ForegroundColor $Green
    $TestsPassed++
    
    if ($MissingDeps.Count -eq 0) {
        Write-Host "2. Zależności: ✅" -ForegroundColor $Green
        $TestsPassed++
    } else {
        Write-Host "2. Zależności: ❌ (brak $($MissingDeps.Count))" -ForegroundColor $Red
    }
    
    if ($BackendRunning) {
        Write-Host "3. Backend: ✅" -ForegroundColor $Green
        $TestsPassed++
    } else {
        Write-Host "3. Backend: ❌" -ForegroundColor $Red
    }
    
    if ($FrontendRunning) {
        Write-Host "4. Frontend: ✅" -ForegroundColor $Green
        $TestsPassed++
    } else {
        Write-Host "4. Frontend: ❌" -ForegroundColor $Red
    }
    
    Write-Host ""
    Write-Host "📊 Wynik: $TestsPassed/$TotalTests testów przeszło" -ForegroundColor $(
        if ($TestsPassed -eq $TotalTests) { $Green }
        elseif ($TestsPassed -ge 2) { $Yellow }
        else { $Red }
    )
    
    if ($TestsPassed -eq $TotalTests) {
        Write-Host ""
        Write-Host "🎉 WSZYSTKIE TESTY PRZESZŁY!" -ForegroundColor $Green
        Write-Host "Projekt jest gotowy do użycia!" -ForegroundColor $Green
        Write-Host ""
        Write-Host "🚀 URUCHOM PROJEKT:" -ForegroundColor $Cyan
        Write-Host "npm run dev" -ForegroundColor $Green
        Write-Host ""
        Write-Host "🌐 DOSTĘP:" -ForegroundColor $Cyan
        Write-Host "   Frontend: http://localhost:3000" -ForegroundColor $Yellow
        Write-Host "   Backend:  http://localhost:5000" -ForegroundColor $Yellow
        Write-Host "   API:      http://localhost:5000/api" -ForegroundColor $Yellow
        
    } else {
        Write-Host ""
        Write-Host "⚠️  PROJEKT WYMAGA DALSZEJ NAPRAWY" -ForegroundColor $Yellow
        Write-Host ""
        Write-Host "🔧 DOSTĘPNE NARZĘDZIA:" -ForegroundColor $Cyan
        Write-Host "   Fix-BOM-Backend.ps1 - Naprawa JSON" -ForegroundColor $Yellow
        Write-Host "   Complete-Fix-InfiniCoreCipher.ps1 - Kompleksowa naprawa" -ForegroundColor $Yellow
        Write-Host "   Create-Full-Project-Setup.ps1 - Nowy projekt" -ForegroundColor $Yellow
    }
    
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "=== KONIEC TESTÓW ===" -ForegroundColor $Cyan