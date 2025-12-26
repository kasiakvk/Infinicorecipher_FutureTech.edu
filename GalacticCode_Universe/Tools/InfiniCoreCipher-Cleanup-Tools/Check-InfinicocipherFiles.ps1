# Check-InfinicocipherFiles.ps1
# Skrypt do sprawdzenia kompletności plików projektu Infinicorecipher

param(
    [string]$TargetPath = "D:\Infinicorecipher-Startup",
    [switch]$Detailed = $false,
    [switch]$CreateMissing = $false
)

# Kolory dla lepszej czytelności
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

Write-Host "=== SPRAWDZANIE KOMPLETNOŚCI PROJEKTU INFINICORECIPHER ===" -ForegroundColor $Cyan
Write-Host "Ścieżka docelowa: $TargetPath" -ForegroundColor $Yellow
Write-Host ""

# Lista oczekiwanych plików i folderów
$ExpectedStructure = @{
    "Pliki główne" = @(
        "package.json",
        "README.md",
        ".gitignore",
        "docker-compose.yml",
        "docker-compose.dev.yml"
    )
    "Frontend" = @(
        "frontend/package.json",
        "frontend/index.html",
        "frontend/vite.config.ts",
        "frontend/tsconfig.json",
        "frontend/tailwind.config.js",
        "frontend/src/main.tsx",
        "frontend/src/App.tsx",
        "frontend/src/styles/index.css",
        "frontend/src/contexts/AccessibilityContext.tsx",
        "frontend/src/components/accessibility/AccessibilityToolbar.tsx"
    )
    "Backend" = @(
        "backend/package.json",
        "backend/tsconfig.json",
        "backend/src/server.ts",
        "backend/src/app.ts",
        "backend/src/config/database.ts",
        "backend/src/routes/auth.ts",
        "backend/src/routes/users.ts",
        "backend/src/routes/games.ts",
        "backend/src/middleware/auth.ts",
        "backend/src/middleware/accessibility.ts",
        "backend/src/models/User.ts",
        "backend/src/models/Game.ts",
        "backend/src/controllers/AuthController.ts",
        "backend/src/controllers/UserController.ts",
        "backend/src/controllers/GameController.ts",
        "backend/src/services/AuthService.ts",
        "backend/src/services/UserService.ts",
        "backend/src/services/GameService.ts",
        "backend/src/utils/validation.ts",
        "backend/src/utils/accessibility.ts"
    )
    "Baza danych" = @(
        "database/schemas/users.sql",
        "database/schemas/games.sql",
        "database/schemas/progress.sql",
        "database/seeds/sample-data.sql",
        "database/migrations/001_initial_setup.sql"
    )
    "Dokumentacja" = @(
        "docs/README.md",
        "docs/SETUP.md",
        "docs/ACCESSIBILITY.md",
        "docs/api/README.md",
        "docs/deployment/README.md"
    )
    "Konfiguracja" = @(
        "config/development.env",
        "config/production.env",
        "config/docker.env"
    )
}

# Funkcja sprawdzania istnienia pliku
function Test-FileExists {
    param([string]$FilePath, [string]$BasePath)
    
    $FullPath = Join-Path $BasePath $FilePath
    return Test-Path $FullPath
}

# Funkcja tworzenia brakującego pliku/folderu
function New-MissingItem {
    param([string]$FilePath, [string]$BasePath)
    
    $FullPath = Join-Path $BasePath $FilePath
    $Directory = Split-Path $FullPath -Parent
    
    if (-not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
        Write-Host "  [UTWORZONO] Folder: $Directory" -ForegroundColor $Yellow
    }
    
    if ($FilePath -like "*.json" -or $FilePath -like "*.md" -or $FilePath -like "*.ts" -or $FilePath -like "*.tsx" -or $FilePath -like "*.sql") {
        New-Item -ItemType File -Path $FullPath -Force | Out-Null
        Write-Host "  [UTWORZONO] Plik: $FilePath" -ForegroundColor $Yellow
    }
}

# Sprawdzenie czy folder docelowy istnieje
if (-not (Test-Path $TargetPath)) {
    Write-Host "❌ BŁĄD: Folder docelowy nie istnieje: $TargetPath" -ForegroundColor $Red
    
    if ($CreateMissing) {
        Write-Host "Tworzenie folderu docelowego..." -ForegroundColor $Yellow
        New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
        Write-Host "✅ Folder utworzony: $TargetPath" -ForegroundColor $Green
    } else {
        Write-Host "Użyj parametru -CreateMissing aby utworzyć folder automatycznie" -ForegroundColor $Yellow
        exit 1
    }
}

# Statystyki
$TotalFiles = 0
$ExistingFiles = 0
$MissingFiles = 0
$MissingFilesList = @()

# Sprawdzanie każdej kategorii
foreach ($Category in $ExpectedStructure.Keys) {
    Write-Host "📁 $Category" -ForegroundColor $Cyan
    
    $CategoryFiles = $ExpectedStructure[$Category]
    $CategoryExisting = 0
    $CategoryMissing = 0
    
    foreach ($File in $CategoryFiles) {
        $TotalFiles++
        
        if (Test-FileExists -FilePath $File -BasePath $TargetPath) {
            $ExistingFiles++
            $CategoryExisting++
            
            if ($Detailed) {
                Write-Host "  ✅ $File" -ForegroundColor $Green
            }
        } else {
            $MissingFiles++
            $CategoryMissing++
            $MissingFilesList += $File
            
            Write-Host "  ❌ $File" -ForegroundColor $Red
            
            if ($CreateMissing) {
                New-MissingItem -FilePath $File -BasePath $TargetPath
            }
        }
    }
    
    # Podsumowanie kategorii
    $CategoryTotal = $CategoryFiles.Count
    $CategoryPercent = [math]::Round(($CategoryExisting / $CategoryTotal) * 100, 1)
    
    Write-Host "  📊 $CategoryExisting/$CategoryTotal plików ($CategoryPercent%)" -ForegroundColor $(
        if ($CategoryPercent -eq 100) { $Green }
        elseif ($CategoryPercent -ge 80) { $Yellow }
        else { $Red }
    )
    Write-Host ""
}

# Sprawdzenie dodatkowych folderów
Write-Host "📁 Sprawdzanie struktury folderów" -ForegroundColor $Cyan

$ExpectedFolders = @(
    "frontend/src/components",
    "frontend/src/hooks",
    "frontend/src/pages",
    "frontend/src/utils",
    "frontend/src/types",
    "frontend/src/assets",
    "backend/src/routes",
    "backend/src/controllers",
    "backend/src/services",
    "backend/src/models",
    "backend/src/middleware",
    "backend/src/utils",
    "backend/src/types",
    "database/schemas",
    "database/seeds",
    "database/migrations",
    "docs/api",
    "docs/deployment",
    "config"
)

$ExistingFolders = 0
$MissingFolders = 0

foreach ($Folder in $ExpectedFolders) {
    $FolderPath = Join-Path $TargetPath $Folder
    
    if (Test-Path $FolderPath) {
        $ExistingFolders++
        if ($Detailed) {
            Write-Host "  ✅ $Folder/" -ForegroundColor $Green
        }
    } else {
        $MissingFolders++
        Write-Host "  ❌ $Folder/" -ForegroundColor $Red
        
        if ($CreateMissing) {
            New-Item -ItemType Directory -Path $FolderPath -Force | Out-Null
            Write-Host "  [UTWORZONO] Folder: $Folder/" -ForegroundColor $Yellow
        }
    }
}

Write-Host "  📊 $ExistingFolders/$($ExpectedFolders.Count) folderów" -ForegroundColor $(
    if ($MissingFolders -eq 0) { $Green } else { $Yellow }
)
Write-Host ""

# Sprawdzenie rozmiaru projektu
if (Test-Path $TargetPath) {
    $ProjectSize = (Get-ChildItem $TargetPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $ProjectSizeMB = [math]::Round($ProjectSize / 1MB, 2)
    
    Write-Host "📊 Rozmiar projektu: $ProjectSizeMB MB" -ForegroundColor $Cyan
    
    # Sprawdzenie liczby plików
    $ActualFileCount = (Get-ChildItem $TargetPath -Recurse -File).Count
    Write-Host "📊 Liczba plików w projekcie: $ActualFileCount" -ForegroundColor $Cyan
}

# PODSUMOWANIE KOŃCOWE
Write-Host ""
Write-Host "=== PODSUMOWANIE SPRAWDZENIA ===" -ForegroundColor $Cyan

$CompletionPercent = [math]::Round(($ExistingFiles / $TotalFiles) * 100, 1)

Write-Host "📊 Pliki: $ExistingFiles/$TotalFiles ($CompletionPercent%)" -ForegroundColor $(
    if ($CompletionPercent -eq 100) { $Green }
    elseif ($CompletionPercent -ge 90) { $Yellow }
    else { $Red }
)

Write-Host "📊 Foldery: $ExistingFolders/$($ExpectedFolders.Count)" -ForegroundColor $(
    if ($MissingFolders -eq 0) { $Green } else { $Yellow }
)

# Status projektu
if ($MissingFiles -eq 0 -and $MissingFolders -eq 0) {
    Write-Host ""
    Write-Host "🎉 PROJEKT KOMPLETNY!" -ForegroundColor $Green
    Write-Host "Wszystkie wymagane pliki i foldery są obecne." -ForegroundColor $Green
    
    Write-Host ""
    Write-Host "📋 NASTĘPNE KROKI:" -ForegroundColor $Cyan
    Write-Host "1. cd `"$TargetPath`"" -ForegroundColor $Yellow
    Write-Host "2. npm run install:all" -ForegroundColor $Yellow
    Write-Host "3. npm run dev" -ForegroundColor $Yellow
    
} elseif ($MissingFiles -le 5) {
    Write-Host ""
    Write-Host "⚠️  PROJEKT PRAWIE KOMPLETNY" -ForegroundColor $Yellow
    Write-Host "Brakuje tylko kilku plików. Projekt powinien działać." -ForegroundColor $Yellow
    
} else {
    Write-Host ""
    Write-Host "❌ PROJEKT NIEKOMPLETNY" -ForegroundColor $Red
    Write-Host "Brakuje wielu ważnych plików. Projekt może nie działać poprawnie." -ForegroundColor $Red
}

# Lista brakujących plików
if ($MissingFiles -gt 0) {
    Write-Host ""
    Write-Host "📋 BRAKUJĄCE PLIKI ($MissingFiles):" -ForegroundColor $Red
    
    foreach ($MissingFile in $MissingFilesList) {
        Write-Host "  - $MissingFile" -ForegroundColor $Red
    }
    
    if (-not $CreateMissing) {
        Write-Host ""
        Write-Host "💡 WSKAZÓWKA: Użyj parametru -CreateMissing aby utworzyć brakujące pliki automatycznie" -ForegroundColor $Yellow
        Write-Host "   Przykład: .\Check-InfinicocipherFiles.ps1 -CreateMissing" -ForegroundColor $Yellow
    }
}

# Sprawdzenie czy można uruchomić projekt
Write-Host ""
Write-Host "🔍 SPRAWDZANIE GOTOWOŚCI DO URUCHOMIENIA:" -ForegroundColor $Cyan

$CanRun = $true
$CriticalFiles = @(
    "package.json",
    "frontend/package.json", 
    "backend/package.json",
    "frontend/src/main.tsx",
    "backend/src/server.ts"
)

foreach ($CriticalFile in $CriticalFiles) {
    if (-not (Test-FileExists -FilePath $CriticalFile -BasePath $TargetPath)) {
        Write-Host "  ❌ Brakuje krytycznego pliku: $CriticalFile" -ForegroundColor $Red
        $CanRun = $false
    }
}

if ($CanRun) {
    Write-Host "  ✅ Projekt gotowy do uruchomienia!" -ForegroundColor $Green
} else {
    Write-Host "  ❌ Projekt nie jest gotowy do uruchomienia" -ForegroundColor $Red
}

Write-Host ""
Write-Host "=== KONIEC SPRAWDZENIA ===" -ForegroundColor $Cyan

# Zwróć kod wyjścia
if ($MissingFiles -eq 0 -and $MissingFolders -eq 0) {
    exit 0  # Sukces
} elseif ($MissingFiles -le 5) {
    exit 1  # Ostrzeżenie
} else {
    exit 2  # Błąd
}