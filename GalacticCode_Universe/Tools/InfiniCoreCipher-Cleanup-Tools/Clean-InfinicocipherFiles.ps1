# Clean-InfinicocipherFiles.ps1
# Bezpieczny skrypt do usuwania niepotrzebnych plików z projektu Infinicorecipher

param(
    [string]$TargetPath = "C:\Infinicorecipher",
    [switch]$DryRun = $true,  # Domyślnie tylko symulacja
    [switch]$CreateBackup = $true,
    [switch]$Verbose = $false,
    [switch]$Interactive = $false
)

# Kolory dla lepszej czytelności
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Magenta = "Magenta"

Write-Host "🧹 CZYSZCZENIE PLIKÓW INFINICORECIPHER" -ForegroundColor $Cyan
Write-Host "=======================================" -ForegroundColor $Cyan
Write-Host "Folder: $TargetPath" -ForegroundColor $Yellow
Write-Host "Tryb: $(if($DryRun){'SYMULACJA (DRY-RUN)'}else{'RZECZYWISTE USUWANIE'})" -ForegroundColor $(if($DryRun){$Yellow}else{$Red})
Write-Host ""

# Sprawdź czy folder istnieje
if (-not (Test-Path $TargetPath)) {
    Write-Host "❌ BŁĄD: Folder nie istnieje: $TargetPath" -ForegroundColor $Red
    Write-Host "Sprawdź ścieżkę i spróbuj ponownie." -ForegroundColor $Yellow
    exit 1
}

# Definicja plików/folderów do usunięcia
$CleanupRules = @{
    "Node.js Dependencies" = @{
        Folders = @("node_modules", "*/node_modules", "*/*/node_modules")
        Files = @("package-lock.json", "*/package-lock.json", "yarn.lock", "*/yarn.lock")
        Description = "Zależności npm/yarn (można odtworzyć przez npm install)"
    }
    "Build Artifacts" = @{
        Folders = @("dist", "build", "out", "*/dist", "*/build", "*/out", ".next", "*/.next")
        Files = @("*.tsbuildinfo", "*/*.tsbuildinfo")
        Description = "Pliki wygenerowane podczas budowania (można odtworzyć przez npm run build)"
    }
    "Cache Files" = @{
        Folders = @(".cache", "*/.cache", ".parcel-cache", "*/.parcel-cache", ".vite", "*/.vite")
        Files = @("*.cache", "*/*.cache")
        Description = "Pliki cache (tymczasowe, można bezpiecznie usunąć)"
    }
    "Log Files" = @{
        Files = @("*.log", "*/*.log", "npm-debug.log*", "*/npm-debug.log*", "yarn-debug.log*", "*/yarn-debug.log*", "yarn-error.log*", "*/yarn-error.log*")
        Description = "Pliki logów (można bezpiecznie usunąć)"
    }
    "Temporary Files" = @{
        Files = @("*.tmp", "*.temp", "*/*.tmp", "*/*.temp", ".DS_Store", "*/.DS_Store", "Thumbs.db", "*/Thumbs.db")
        Folders = @("tmp", "temp", "*/tmp", "*/temp")
        Description = "Pliki tymczasowe systemu"
    }
    "IDE Files" = @{
        Folders = @(".vscode", "*/.vscode", ".idea", "*/.idea")
        Files = @("*.swp", "*.swo", "*/*.swp", "*/*.swo")
        Description = "Pliki edytorów/IDE (ustawienia lokalne)"
    }
    "Git Files" = @{
        Folders = @(".git")
        Description = "Repozytorium Git (UWAGA: usuwa historię zmian!)"
    }
    "Environment Files" = @{
        Files = @(".env.local", ".env.development.local", ".env.test.local", ".env.production.local", "*/.env.local", "*/.env.*.local")
        Description = "Lokalne pliki środowiskowe (mogą zawierać wrażliwe dane)"
    }
}

# Funkcja do formatowania rozmiaru
function Format-FileSize {
    param([long]$Size)
    
    if ($Size -gt 1GB) {
        return "{0:N2} GB" -f ($Size / 1GB)
    } elseif ($Size -gt 1MB) {
        return "{0:N2} MB" -f ($Size / 1MB)
    } elseif ($Size -gt 1KB) {
        return "{0:N2} KB" -f ($Size / 1KB)
    } else {
        return "$Size B"
    }
}

# Funkcja do skanowania plików
function Get-FilesToClean {
    param([hashtable]$Rules, [string]$BasePath)
    
    $Results = @()
    
    foreach ($Category in $Rules.Keys) {
        $Rule = $Rules[$Category]
        $CategoryResults = @{
            Category = $Category
            Description = $Rule.Description
            Files = @()
            Folders = @()
            TotalSize = 0
        }
        
        # Skanuj pliki
        if ($Rule.Files) {
            foreach ($Pattern in $Rule.Files) {
                try {
                    $FoundFiles = Get-ChildItem -Path $BasePath -File -Name $Pattern -Recurse -ErrorAction SilentlyContinue
                    foreach ($File in $FoundFiles) {
                        $FullPath = Join-Path $BasePath $File
                        if (Test-Path $FullPath) {
                            $FileInfo = Get-Item $FullPath
                            $CategoryResults.Files += @{
                                Path = $FullPath
                                RelativePath = $File
                                Size = $FileInfo.Length
                            }
                            $CategoryResults.TotalSize += $FileInfo.Length
                        }
                    }
                } catch {
                    if ($Verbose) {
                        Write-Host "      ⚠️  Błąd skanowania plików $Pattern`: $($_.Exception.Message)" -ForegroundColor $Yellow
                    }
                }
            }
        }
        
        # Skanuj foldery
        if ($Rule.Folders) {
            foreach ($Pattern in $Rule.Folders) {
                try {
                    $FoundFolders = Get-ChildItem -Path $BasePath -Directory -Name $Pattern -Recurse -ErrorAction SilentlyContinue
                    foreach ($Folder in $FoundFolders) {
                        $FullPath = Join-Path $BasePath $Folder
                        if (Test-Path $FullPath) {
                            try {
                                $FolderSize = (Get-ChildItem $FullPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
                                $CategoryResults.Folders += @{
                                    Path = $FullPath
                                    RelativePath = $Folder
                                    Size = $FolderSize
                                }
                                $CategoryResults.TotalSize += $FolderSize
                            } catch {
                                $CategoryResults.Folders += @{
                                    Path = $FullPath
                                    RelativePath = $Folder
                                    Size = 0
                                }
                            }
                        }
                    }
                } catch {
                    if ($Verbose) {
                        Write-Host "      ⚠️  Błąd skanowania folderów $Pattern`: $($_.Exception.Message)" -ForegroundColor $Yellow
                    }
                }
            }
        }
        
        if ($CategoryResults.Files.Count -gt 0 -or $CategoryResults.Folders.Count -gt 0) {
            $Results += $CategoryResults
        }
    }
    
    return $Results
}

# Funkcja do tworzenia kopii zapasowej
function Create-Backup {
    param([string]$SourcePath)
    
    $BackupPath = "$SourcePath-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    Write-Host "📦 Tworzenie kopii zapasowej..." -ForegroundColor $Yellow
    Write-Host "   Źródło: $SourcePath" -ForegroundColor $Cyan
    Write-Host "   Backup: $BackupPath" -ForegroundColor $Cyan
    
    try {
        Copy-Item -Path $SourcePath -Destination $BackupPath -Recurse -Force
        Write-Host "   ✅ Kopia zapasowa utworzona pomyślnie" -ForegroundColor $Green
        return $BackupPath
    } catch {
        Write-Host "   ❌ Błąd tworzenia kopii zapasowej: $($_.Exception.Message)" -ForegroundColor $Red
        return $null
    }
}

# Główna logika
Write-Host "🔍 SKANOWANIE PLIKÓW DO USUNIĘCIA..." -ForegroundColor $Cyan
Write-Host ""

$FilesToClean = Get-FilesToClean -Rules $CleanupRules -BasePath $TargetPath

if ($FilesToClean.Count -eq 0) {
    Write-Host "✅ BRAK PLIKÓW DO USUNIĘCIA" -ForegroundColor $Green
    Write-Host "Folder jest już czysty lub nie zawiera typowych plików do usunięcia." -ForegroundColor $Yellow
    exit 0
}

# Pokaż wyniki skanowania
$TotalSize = 0
$TotalFiles = 0
$TotalFolders = 0

Write-Host "📋 ZNALEZIONE PLIKI DO USUNIĘCIA:" -ForegroundColor $Cyan
Write-Host ""

foreach ($Category in $FilesToClean) {
    Write-Host "📁 $($Category.Category)" -ForegroundColor $Magenta
    Write-Host "   💡 $($Category.Description)" -ForegroundColor $Cyan
    
    if ($Category.Files.Count -gt 0) {
        Write-Host "   📄 Pliki ($($Category.Files.Count)):" -ForegroundColor $Yellow
        $Category.Files | ForEach-Object {
            $Size = Format-FileSize $_.Size
            Write-Host "      - $($_.RelativePath) ($Size)" -ForegroundColor $Yellow
            $TotalFiles++
        }
    }
    
    if ($Category.Folders.Count -gt 0) {
        Write-Host "   📁 Foldery ($($Category.Folders.Count)):" -ForegroundColor $Yellow
        $Category.Folders | ForEach-Object {
            $Size = Format-FileSize $_.Size
            Write-Host "      - $($_.RelativePath) ($Size)" -ForegroundColor $Yellow
            $TotalFolders++
        }
    }
    
    $CategorySize = Format-FileSize $Category.TotalSize
    Write-Host "   📊 Rozmiar kategorii: $CategorySize" -ForegroundColor $Cyan
    $TotalSize += $Category.TotalSize
    Write-Host ""
}

# Podsumowanie
$TotalSizeFormatted = Format-FileSize $TotalSize
Write-Host "📊 PODSUMOWANIE:" -ForegroundColor $Cyan
Write-Host "   📄 Pliki do usunięcia: $TotalFiles" -ForegroundColor $Yellow
Write-Host "   📁 Foldery do usunięcia: $TotalFolders" -ForegroundColor $Yellow
Write-Host "   💾 Całkowity rozmiar: $TotalSizeFormatted" -ForegroundColor $Yellow
Write-Host ""

# Tryb interaktywny - wybór kategorii
if ($Interactive) {
    Write-Host "🎯 TRYB INTERAKTYWNY - WYBIERZ KATEGORIE DO USUNIĘCIA:" -ForegroundColor $Cyan
    Write-Host ""
    
    $SelectedCategories = @()
    
    for ($i = 0; $i -lt $FilesToClean.Count; $i++) {
        $Category = $FilesToClean[$i]
        $Size = Format-FileSize $Category.TotalSize
        $ItemCount = $Category.Files.Count + $Category.Folders.Count
        
        Write-Host "[$($i+1)] $($Category.Category) - $ItemCount elementów ($Size)" -ForegroundColor $Yellow
        Write-Host "    $($Category.Description)" -ForegroundColor $Cyan
        
        $Response = Read-Host "    Usunąć tę kategorię? (y/N)"
        if ($Response -eq "y" -or $Response -eq "Y") {
            $SelectedCategories += $Category
            Write-Host "    ✅ Dodano do usunięcia" -ForegroundColor $Green
        } else {
            Write-Host "    ⏭️  Pominięto" -ForegroundColor $Yellow
        }
        Write-Host ""
    }
    
    $FilesToClean = $SelectedCategories
    
    if ($FilesToClean.Count -eq 0) {
        Write-Host "ℹ️  Nie wybrano żadnych kategorii do usunięcia." -ForegroundColor $Yellow
        exit 0
    }
}

# Ostrzeżenie przed usuwaniem
if (-not $DryRun) {
    Write-Host "⚠️  OSTRZEŻENIE: RZECZYWISTE USUWANIE PLIKÓW!" -ForegroundColor $Red
    Write-Host "Ta operacja usunie $TotalFiles plików i $TotalFolders folderów ($TotalSizeFormatted)" -ForegroundColor $Red
    Write-Host ""
    
    if (-not $Interactive) {
        $Confirmation = Read-Host "Czy na pewno chcesz kontynuować? Wpisz 'TAK' aby potwierdzić"
        if ($Confirmation -ne "TAK") {
            Write-Host "Operacja anulowana przez użytkownika." -ForegroundColor $Yellow
            exit 0
        }
    }
    
    # Utwórz kopię zapasową
    if ($CreateBackup) {
        $BackupPath = Create-Backup -SourcePath $TargetPath
        if (-not $BackupPath) {
            Write-Host "❌ Nie można utworzyć kopii zapasowej. Operacja przerwana." -ForegroundColor $Red
            exit 1
        }
        Write-Host ""
    }
}

# Wykonaj czyszczenie
Write-Host "🧹 $(if($DryRun){'SYMULACJA CZYSZCZENIA'}else{'ROZPOCZYNANIE CZYSZCZENIA'})..." -ForegroundColor $Cyan
Write-Host ""

$DeletedFiles = 0
$DeletedFolders = 0
$DeletedSize = 0
$Errors = 0

foreach ($Category in $FilesToClean) {
    Write-Host "🗂️  Przetwarzanie: $($Category.Category)" -ForegroundColor $Magenta
    
    # Usuń pliki
    foreach ($File in $Category.Files) {
        try {
            if ($DryRun) {
                Write-Host "   [SYMULACJA] Usuwanie pliku: $($File.RelativePath)" -ForegroundColor $Yellow
            } else {
                Remove-Item -Path $File.Path -Force
                Write-Host "   ✅ Usunięto plik: $($File.RelativePath)" -ForegroundColor $Green
            }
            $DeletedFiles++
            $DeletedSize += $File.Size
        } catch {
            Write-Host "   ❌ Błąd usuwania pliku $($File.RelativePath): $($_.Exception.Message)" -ForegroundColor $Red
            $Errors++
        }
    }
    
    # Usuń foldery
    foreach ($Folder in $Category.Folders) {
        try {
            if ($DryRun) {
                Write-Host "   [SYMULACJA] Usuwanie folderu: $($Folder.RelativePath)" -ForegroundColor $Yellow
            } else {
                Remove-Item -Path $Folder.Path -Recurse -Force
                Write-Host "   ✅ Usunięto folder: $($Folder.RelativePath)" -ForegroundColor $Green
            }
            $DeletedFolders++
            $DeletedSize += $Folder.Size
        } catch {
            Write-Host "   ❌ Błąd usuwania folderu $($Folder.RelativePath): $($_.Exception.Message)" -ForegroundColor $Red
            $Errors++
        }
    }
}

# Podsumowanie końcowe
Write-Host ""
Write-Host "🎉 $(if($DryRun){'SYMULACJA ZAKOŃCZONA'}else{'CZYSZCZENIE ZAKOŃCZONE'})!" -ForegroundColor $Green
Write-Host ""
Write-Host "📊 STATYSTYKI:" -ForegroundColor $Cyan
Write-Host "   📄 $(if($DryRun){'Pliki do usunięcia'}else{'Usunięte pliki'}): $DeletedFiles" -ForegroundColor $Green
Write-Host "   📁 $(if($DryRun){'Foldery do usunięcia'}else{'Usunięte foldery'}): $DeletedFolders" -ForegroundColor $Green
Write-Host "   💾 $(if($DryRun){'Rozmiar do zwolnienia'}else{'Zwolnione miejsce'}): $(Format-FileSize $DeletedSize)" -ForegroundColor $Green
Write-Host "   ❌ Błędy: $Errors" -ForegroundColor $(if($Errors -eq 0){$Green}else{$Red})

if ($DryRun) {
    Write-Host ""
    Write-Host "💡 NASTĘPNE KROKI:" -ForegroundColor $Cyan
    Write-Host "Aby rzeczywiście usunąć pliki, uruchom:" -ForegroundColor $Yellow
    Write-Host ".\Clean-InfinicocipherFiles.ps1 -TargetPath `"$TargetPath`" -DryRun:`$false" -ForegroundColor $Yellow
}

if (-not $DryRun -and $CreateBackup -and $BackupPath) {
    Write-Host ""
    Write-Host "💾 KOPIA ZAPASOWA:" -ForegroundColor $Cyan
    Write-Host "W razie problemów możesz przywrócić z: $BackupPath" -ForegroundColor $Yellow
}

Write-Host ""
Write-Host "=== KONIEC CZYSZCZENIA ===" -ForegroundColor $Cyan