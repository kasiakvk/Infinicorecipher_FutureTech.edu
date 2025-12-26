# Complete-Fix-InfiniCoreCipher.ps1
# Kompleksowe rozwiązanie problemów z projektem InfiniCoreCipher

param(
    [string]$ProjectPath = "C:\InfiniCoreCipher-Startup",
    [switch]$Force = $false,
    [switch]$SkipExecutionPolicy = $false
)

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Magenta = "Magenta"

Write-Host "🚀 KOMPLEKSOWA NAPRAWA INFINICORECIPHER" -ForegroundColor $Cyan
Write-Host "=======================================" -ForegroundColor $Cyan
Write-Host "Projekt: $ProjectPath" -ForegroundColor $Yellow
Write-Host ""

# Funkcja sprawdzania uprawnień administratora
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# KROK 1: NAPRAWA EXECUTION POLICY
Write-Host "🔧 KROK 1: NAPRAWA EXECUTION POLICY" -ForegroundColor $Cyan
Write-Host ""

if (-not $SkipExecutionPolicy) {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    Write-Host "Aktualna polityka: $currentPolicy" -ForegroundColor $Yellow
    
    if ($currentPolicy -eq "Restricted" -or $currentPolicy -eq "Undefined") {
        Write-Host "❌ Execution Policy blokuje uruchamianie skryptów" -ForegroundColor $Red
        Write-Host "🔧 Naprawianie..." -ForegroundColor $Yellow
        
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Write-Host "✅ Execution Policy naprawiona (RemoteSigned dla CurrentUser)" -ForegroundColor $Green
        } catch {
            Write-Host "❌ Błąd naprawy Execution Policy: $($_.Exception.Message)" -ForegroundColor $Red
            Write-Host ""
            Write-Host "💡 RĘCZNA NAPRAWA:" -ForegroundColor $Yellow
            Write-Host "Uruchom PowerShell jako Administrator i wykonaj:" -ForegroundColor $Yellow
            Write-Host "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor $Green
            Write-Host ""
        }
    } else {
        Write-Host "✅ Execution Policy jest poprawna" -ForegroundColor $Green
    }
} else {
    Write-Host "⏭️  Pomijanie naprawy Execution Policy" -ForegroundColor $Yellow
}

Write-Host ""

# KROK 2: SPRAWDZENIE PROJEKTU
Write-Host "🔍 KROK 2: SPRAWDZENIE PROJEKTU" -ForegroundColor $Cyan
Write-Host ""

if (-not (Test-Path $ProjectPath)) {
    Write-Host "❌ Folder projektu nie istnieje: $ProjectPath" -ForegroundColor $Red
    Write-Host ""
    Write-Host "💡 MOŻLIWE LOKALIZACJE:" -ForegroundColor $Yellow
    
    $PossiblePaths = @(
        "C:\InfiniCoreCipher-Startup",
        "D:\InfiniCoreCipher-Startup", 
        "C:\InfiniCodeCipher",
        "D:\InfiniCodeCipher",
        "$env:USERPROFILE\Desktop\InfiniCoreCipher-Startup",
        "$env:USERPROFILE\Documents\InfiniCoreCipher-Startup"
    )
    
    $FoundPaths = @()
    foreach ($Path in $PossiblePaths) {
        if (Test-Path $Path) {
            $FoundPaths += $Path
            Write-Host "   ✅ Znaleziono: $Path" -ForegroundColor $Green
        }
    }
    
    if ($FoundPaths.Count -eq 0) {
        Write-Host "❌ Nie znaleziono projektu w żadnej lokalizacji" -ForegroundColor $Red
        Write-Host ""
        Write-Host "🆕 TWORZENIE NOWEGO PROJEKTU:" -ForegroundColor $Cyan
        Write-Host "Użyj skryptu: Create-Full-Project-Setup.ps1" -ForegroundColor $Yellow
        exit 1
    } elseif ($FoundPaths.Count -eq 1) {
        $ProjectPath = $FoundPaths[0]
        Write-Host "🎯 Używanie znalezionego projektu: $ProjectPath" -ForegroundColor $Green
    } else {
        Write-Host "⚠️  Znaleziono wiele projektów:" -ForegroundColor $Yellow
        for ($i = 0; $i -lt $FoundPaths.Count; $i++) {
            Write-Host "   $($i + 1). $($FoundPaths[$i])" -ForegroundColor $Yellow
        }
        Write-Host ""
        Write-Host "Użyj parametru -ProjectPath aby wybrać konkretną lokalizację" -ForegroundColor $Yellow
        $ProjectPath = $FoundPaths[0]
        Write-Host "🎯 Używanie pierwszego znalezionego: $ProjectPath" -ForegroundColor $Green
    }
    Write-Host ""
}

Push-Location $ProjectPath

try {
    Write-Host "📁 Projekt: $ProjectPath" -ForegroundColor $Green
    Write-Host ""
    
    # KROK 3: NAPRAWA PLIKÓW JSON
    Write-Host "🔧 KROK 3: NAPRAWA PLIKÓW JSON" -ForegroundColor $Cyan
    Write-Host ""
    
    $JsonFiles = @(
        "package.json",
        "frontend/package.json", 
        "backend/package.json",
        "frontend/tsconfig.json",
        "backend/tsconfig.json"
    )
    
    $FixedFiles = 0
    $ErrorFiles = 0
    
    foreach ($JsonFile in $JsonFiles) {
        Write-Host "📄 Sprawdzanie: $JsonFile" -ForegroundColor $Yellow
        
        if (-not (Test-Path $JsonFile)) {
            Write-Host "   ⚠️  Plik nie istnieje" -ForegroundColor $Yellow
            continue
        }
        
        try {
            # Sprawdź czy plik ma BOM
            $bytes = [System.IO.File]::ReadAllBytes($JsonFile)
            $hasBOM = $false
            
            if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
                $hasBOM = $true
                Write-Host "   ❌ Wykryto BOM (Byte Order Mark)" -ForegroundColor $Red
            }
            
            # Odczytaj zawartość
            $content = Get-Content $JsonFile -Raw -Encoding UTF8
            
            # Sprawdź czy to poprawny JSON
            try {
                $jsonObject = $content | ConvertFrom-Json
                if (-not $hasBOM) {
                    Write-Host "   ✅ Plik JSON jest poprawny" -ForegroundColor $Green
                    continue
                }
            } catch {
                Write-Host "   ❌ Błąd parsowania JSON: $($_.Exception.Message)" -ForegroundColor $Red
            }
            
            # Napraw plik
            Write-Host "   🔧 Naprawianie pliku..." -ForegroundColor $Yellow
            
            # Usuń BOM i zapisz ponownie
            $cleanContent = $content.TrimStart([char]0xFEFF)
            
            # Sprawdź czy naprawiona zawartość jest poprawnym JSON
            try {
                $testJson = $cleanContent | ConvertFrom-Json
                
                # Utwórz kopię zapasową
                $backupFile = "$JsonFile.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                Copy-Item $JsonFile $backupFile
                
                # Zapisz bez BOM
                [System.IO.File]::WriteAllText($JsonFile, $cleanContent, [System.Text.UTF8Encoding]::new($false))
                
                Write-Host "   ✅ Plik naprawiony (kopia: $backupFile)" -ForegroundColor $Green
                $FixedFiles++
                
            } catch {
                Write-Host "   ❌ Nie można naprawić pliku: $($_.Exception.Message)" -ForegroundColor $Red
                $ErrorFiles++
            }
            
        } catch {
            Write-Host "   ❌ Błąd przetwarzania pliku: $($_.Exception.Message)" -ForegroundColor $Red
            $ErrorFiles++
        }
    }
    
    Write-Host ""
    Write-Host "📊 Naprawione pliki JSON: $FixedFiles" -ForegroundColor $(if($FixedFiles -gt 0){$Green}else{$Yellow})
    Write-Host "📊 Pliki z błędami: $ErrorFiles" -ForegroundColor $(if($ErrorFiles -eq 0){$Green}else{$Red})
    Write-Host ""
    
    # KROK 4: SPRAWDZENIE STRUKTURY PROJEKTU
    Write-Host "🔍 KROK 4: SPRAWDZENIE STRUKTURY PROJEKTU" -ForegroundColor $Cyan
    Write-Host ""
    
    $CriticalFiles = @(
        "package.json",
        "frontend/package.json",
        "backend/package.json",
        "frontend/src/main.tsx",
        "backend/src/server.ts"
    )
    
    $MissingCritical = @()
    $ExistingCritical = 0
    
    foreach ($File in $CriticalFiles) {
        if (Test-Path $File) {
            Write-Host "   ✅ $File" -ForegroundColor $Green
            $ExistingCritical++
        } else {
            Write-Host "   ❌ $File" -ForegroundColor $Red
            $MissingCritical += $File
        }
    }
    
    Write-Host ""
    Write-Host "📊 Krytyczne pliki: $ExistingCritical/$($CriticalFiles.Count)" -ForegroundColor $(
        if ($MissingCritical.Count -eq 0) { $Green }
        elseif ($MissingCritical.Count -le 2) { $Yellow }
        else { $Red }
    )
    
    # KROK 5: SPRAWDZENIE NODE_MODULES
    Write-Host ""
    Write-Host "📦 KROK 5: SPRAWDZENIE ZALEŻNOŚCI" -ForegroundColor $Cyan
    Write-Host ""
    
    $NodeModulesStatus = @{
        "Root" = Test-Path "node_modules"
        "Frontend" = Test-Path "frontend/node_modules"
        "Backend" = Test-Path "backend/node_modules"
    }
    
    foreach ($Location in $NodeModulesStatus.Keys) {
        $Status = $NodeModulesStatus[$Location]
        if ($Status) {
            Write-Host "   ✅ $Location node_modules" -ForegroundColor $Green
        } else {
            Write-Host "   ❌ $Location node_modules (brak)" -ForegroundColor $Red
        }
    }
    
    $MissingNodeModules = ($NodeModulesStatus.Values | Where-Object { $_ -eq $false }).Count
    
    # KROK 6: TEST URUCHOMIENIA
    Write-Host ""
    Write-Host "🚀 KROK 6: TEST GOTOWOŚCI" -ForegroundColor $Cyan
    Write-Host ""
    
    $CanRun = $true
    $Issues = @()
    
    # Sprawdź Node.js
    try {
        $NodeVersion = node --version 2>$null
        if ($NodeVersion) {
            Write-Host "   ✅ Node.js: $NodeVersion" -ForegroundColor $Green
        } else {
            Write-Host "   ❌ Node.js nie jest dostępny" -ForegroundColor $Red
            $CanRun = $false
            $Issues += "Zainstaluj Node.js z https://nodejs.org/"
        }
    } catch {
        Write-Host "   ❌ Node.js nie jest dostępny" -ForegroundColor $Red
        $CanRun = $false
        $Issues += "Zainstaluj Node.js z https://nodejs.org/"
    }
    
    # Sprawdź npm
    try {
        $NpmVersion = npm --version 2>$null
        if ($NpmVersion) {
            Write-Host "   ✅ npm: v$NpmVersion" -ForegroundColor $Green
        } else {
            Write-Host "   ❌ npm nie jest dostępny" -ForegroundColor $Red
            $CanRun = $false
            $Issues += "npm powinien być zainstalowany z Node.js"
        }
    } catch {
        Write-Host "   ❌ npm nie jest dostępny" -ForegroundColor $Red
        $CanRun = $false
        $Issues += "npm powinien być zainstalowany z Node.js"
    }
    
    # Sprawdź krytyczne pliki
    if ($MissingCritical.Count -gt 0) {
        Write-Host "   ❌ Brakuje krytycznych plików: $($MissingCritical.Count)" -ForegroundColor $Red
        $CanRun = $false
        $Issues += "Uzupełnij brakujące pliki lub użyj Create-Full-Project-Setup.ps1"
    } else {
        Write-Host "   ✅ Wszystkie krytyczne pliki obecne" -ForegroundColor $Green
    }
    
    # Sprawdź node_modules
    if ($MissingNodeModules -gt 0) {
        Write-Host "   ⚠️  Brakuje zależności w $MissingNodeModules lokalizacjach" -ForegroundColor $Yellow
        $Issues += "Uruchom: npm run install:all"
    } else {
        Write-Host "   ✅ Wszystkie zależności zainstalowane" -ForegroundColor $Green
    }
    
    # PODSUMOWANIE I INSTRUKCJE
    Write-Host ""
    Write-Host "📋 PODSUMOWANIE NAPRAWY" -ForegroundColor $Cyan
    Write-Host "======================" -ForegroundColor $Cyan
    
    if ($CanRun -and $Issues.Count -eq 0) {
        Write-Host "🎉 PROJEKT GOTOWY DO URUCHOMIENIA!" -ForegroundColor $Green
        Write-Host ""
        Write-Host "🚀 URUCHOMIENIE:" -ForegroundColor $Cyan
        Write-Host "cd `"$ProjectPath`"" -ForegroundColor $Yellow
        Write-Host "npm run dev" -ForegroundColor $Green
        Write-Host ""
        Write-Host "🌐 APLIKACJA BĘDZIE DOSTĘPNA:" -ForegroundColor $Cyan
        Write-Host "   Frontend: http://localhost:3000" -ForegroundColor $Yellow
        Write-Host "   Backend:  http://localhost:5000" -ForegroundColor $Yellow
        Write-Host "   API:      http://localhost:5000/api" -ForegroundColor $Yellow
        
    } elseif ($CanRun -and $Issues.Count -le 2) {
        Write-Host "⚠️  PROJEKT PRAWIE GOTOWY" -ForegroundColor $Yellow
        Write-Host ""
        Write-Host "🔧 WYMAGANE DZIAŁANIA:" -ForegroundColor $Cyan
        foreach ($Issue in $Issues) {
            Write-Host "   • $Issue" -ForegroundColor $Yellow
        }
        Write-Host ""
        Write-Host "Po naprawie uruchom:" -ForegroundColor $Yellow
        Write-Host "npm run dev" -ForegroundColor $Green
        
    } else {
        Write-Host "❌ PROJEKT WYMAGA NAPRAWY" -ForegroundColor $Red
        Write-Host ""
        Write-Host "🔧 WYMAGANE DZIAŁANIA:" -ForegroundColor $Cyan
        foreach ($Issue in $Issues) {
            Write-Host "   • $Issue" -ForegroundColor $Red
        }
        
        if ($MissingCritical.Count -gt 2) {
            Write-Host ""
            Write-Host "💡 ZALECENIE:" -ForegroundColor $Yellow
            Write-Host "Użyj skryptu Create-Full-Project-Setup.ps1 do utworzenia nowego projektu" -ForegroundColor $Yellow
        }
    }
    
    # Dodatkowe narzędzia
    Write-Host ""
    Write-Host "🛠️  DOSTĘPNE NARZĘDZIA:" -ForegroundColor $Cyan
    Write-Host "   Check-InfinicocipherFiles.ps1 - Sprawdzenie kompletności" -ForegroundColor $Yellow
    Write-Host "   Clean-InfinicocipherFiles.ps1 - Czyszczenie projektu" -ForegroundColor $Yellow
    Write-Host "   Create-Full-Project-Setup.ps1 - Nowy projekt od podstaw" -ForegroundColor $Yellow
    Write-Host "   Analyze-And-Fix-Project.ps1 - Analiza i naprawa" -ForegroundColor $Yellow
    
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "=== KONIEC KOMPLEKSOWEJ NAPRAWY ===" -ForegroundColor $Cyan