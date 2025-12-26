# Setup-InfinicocipherProject.ps1
# Główny skrypt do pełnej konfiguracji projektu Infinicorecipher

param(
    [string]$TargetPath = "D:\Infinicorecipher-Startup",
    [switch]$SkipCopy = $false,
    [switch]$SkipCheck = $false,
    [switch]$SkipInstall = $false,
    [switch]$AutoStart = $false,
    [switch]$Force = $false
)

# Kolory dla lepszej czytelności
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Magenta = "Magenta"

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor $Cyan
    Write-Host $Title.ToUpper().PadLeft(($Title.Length + 60) / 2) -ForegroundColor $Cyan
    Write-Host "=" * 60 -ForegroundColor $Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$StepNumber, [string]$Description)
    Write-Host "🔸 KROK $StepNumber`: $Description" -ForegroundColor $Magenta
    Write-Host ""
}

function Test-Prerequisites {
    Write-Step "0" "Sprawdzanie wymagań systemowych"
    
    $AllGood = $true
    
    # Sprawdź Node.js
    try {
        $NodeVersion = node --version 2>$null
        if ($NodeVersion) {
            Write-Host "✅ Node.js: $NodeVersion" -ForegroundColor $Green
        } else {
            throw "Node.js nie znaleziony"
        }
    } catch {
        Write-Host "❌ Node.js nie jest zainstalowany" -ForegroundColor $Red
        Write-Host "   Pobierz z: https://nodejs.org/" -ForegroundColor $Yellow
        $AllGood = $false
    }
    
    # Sprawdź npm
    try {
        $NpmVersion = npm --version 2>$null
        if ($NpmVersion) {
            Write-Host "✅ npm: v$NpmVersion" -ForegroundColor $Green
        } else {
            throw "npm nie znaleziony"
        }
    } catch {
        Write-Host "❌ npm nie jest dostępny" -ForegroundColor $Red
        $AllGood = $false
    }
    
    # Sprawdź Git (opcjonalnie)
    try {
        $GitVersion = git --version 2>$null
        if ($GitVersion) {
            Write-Host "✅ $GitVersion" -ForegroundColor $Green
        }
    } catch {
        Write-Host "⚠️  Git nie jest zainstalowany (opcjonalny)" -ForegroundColor $Yellow
    }
    
    # Sprawdź dostępne miejsce na dysku
    $Drive = Split-Path $TargetPath -Qualifier
    $DriveInfo = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $Drive }
    
    if ($DriveInfo) {
        $FreeSpaceGB = [math]::Round($DriveInfo.FreeSpace / 1GB, 2)
        if ($FreeSpaceGB -gt 1) {
            Write-Host "✅ Dostępne miejsce na dysku $Drive`: $FreeSpaceGB GB" -ForegroundColor $Green
        } else {
            Write-Host "⚠️  Mało miejsca na dysku $Drive`: $FreeSpaceGB GB" -ForegroundColor $Yellow
        }
    }
    
    Write-Host ""
    return $AllGood
}

# Główna logika
Write-Header "KONFIGURACJA PROJEKTU INFINICORECIPHER"

Write-Host "🎯 Cel instalacji: $TargetPath" -ForegroundColor $Cyan
Write-Host "📅 Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor $Cyan
Write-Host ""

# Sprawdź wymagania systemowe
if (-not (Test-Prerequisites)) {
    Write-Host "❌ Nie wszystkie wymagania są spełnione. Zainstaluj brakujące komponenty i spróbuj ponownie." -ForegroundColor $Red
    exit 1
}

# KROK 1: Kopiowanie plików
if (-not $SkipCopy) {
    Write-Step "1" "Kopiowanie plików projektu"
    
    $CopyParams = @{
        TargetPath = $TargetPath
    }
    
    if ($Force) {
        $CopyParams.Force = $true
    }
    
    try {
        & ".\InfinicocipherProject.ps1" @CopyParams
        
        if ($LASTEXITCODE -ne 0) {
            throw "Kopiowanie zakończone z błędami"
        }
        
        Write-Host "✅ Pliki skopiowane pomyślnie" -ForegroundColor $Green
    } catch {
        Write-Host "❌ Błąd podczas kopiowania: $($_.Exception.Message)" -ForegroundColor $Red
        exit 1
    }
} else {
    Write-Host "⏭️  Pomijanie kopiowania plików (użyto -SkipCopy)" -ForegroundColor $Yellow
}

# KROK 2: Sprawdzenie kompletności
if (-not $SkipCheck) {
    Write-Step "2" "Sprawdzanie kompletności projektu"
    
    try {
        & ".\Check-InfinicocipherFiles.ps1" -TargetPath $TargetPath -CreateMissing
        
        $CheckResult = $LASTEXITCODE
        
        if ($CheckResult -eq 0) {
            Write-Host "✅ Projekt jest kompletny" -ForegroundColor $Green
        } elseif ($CheckResult -eq 1) {
            Write-Host "⚠️  Projekt prawie kompletny - może działać" -ForegroundColor $Yellow
        } else {
            Write-Host "❌ Projekt niekompletny - może nie działać poprawnie" -ForegroundColor $Red
            
            if (-not $Force) {
                $Response = Read-Host "Czy chcesz kontynuować mimo błędów? (y/N)"
                if ($Response -ne "y" -and $Response -ne "Y") {
                    exit 1
                }
            }
        }
    } catch {
        Write-Host "❌ Błąd podczas sprawdzania: $($_.Exception.Message)" -ForegroundColor $Red
        exit 1
    }
} else {
    Write-Host "⏭️  Pomijanie sprawdzania kompletności (użyto -SkipCheck)" -ForegroundColor $Yellow
}

# KROK 3: Instalacja zależności
if (-not $SkipInstall) {
    Write-Step "3" "Instalacja zależności npm"
    
    if (-not (Test-Path $TargetPath)) {
        Write-Host "❌ Folder projektu nie istnieje: $TargetPath" -ForegroundColor $Red
        exit 1
    }
    
    Push-Location $TargetPath
    
    try {
        # Sprawdź czy package.json istnieje
        if (-not (Test-Path "package.json")) {
            Write-Host "❌ Brak pliku package.json w folderze głównym" -ForegroundColor $Red
            throw "Brak package.json"
        }
        
        Write-Host "📦 Instalowanie zależności głównych..." -ForegroundColor $Yellow
        npm install
        
        if ($LASTEXITCODE -ne 0) {
            throw "Błąd instalacji zależności głównych"
        }
        
        # Instalacja zależności frontend
        if (Test-Path "frontend/package.json") {
            Write-Host "📦 Instalowanie zależności frontend..." -ForegroundColor $Yellow
            Set-Location "frontend"
            npm install
            
            if ($LASTEXITCODE -ne 0) {
                throw "Błąd instalacji zależności frontend"
            }
            
            Set-Location ".."
        }
        
        # Instalacja zależności backend
        if (Test-Path "backend/package.json") {
            Write-Host "📦 Instalowanie zależności backend..." -ForegroundColor $Yellow
            Set-Location "backend"
            npm install
            
            if ($LASTEXITCODE -ne 0) {
                throw "Błąd instalacji zależności backend"
            }
            
            Set-Location ".."
        }
        
        Write-Host "✅ Wszystkie zależności zainstalowane pomyślnie" -ForegroundColor $Green
        
    } catch {
        Write-Host "❌ Błąd podczas instalacji: $($_.Exception.Message)" -ForegroundColor $Red
        Pop-Location
        exit 1
    } finally {
        Pop-Location
    }
} else {
    Write-Host "⏭️  Pomijanie instalacji zależności (użyto -SkipInstall)" -ForegroundColor $Yellow
}

# KROK 4: Finalizacja
Write-Step "4" "Finalizacja konfiguracji"

# Sprawdź czy wszystko jest gotowe
$ReadyToRun = $true

Push-Location $TargetPath

try {
    # Sprawdź node_modules
    if (-not (Test-Path "node_modules") -and -not $SkipInstall) {
        Write-Host "⚠️  Brak folderu node_modules" -ForegroundColor $Yellow
        $ReadyToRun = $false
    }
    
    if (-not (Test-Path "frontend/node_modules") -and -not $SkipInstall) {
        Write-Host "⚠️  Brak folderu frontend/node_modules" -ForegroundColor $Yellow
        $ReadyToRun = $false
    }
    
    if (-not (Test-Path "backend/node_modules") -and -not $SkipInstall) {
        Write-Host "⚠️  Brak folderu backend/node_modules" -ForegroundColor $Yellow
        $ReadyToRun = $false
    }
    
    # Sprawdź kluczowe pliki
    $CriticalFiles = @(
        "package.json",
        "frontend/src/main.tsx",
        "backend/src/server.ts"
    )
    
    foreach ($File in $CriticalFiles) {
        if (-not (Test-Path $File)) {
            Write-Host "❌ Brak krytycznego pliku: $File" -ForegroundColor $Red
            $ReadyToRun = $false
        }
    }
    
} finally {
    Pop-Location
}

# Podsumowanie końcowe
Write-Header "PODSUMOWANIE KONFIGURACJI"

if ($ReadyToRun) {
    Write-Host "🎉 PROJEKT GOTOWY DO URUCHOMIENIA!" -ForegroundColor $Green
    Write-Host ""
    Write-Host "📋 POLECENIA DO URUCHOMIENIA:" -ForegroundColor $Cyan
    Write-Host "cd `"$TargetPath`"" -ForegroundColor $Yellow
    Write-Host "npm run dev" -ForegroundColor $Yellow
    Write-Host ""
    Write-Host "🌐 Aplikacja będzie dostępna pod adresem:" -ForegroundColor $Cyan
    Write-Host "Frontend: http://localhost:3000" -ForegroundColor $Yellow
    Write-Host "Backend:  http://localhost:5000" -ForegroundColor $Yellow
    
    if ($AutoStart) {
        Write-Host ""
        Write-Host "🚀 Automatyczne uruchamianie..." -ForegroundColor $Magenta
        
        Push-Location $TargetPath
        try {
            Start-Process "npm" -ArgumentList "run", "dev" -NoNewWindow
            Write-Host "✅ Projekt uruchomiony!" -ForegroundColor $Green
        } catch {
            Write-Host "❌ Błąd uruchamiania: $($_.Exception.Message)" -ForegroundColor $Red
        } finally {
            Pop-Location
        }
    }
    
} else {
    Write-Host "⚠️  PROJEKT WYMAGA DODATKOWEJ KONFIGURACJI" -ForegroundColor $Yellow
    Write-Host "Sprawdź komunikaty błędów powyżej i uzupełnij brakujące elementy." -ForegroundColor $Yellow
}

Write-Host ""
Write-Host "📚 DODATKOWE INFORMACJE:" -ForegroundColor $Cyan
Write-Host "- Dokumentacja: $TargetPath\docs\README.md" -ForegroundColor $Yellow
Write-Host "- Konfiguracja: $TargetPath\docs\SETUP.md" -ForegroundColor $Yellow
Write-Host "- Dostępność: $TargetPath\docs\ACCESSIBILITY.md" -ForegroundColor $Yellow

Write-Host ""
Write-Host "=== KONFIGURACJA ZAKOŃCZONA ===" -ForegroundColor $Cyan