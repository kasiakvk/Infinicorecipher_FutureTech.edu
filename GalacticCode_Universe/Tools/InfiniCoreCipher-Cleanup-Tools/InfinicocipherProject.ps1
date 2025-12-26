# Copy-InfinicocipherProject.ps1
# Skrypt do kopiowania projektu Infinicorecipher z workspace do folderu docelowego

param(
    [string]$SourcePath = ".\infinicorecipher-startup",
    [string]$TargetPath = "D:\Infinicorecipher-Startup",
    [switch]$Force = $false,
    [switch]$Backup = $true
)

# Kolory dla lepszej czytelności
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

Write-Host "=== KOPIOWANIE PROJEKTU INFINICORECIPHER ===" -ForegroundColor $Cyan
Write-Host "Źródło: $SourcePath" -ForegroundColor $Yellow
Write-Host "Cel: $TargetPath" -ForegroundColor $Yellow
Write-Host ""

# Sprawdzenie czy folder źródłowy istnieje
if (-not (Test-Path $SourcePath)) {
    Write-Host "❌ BŁĄD: Folder źródłowy nie istnieje: $SourcePath" -ForegroundColor $Red
    Write-Host "Upewnij się, że uruchamiasz skrypt z właściwego katalogu." -ForegroundColor $Yellow
    exit 1
}

# Sprawdzenie czy folder docelowy już istnieje
if (Test-Path $TargetPath) {
    if (-not $Force) {
        Write-Host "⚠️  Folder docelowy już istnieje: $TargetPath" -ForegroundColor $Yellow
        $Response = Read-Host "Czy chcesz kontynuować? Istniejące pliki zostaną nadpisane. (y/N)"
        
        if ($Response -ne "y" -and $Response -ne "Y") {
            Write-Host "Operacja anulowana przez użytkownika." -ForegroundColor $Yellow
            exit 0
        }
    }
    
    # Tworzenie kopii zapasowej
    if ($Backup) {
        $BackupPath = "$TargetPath-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Write-Host "📦 Tworzenie kopii zapasowej: $BackupPath" -ForegroundColor $Yellow
        
        try {
            Copy-Item -Path $TargetPath -Destination $BackupPath -Recurse -Force
            Write-Host "✅ Kopia zapasowa utworzona pomyślnie" -ForegroundColor $Green
        } catch {
            Write-Host "❌ Błąd podczas tworzenia kopii zapasowej: $($_.Exception.Message)" -ForegroundColor $Red
            exit 1
        }
    }
} else {
    # Tworzenie folderu docelowego
    Write-Host "📁 Tworzenie folderu docelowego..." -ForegroundColor $Yellow
    try {
        New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
        Write-Host "✅ Folder docelowy utworzony" -ForegroundColor $Green
    } catch {
        Write-Host "❌ Błąd podczas tworzenia folderu: $($_.Exception.Message)" -ForegroundColor $Red
        exit 1
    }
}

# Lista plików do wykluczenia z kopiowania
$ExcludePatterns = @(
    "node_modules",
    ".git",
    "dist",
    "build",
    ".env",
    "*.log",
    ".DS_Store",
    "Thumbs.db",
    "*.tmp",
    "*.temp"
)

Write-Host "📋 Wykluczane z kopiowania:" -ForegroundColor $Cyan
foreach ($Pattern in $ExcludePatterns) {
    Write-Host "  - $Pattern" -ForegroundColor $Yellow
}
Write-Host ""

# Funkcja kopiowania z wykluczeniami
function Copy-ProjectFiles {
    param(
        [string]$Source,
        [string]$Destination,
        [string[]]$Exclude
    )
    
    $CopiedFiles = 0
    $SkippedFiles = 0
    $Errors = 0
    
    try {
        # Pobierz wszystkie pliki i foldery
        $Items = Get-ChildItem -Path $Source -Recurse
        $TotalItems = $Items.Count
        $ProcessedItems = 0
        
        Write-Host "📊 Znaleziono $TotalItems elementów do przetworzenia" -ForegroundColor $Cyan
        Write-Host ""
        
        foreach ($Item in $Items) {
            $ProcessedItems++
            $RelativePath = $Item.FullName.Substring($Source.Length + 1)
            $DestinationPath = Join-Path $Destination $RelativePath
            
            # Sprawdź czy element powinien być wykluczony
            $ShouldExclude = $false
            foreach ($Pattern in $Exclude) {
                if ($RelativePath -like "*$Pattern*") {
                    $ShouldExclude = $true
                    break
                }
            }
            
            if ($ShouldExclude) {
                $SkippedFiles++
                Write-Progress -Activity "Kopiowanie projektu" -Status "Pomijanie: $RelativePath" -PercentComplete (($ProcessedItems / $TotalItems) * 100)
                continue
            }
            
            try {
                if ($Item.PSIsContainer) {
                    # To jest folder
                    if (-not (Test-Path $DestinationPath)) {
                        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
                    }
                } else {
                    # To jest plik
                    $DestinationDir = Split-Path $DestinationPath -Parent
                    if (-not (Test-Path $DestinationDir)) {
                        New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null
                    }
                    
                    Copy-Item -Path $Item.FullName -Destination $DestinationPath -Force
                    $CopiedFiles++
                }
                
                Write-Progress -Activity "Kopiowanie projektu" -Status "Kopiowanie: $RelativePath" -PercentComplete (($ProcessedItems / $TotalItems) * 100)
                
            } catch {
                $Errors++
                Write-Host "❌ Błąd kopiowania $RelativePath`: $($_.Exception.Message)" -ForegroundColor $Red
            }
        }
        
        Write-Progress -Activity "Kopiowanie projektu" -Completed
        
    } catch {
        Write-Host "❌ Błąd podczas kopiowania: $($_.Exception.Message)" -ForegroundColor $Red
        return $false
    }
    
    # Podsumowanie
    Write-Host ""
    Write-Host "📊 PODSUMOWANIE KOPIOWANIA:" -ForegroundColor $Cyan
    Write-Host "  ✅ Skopiowane pliki: $CopiedFiles" -ForegroundColor $Green
    Write-Host "  ⏭️  Pominięte elementy: $SkippedFiles" -ForegroundColor $Yellow
    Write-Host "  ❌ Błędy: $Errors" -ForegroundColor $(if ($Errors -eq 0) { $Green } else { $Red })
    
    return ($Errors -eq 0)
}

# Rozpoczęcie kopiowania
Write-Host "🚀 Rozpoczynanie kopiowania..." -ForegroundColor $Cyan
$Success = Copy-ProjectFiles -Source $SourcePath -Destination $TargetPath -Exclude $ExcludePatterns

if ($Success) {
    Write-Host ""
    Write-Host "🎉 KOPIOWANIE ZAKOŃCZONE POMYŚLNIE!" -ForegroundColor $Green
    
    # Sprawdzenie rozmiaru skopiowanego projektu
    $ProjectSize = (Get-ChildItem $TargetPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $ProjectSizeMB = [math]::Round($ProjectSize / 1MB, 2)
    $FileCount = (Get-ChildItem $TargetPath -Recurse -File).Count
    
    Write-Host "📊 Rozmiar projektu: $ProjectSizeMB MB" -ForegroundColor $Cyan
    Write-Host "📊 Liczba plików: $FileCount" -ForegroundColor $Cyan
    
    Write-Host ""
    Write-Host "📋 NASTĘPNE KROKI:" -ForegroundColor $Cyan
    Write-Host "1. Sprawdź kompletność plików:" -ForegroundColor $Yellow
    Write-Host "   .\Check-InfinicocipherFiles.ps1" -ForegroundColor $Yellow
    Write-Host ""
    Write-Host "2. Przejdź do folderu projektu:" -ForegroundColor $Yellow
    Write-Host "   cd `"$TargetPath`"" -ForegroundColor $Yellow
    Write-Host ""
    Write-Host "3. Zainstaluj zależności:" -ForegroundColor $Yellow
    Write-Host "   npm run install:all" -ForegroundColor $Yellow
    Write-Host ""
    Write-Host "4. Uruchom projekt:" -ForegroundColor $Yellow
    Write-Host "   npm run dev" -ForegroundColor $Yellow
    
} else {
    Write-Host ""
    Write-Host "❌ KOPIOWANIE ZAKOŃCZONE Z BŁĘDAMI" -ForegroundColor $Red
    Write-Host "Sprawdź komunikaty błędów powyżej i spróbuj ponownie." -ForegroundColor $Yellow
    exit 1
}

Write-Host ""
Write-Host "=== KONIEC KOPIOWANIA ===" -ForegroundColor $Cyan