<#
.SYNOPSIS
    Skrypt diagnostyczny dla projektu InfiniCoreCipher

.DESCRIPTION
    Sprawdza konfigurację, zależności i identyfikuje problemy z uruchomieniem
#>

# Kolory dla lepszej czytelności
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Blue = "Blue"

function Write-Status {
    param(
        [string]$Message,
        [string]$Status = "INFO",
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Status] $Message" -ForegroundColor $Color
}

function Test-FileExists {
    param([string]$Path, [string]$Description)
    if (Test-Path $Path) {
        Write-Status "✅ $Description" "OK" $Green
        return $true
    } else {
        Write-Status "❌ $Description - BRAK" "ERROR" $Red
        return $false
    }
}

function Get-PackageJsonContent {
    param([string]$Path)
    try {
        if (Test-Path $Path) {
            $content = Get-Content $Path -Raw | ConvertFrom-Json
            return $content
        }
        return $null
    } catch {
        Write-Status "❌ Błąd odczytu $Path : $($_.Exception.Message)" "ERROR" $Red
        return $null
    }
}

Write-Host "=== DIAGNOZA INFINICORECIPHER ===" -ForegroundColor $Cyan
Write-Host ""

# Sprawdzenie struktury projektu
Write-Status "🔍 SPRAWDZANIE STRUKTURY PROJEKTU" "INFO" $Cyan

$projectRoot = Get-Location
Write-Status "Katalog projektu: $projectRoot" "INFO" $Blue

# Sprawdzenie głównych plików
$mainFiles = @(
    @{ Path = "package.json"; Desc = "Root package.json" },
    @{ Path = "frontend/package.json"; Desc = "Frontend package.json" },
    @{ Path = "backend/package.json"; Desc = "Backend package.json" },
    @{ Path = "frontend/src/main.jsx"; Desc = "Frontend entry point" },
    @{ Path = "backend/server.js"; Desc = "Backend entry point" }
)

foreach ($file in $mainFiles) {
    Test-FileExists -Path $file.Path -Description $file.Desc
}

Write-Host ""

# Sprawdzenie package.json
Write-Status "📦 ANALIZA PACKAGE.JSON" "INFO" $Cyan

# Root package.json
$rootPkg = Get-PackageJsonContent "package.json"
if ($rootPkg) {
    Write-Status "Root package.json:" "INFO" $Blue
    if ($rootPkg.scripts) {
        Write-Status "  Dostępne skrypty:" "INFO" $Yellow
        $rootPkg.scripts.PSObject.Properties | ForEach-Object {
            Write-Status "    $($_.Name): $($_.Value)" "INFO" $Yellow
        }
    }
}

# Frontend package.json
$frontendPkg = Get-PackageJsonContent "frontend/package.json"
if ($frontendPkg) {
    Write-Status "Frontend package.json:" "INFO" $Blue
    if ($frontendPkg.scripts) {
        Write-Status "  Skrypty frontend:" "INFO" $Yellow
        $frontendPkg.scripts.PSObject.Properties | ForEach-Object {
            Write-Status "    $($_.Name): $($_.Value)" "INFO" $Yellow
        }
    }
}

# Backend package.json
$backendPkg = Get-PackageJsonContent "backend/package.json"
if ($backendPkg) {
    Write-Status "Backend package.json:" "INFO" $Blue
    if ($backendPkg.scripts) {
        Write-Status "  Skrypty backend:" "INFO" $Yellow
        $backendPkg.scripts.PSObject.Properties | ForEach-Object {
            Write-Status "    $($_.Name): $($_.Value)" "INFO" $Yellow
        }
    }
}

Write-Host ""

# Sprawdzenie node_modules
Write-Status "📁 SPRAWDZANIE NODE_MODULES" "INFO" $Cyan

$nodeModulesChecks = @(
    @{ Path = "node_modules"; Desc = "Root node_modules" },
    @{ Path = "frontend/node_modules"; Desc = "Frontend node_modules" },
    @{ Path = "backend/node_modules"; Desc = "Backend node_modules" }
)

foreach ($check in $nodeModulesChecks) {
    Test-FileExists -Path $check.Path -Description $check.Desc
}

Write-Host ""

# Test uruchomienia - sprawdzenie błędów
Write-Status "🚀 TEST URUCHOMIENIA Z DIAGNOSTYKĄ" "INFO" $Cyan

# Test backend
Write-Status "Testowanie backendu..." "INFO" $Yellow
try {
    $backendTest = Start-Process -FilePath "npm" -ArgumentList "run", "dev:backend" -WorkingDirectory $projectRoot -PassThru -WindowStyle Hidden
    Start-Sleep -Seconds 5
    
    if (-not $backendTest.HasExited) {
        Write-Status "✅ Backend uruchomił się (proces aktywny)" "OK" $Green
        $backendTest.Kill()
    } else {
        Write-Status "❌ Backend zakończył się natychmiast (kod: $($backendTest.ExitCode))" "ERROR" $Red
    }
} catch {
    Write-Status "❌ Błąd uruchomienia backendu: $($_.Exception.Message)" "ERROR" $Red
}

# Test frontend
Write-Status "Testowanie frontendu..." "INFO" $Yellow
try {
    $frontendTest = Start-Process -FilePath "npm" -ArgumentList "run", "dev:frontend" -WorkingDirectory $projectRoot -PassThru -WindowStyle Hidden
    Start-Sleep -Seconds 5
    
    if (-not $frontendTest.HasExited) {
        Write-Status "✅ Frontend uruchomił się (proces aktywny)" "OK" $Green
        $frontendTest.Kill()
    } else {
        Write-Status "❌ Frontend zakończył się natychmiast (kod: $($frontendTest.ExitCode))" "ERROR" $Red
    }
} catch {
    Write-Status "❌ Błąd uruchomienia frontendu: $($_.Exception.Message)" "ERROR" $Red
}

Write-Host ""

# Sprawdzenie portów
Write-Status "🌐 SPRAWDZANIE PORTÓW" "INFO" $Cyan

$ports = @(3000, 5000)
foreach ($port in $ports) {
    try {
        $connection = Test-NetConnection -ComputerName "localhost" -Port $port -WarningAction SilentlyContinue
        if ($connection.TcpTestSucceeded) {
            Write-Status "⚠️  Port $port jest zajęty" "WARNING" $Yellow
        } else {
            Write-Status "✅ Port $port jest wolny" "OK" $Green
        }
    } catch {
        Write-Status "✅ Port $port jest wolny" "OK" $Green
    }
}

Write-Host ""

# Rekomendacje naprawy
Write-Status "🔧 REKOMENDACJE NAPRAWY" "INFO" $Cyan

Write-Status "1. Sprawdź logi błędów:" "INFO" $Yellow
Write-Status "   npm run dev:backend 2>&1 | Tee-Object backend-error.log" "INFO" $Blue
Write-Status "   npm run dev:frontend 2>&1 | Tee-Object frontend-error.log" "INFO" $Blue

Write-Status "2. Sprawdź czy wszystkie zależności są zainstalowane:" "INFO" $Yellow
Write-Status "   npm run install:all" "INFO" $Blue

Write-Status "3. Wyczyść cache i reinstaluj:" "INFO" $Yellow
Write-Status "   npm cache clean --force" "INFO" $Blue
Write-Status "   Remove-Item node_modules -Recurse -Force" "INFO" $Blue
Write-Status "   Remove-Item frontend/node_modules -Recurse -Force" "INFO" $Blue
Write-Status "   Remove-Item backend/node_modules -Recurse -Force" "INFO" $Blue
Write-Status "   npm run install:all" "INFO" $Blue

Write-Status "4. Sprawdź wersje Node.js i npm:" "INFO" $Yellow
Write-Status "   node --version" "INFO" $Blue
Write-Status "   npm --version" "INFO" $Blue

Write-Host ""
Write-Status "=== KONIEC DIAGNOZY ===" "INFO" $Cyan