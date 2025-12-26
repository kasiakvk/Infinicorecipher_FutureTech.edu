# Analyze-And-Fix-Project.ps1
# Analiza i naprawa projektu InfiniCoreCipher-Startup

param(
    [string]$ProjectPath = "C:\InfiniCoreCipher-Startup",
    [switch]$AutoFix = $false,
    [switch]$CreateMissing = $false,
    [switch]$InstallDependencies = $false
)

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Magenta = "Magenta"

Write-Host "🔍 ANALIZA I NAPRAWA PROJEKTU INFINICORECIPHER" -ForegroundColor $Cyan
Write-Host "===============================================" -ForegroundColor $Cyan
Write-Host "Ścieżka projektu: $ProjectPath" -ForegroundColor $Yellow
Write-Host "Auto-naprawa: $(if($AutoFix){'WŁĄCZONA'}else{'WYŁĄCZONA'})" -ForegroundColor $(if($AutoFix){$Green}else{$Yellow})
Write-Host ""

# Sprawdź czy folder istnieje
if (-not (Test-Path $ProjectPath)) {
    Write-Host "❌ BŁĄD: Folder projektu nie istnieje!" -ForegroundColor $Red
    Write-Host "Ścieżka: $ProjectPath" -ForegroundColor $Red
    
    if ($CreateMissing) {
        Write-Host "📁 Tworzenie folderu projektu..." -ForegroundColor $Yellow
        try {
            New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null
            Write-Host "✅ Folder utworzony pomyślnie" -ForegroundColor $Green
        } catch {
            Write-Host "❌ Błąd tworzenia folderu: $($_.Exception.Message)" -ForegroundColor $Red
            exit 1
        }
    } else {
        Write-Host "💡 Użyj parametru -CreateMissing aby utworzyć folder" -ForegroundColor $Yellow
        exit 1
    }
}

# Przejdź do folderu projektu
Push-Location $ProjectPath

try {
    # Analiza struktury projektu
    Write-Host "📋 ANALIZA STRUKTURY PROJEKTU" -ForegroundColor $Cyan
    Write-Host ""
    
    # Sprawdź zawartość głównego folderu
    $RootContents = Get-ChildItem -ErrorAction SilentlyContinue
    Write-Host "📁 Zawartość głównego folderu ($($RootContents.Count) elementów):" -ForegroundColor $Yellow
    
    if ($RootContents.Count -eq 0) {
        Write-Host "   📋 Folder pusty" -ForegroundColor $Red
    } else {
        $RootContents | ForEach-Object {
            $Type = if ($_.PSIsContainer) { "📁" } else { "📄" }
            $Size = if (-not $_.PSIsContainer) { " ($([math]::Round($_.Length/1KB, 1)) KB)" } else { "" }
            Write-Host "   $Type $($_.Name)$Size" -ForegroundColor $Yellow
        }
    }
    
    Write-Host ""
    
    # Definicja oczekiwanej struktury projektu
    $ExpectedStructure = @{
        "Pliki główne" = @(
            @{ Name = "package.json"; Type = "File"; Critical = $true; Description = "Główny plik konfiguracji npm" },
            @{ Name = "README.md"; Type = "File"; Critical = $true; Description = "Dokumentacja projektu" },
            @{ Name = ".gitignore"; Type = "File"; Critical = $false; Description = "Ignorowane pliki Git" },
            @{ Name = "docker-compose.yml"; Type = "File"; Critical = $false; Description = "Konfiguracja Docker" }
        )
        "Foldery główne" = @(
            @{ Name = "frontend"; Type = "Folder"; Critical = $true; Description = "Aplikacja React/Vue" },
            @{ Name = "backend"; Type = "Folder"; Critical = $true; Description = "API Node.js/Express" },
            @{ Name = "database"; Type = "Folder"; Critical = $false; Description = "Schematy i migracje bazy danych" },
            @{ Name = "docs"; Type = "Folder"; Critical = $false; Description = "Dokumentacja projektu" },
            @{ Name = "config"; Type = "Folder"; Critical = $false; Description = "Pliki konfiguracyjne" }
        )
        "Frontend" = @(
            @{ Name = "frontend/package.json"; Type = "File"; Critical = $true; Description = "Konfiguracja frontend" },
            @{ Name = "frontend/index.html"; Type = "File"; Critical = $true; Description = "Główny plik HTML" },
            @{ Name = "frontend/src"; Type = "Folder"; Critical = $true; Description = "Kod źródłowy frontend" },
            @{ Name = "frontend/src/main.tsx"; Type = "File"; Critical = $true; Description = "Punkt wejścia aplikacji" },
            @{ Name = "frontend/src/App.tsx"; Type = "File"; Critical = $true; Description = "Główny komponent" }
        )
        "Backend" = @(
            @{ Name = "backend/package.json"; Type = "File"; Critical = $true; Description = "Konfiguracja backend" },
            @{ Name = "backend/src"; Type = "Folder"; Critical = $true; Description = "Kod źródłowy backend" },
            @{ Name = "backend/src/server.ts"; Type = "File"; Critical = $true; Description = "Serwer główny" },
            @{ Name = "backend/src/app.ts"; Type = "File"; Critical = $true; Description = "Aplikacja Express" }
        )
    }
    
    # Analiza każdej kategorii
    $Issues = @()
    $TotalItems = 0
    $ExistingItems = 0
    
    foreach ($Category in $ExpectedStructure.Keys) {
        Write-Host "🔍 Sprawdzanie: $Category" -ForegroundColor $Magenta
        
        $CategoryItems = $ExpectedStructure[$Category]
        $CategoryExisting = 0
        
        foreach ($Item in $CategoryItems) {
            $TotalItems++
            $ItemPath = $Item.Name
            $Exists = Test-Path $ItemPath
            
            if ($Exists) {
                $ExistingItems++
                $CategoryExisting++
                Write-Host "   ✅ $($Item.Name) - $($Item.Description)" -ForegroundColor $Green
            } else {
                $Status = if ($Item.Critical) { "❌ KRYTYCZNY" } else { "⚠️  OPCJONALNY" }
                $Color = if ($Item.Critical) { $Red } else { $Yellow }
                Write-Host "   $Status $($Item.Name) - $($Item.Description)" -ForegroundColor $Color
                
                $Issues += @{
                    Category = $Category
                    Item = $Item
                    Type = if ($Item.Critical) { "Critical" } else { "Optional" }
                }
            }
        }
        
        $CategoryPercent = if ($CategoryItems.Count -gt 0) { [math]::Round(($CategoryExisting / $CategoryItems.Count) * 100, 1) } else { 100 }
        Write-Host "   📊 Kompletność: $CategoryExisting/$($CategoryItems.Count) ($CategoryPercent%)" -ForegroundColor $(
            if ($CategoryPercent -eq 100) { $Green }
            elseif ($CategoryPercent -ge 70) { $Yellow }
            else { $Red }
        )
        Write-Host ""
    }
    
    # Podsumowanie analizy
    $CompletionPercent = [math]::Round(($ExistingItems / $TotalItems) * 100, 1)
    $CriticalIssues = ($Issues | Where-Object { $_.Type -eq "Critical" }).Count
    $OptionalIssues = ($Issues | Where-Object { $_.Type -eq "Optional" }).Count
    
    Write-Host "📊 PODSUMOWANIE ANALIZY" -ForegroundColor $Cyan
    Write-Host "   📋 Kompletność ogólna: $ExistingItems/$TotalItems ($CompletionPercent%)" -ForegroundColor $(
        if ($CompletionPercent -eq 100) { $Green }
        elseif ($CompletionPercent -ge 80) { $Yellow }
        else { $Red }
    )
    Write-Host "   ❌ Problemy krytyczne: $CriticalIssues" -ForegroundColor $(if($CriticalIssues -eq 0){$Green}else{$Red})
    Write-Host "   ⚠️  Problemy opcjonalne: $OptionalIssues" -ForegroundColor $(if($OptionalIssues -eq 0){$Green}else{$Yellow})
    Write-Host ""
    
    # Sprawdź zależności npm
    Write-Host "📦 SPRAWDZANIE ZALEŻNOŚCI NPM" -ForegroundColor $Cyan
    
    $NpmIssues = @()
    
    # Sprawdź root package.json
    if (Test-Path "package.json") {
        if (-not (Test-Path "node_modules")) {
            Write-Host "   ❌ Brak node_modules w root" -ForegroundColor $Red
            $NpmIssues += "root"
        } else {
            Write-Host "   ✅ node_modules w root" -ForegroundColor $Green
        }
    }
    
    # Sprawdź frontend
    if (Test-Path "frontend/package.json") {
        if (-not (Test-Path "frontend/node_modules")) {
            Write-Host "   ❌ Brak node_modules w frontend" -ForegroundColor $Red
            $NpmIssues += "frontend"
        } else {
            Write-Host "   ✅ node_modules w frontend" -ForegroundColor $Green
        }
    }
    
    # Sprawdź backend
    if (Test-Path "backend/package.json") {
        if (-not (Test-Path "backend/node_modules")) {
            Write-Host "   ❌ Brak node_modules w backend" -ForegroundColor $Red
            $NpmIssues += "backend"
        } else {
            Write-Host "   ✅ node_modules w backend" -ForegroundColor $Green
        }
    }
    
    Write-Host ""
    
    # Sprawdź czy można uruchomić projekt
    Write-Host "🚀 SPRAWDZANIE GOTOWOŚCI DO URUCHOMIENIA" -ForegroundColor $Cyan
    
    $CanRun = $true
    $RunIssues = @()
    
    # Sprawdź Node.js
    try {
        $NodeVersion = node --version 2>$null
        if ($NodeVersion) {
            Write-Host "   ✅ Node.js: $NodeVersion" -ForegroundColor $Green
        } else {
            Write-Host "   ❌ Node.js nie jest zainstalowany" -ForegroundColor $Red
            $CanRun = $false
            $RunIssues += "Node.js nie zainstalowany"
        }
    } catch {
        Write-Host "   ❌ Node.js nie jest dostępny" -ForegroundColor $Red
        $CanRun = $false
        $RunIssues += "Node.js niedostępny"
    }
    
    # Sprawdź npm
    try {
        $NpmVersion = npm --version 2>$null
        if ($NpmVersion) {
            Write-Host "   ✅ npm: v$NpmVersion" -ForegroundColor $Green
        } else {
            Write-Host "   ❌ npm nie jest dostępny" -ForegroundColor $Red
            $CanRun = $false
            $RunIssues += "npm niedostępny"
        }
    } catch {
        Write-Host "   ❌ npm nie jest dostępny" -ForegroundColor $Red
        $CanRun = $false
        $RunIssues += "npm niedostępny"
    }
    
    # Sprawdź krytyczne pliki
    $CriticalFiles = @("package.json", "frontend/package.json", "backend/package.json")
    foreach ($File in $CriticalFiles) {
        if (-not (Test-Path $File)) {
            Write-Host "   ❌ Brak krytycznego pliku: $File" -ForegroundColor $Red
            $CanRun = $false
            $RunIssues += "Brak $File"
        }
    }
    
    if ($CanRun -and $NpmIssues.Count -eq 0) {
        Write-Host "   🎉 Projekt gotowy do uruchomienia!" -ForegroundColor $Green
    } elseif ($CanRun) {
        Write-Host "   ⚠️  Projekt wymaga instalacji zależności" -ForegroundColor $Yellow
    } else {
        Write-Host "   ❌ Projekt nie jest gotowy do uruchomienia" -ForegroundColor $Red
    }
    
    Write-Host ""
    
    # SEKCJA NAPRAWY
    if ($Issues.Count -gt 0 -or $NpmIssues.Count -gt 0) {
        Write-Host "🔧 PLAN NAPRAWY" -ForegroundColor $Cyan
        Write-Host ""
        
        if ($Issues.Count -gt 0) {
            Write-Host "📋 Brakujące pliki/foldery:" -ForegroundColor $Yellow
            foreach ($Issue in $Issues) {
                $Priority = if ($Issue.Type -eq "Critical") { "🔴 KRYTYCZNY" } else { "🟡 OPCJONALNY" }
                Write-Host "   $Priority $($Issue.Item.Name) - $($Issue.Item.Description)" -ForegroundColor $(if($Issue.Type -eq "Critical"){$Red}else{$Yellow})
            }
            Write-Host ""
        }
        
        if ($NpmIssues.Count -gt 0) {
            Write-Host "📦 Wymagana instalacja npm:" -ForegroundColor $Yellow
            foreach ($Location in $NpmIssues) {
                Write-Host "   📁 $Location - npm install" -ForegroundColor $Yellow
            }
            Write-Host ""
        }
        
        # Auto-naprawa
        if ($AutoFix) {
            Write-Host "🔧 ROZPOCZYNANIE AUTO-NAPRAWY..." -ForegroundColor $Magenta
            Write-Host ""
            
            # Twórz brakujące foldery
            $FolderIssues = $Issues | Where-Object { $_.Item.Type -eq "Folder" }
            foreach ($Issue in $FolderIssues) {
                try {
                    New-Item -ItemType Directory -Path $Issue.Item.Name -Force | Out-Null
                    Write-Host "   ✅ Utworzono folder: $($Issue.Item.Name)" -ForegroundColor $Green
                } catch {
                    Write-Host "   ❌ Błąd tworzenia folderu $($Issue.Item.Name): $($_.Exception.Message)" -ForegroundColor $Red
                }
            }
            
            # Instaluj zależności npm
            if ($InstallDependencies -and $NpmIssues.Count -gt 0) {
                Write-Host "   📦 Instalowanie zależności npm..." -ForegroundColor $Yellow
                
                foreach ($Location in $NpmIssues) {
                    if ($Location -eq "root") {
                        Write-Host "   📁 Instalacja w root..." -ForegroundColor $Yellow
                        try {
                            npm install 2>$null
                            Write-Host "   ✅ Root npm install zakończony" -ForegroundColor $Green
                        } catch {
                            Write-Host "   ❌ Błąd instalacji root: $($_.Exception.Message)" -ForegroundColor $Red
                        }
                    } else {
                        Write-Host "   📁 Instalacja w $Location..." -ForegroundColor $Yellow
                        try {
                            Push-Location $Location
                            npm install 2>$null
                            Write-Host "   ✅ $Location npm install zakończony" -ForegroundColor $Green
                        } catch {
                            Write-Host "   ❌ Błąd instalacji $Location`: $($_.Exception.Message)" -ForegroundColor $Red
                        } finally {
                            Pop-Location
                        }
                    }
                }
            }
        } else {
            Write-Host "💡 INSTRUKCJE NAPRAWY:" -ForegroundColor $Cyan
            Write-Host ""
            
            if ($Issues.Count -gt 0) {
                Write-Host "1. Utwórz brakujące foldery:" -ForegroundColor $Yellow
                $FolderIssues = $Issues | Where-Object { $_.Item.Type -eq "Folder" }
                foreach ($Issue in $FolderIssues) {
                    Write-Host "   mkdir `"$($Issue.Item.Name)`"" -ForegroundColor $Yellow
                }
                Write-Host ""
            }
            
            if ($NpmIssues.Count -gt 0) {
                Write-Host "2. Zainstaluj zależności npm:" -ForegroundColor $Yellow
                foreach ($Location in $NpmIssues) {
                    if ($Location -eq "root") {
                        Write-Host "   npm install" -ForegroundColor $Yellow
                    } else {
                        Write-Host "   cd $Location && npm install && cd .." -ForegroundColor $Yellow
                    }
                }
                Write-Host ""
            }
            
            Write-Host "3. Uruchom auto-naprawę:" -ForegroundColor $Yellow
            Write-Host "   .\Analyze-And-Fix-Project.ps1 -ProjectPath `"$ProjectPath`" -AutoFix -InstallDependencies" -ForegroundColor $Yellow
        }
    } else {
        Write-Host "🎉 PROJEKT W PEŁNI SPRAWNY!" -ForegroundColor $Green
        Write-Host ""
        Write-Host "💡 NASTĘPNE KROKI:" -ForegroundColor $Cyan
        Write-Host "1. cd `"$ProjectPath`"" -ForegroundColor $Yellow
        Write-Host "2. npm run dev" -ForegroundColor $Yellow
        Write-Host ""
        Write-Host "🌐 Aplikacja będzie dostępna pod:" -ForegroundColor $Cyan
        Write-Host "   Frontend: http://localhost:3000" -ForegroundColor $Yellow
        Write-Host "   Backend:  http://localhost:5000" -ForegroundColor $Yellow
    }
    
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "=== KONIEC ANALIZY ===" -ForegroundColor $Cyan