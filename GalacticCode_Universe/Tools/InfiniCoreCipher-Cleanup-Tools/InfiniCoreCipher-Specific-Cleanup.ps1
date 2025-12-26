<#
.SYNOPSIS
    Specjalistyczny skrypt czyszczenia folderu InfiniCoreCipher

.DESCRIPTION
    Dokładnie czyści folder InfiniCoreCipher z duplikatów, starych plików,
    niepotrzebnych dependencies i optymalizuje strukturę projektu.

.PARAMETER ProjectPath
    Ścieżka do folderu InfiniCoreCipher

.PARAMETER DryRun
    Tryb podglądu bez usuwania plików

.PARAMETER KeepBackups
    Zachowaj pliki backup

.EXAMPLE
    .\InfiniCoreCipher-Specific-Cleanup.ps1 -DryRun
    .\InfiniCoreCipher-Specific-Cleanup.ps1 -ProjectPath "C:\InfiniCoreCipher-Startup"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = "C:\InfiniCoreCipher-Startup",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$KeepBackups = $false
)

# Kolory
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Blue = "Blue"

function Write-ProjectLog {
    param(
        [string]$Message,
        [string]$Status = "INFO",
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMessage = "[$timestamp] [$Status] $Message"
    Write-Host $logMessage -ForegroundColor $Color
    Add-Content -Path "InfiniCoreCipher-Cleanup-Log.txt" -Value $logMessage
}

function Format-FileSize {
    param([long]$Size)
    if ($Size -gt 1GB) { return "{0:N2} GB" -f ($Size / 1GB) }
    elseif ($Size -gt 1MB) { return "{0:N2} MB" -f ($Size / 1MB) }
    elseif ($Size -gt 1KB) { return "{0:N2} KB" -f ($Size / 1KB) }
    else { return "$Size B" }
}

function Get-ProjectStructure {
    param($ProjectPath)
    
    Write-ProjectLog "📁 Analizowanie struktury projektu..." "INFO" $Yellow
    
    $structure = @{
        TotalSize = 0
        FileCount = 0
        FolderCount = 0
        LargestFiles = @()
        EmptyFolders = @()
        NodeModules = @()
        BuildArtifacts = @()
        TempFiles = @()
        Duplicates = @()
    }
    
    if (-not (Test-Path $ProjectPath)) {
        Write-ProjectLog "❌ Folder projektu nie istnieje: $ProjectPath" "ERROR" $Red
        return $structure
    }
    
    try {
        # Podstawowe statystyki
        $allItems = Get-ChildItem -Path $ProjectPath -Recurse -Force -ErrorAction SilentlyContinue
        $files = $allItems | Where-Object { -not $_.PSIsContainer }
        $folders = $allItems | Where-Object { $_.PSIsContainer }
        
        $structure.FileCount = $files.Count
        $structure.FolderCount = $folders.Count
        $structure.TotalSize = ($files | Measure-Object Length -Sum).Sum
        
        # Największe pliki (top 10)
        $structure.LargestFiles = $files | Sort-Object Length -Descending | Select-Object -First 10
        
        # Puste foldery
        $structure.EmptyFolders = $folders | Where-Object { 
            (Get-ChildItem $_.FullName -Force -ErrorAction SilentlyContinue).Count -eq 0 
        }
        
        # Node modules
        $structure.NodeModules = $folders | Where-Object { $_.Name -eq "node_modules" }
        
        # Build artifacts
        $buildFolders = @("dist", "build", ".next", ".nuxt", "coverage", ".nyc_output")
        $structure.BuildArtifacts = $folders | Where-Object { $_.Name -in $buildFolders }
        
        # Pliki tymczasowe
        $tempPatterns = @("*.tmp", "*.temp", "*.log", "*.bak", "*.old", "*~", "*.swp", "*.swo")
        $structure.TempFiles = $files | Where-Object { 
            $tempPatterns | ForEach-Object { $_.Name -like $_ } | Where-Object { $_ }
        }
        
        Write-ProjectLog "✅ Struktura przeanalizowana:" "OK" $Green
        Write-ProjectLog "   Pliki: $($structure.FileCount)" "INFO" $Blue
        Write-ProjectLog "   Foldery: $($structure.FolderCount)" "INFO" $Blue
        Write-ProjectLog "   Rozmiar: $(Format-FileSize $structure.TotalSize)" "INFO" $Blue
        
    } catch {
        Write-ProjectLog "❌ Błąd analizy struktury: $($_.Exception.Message)" "ERROR" $Red
    }
    
    return $structure
}

function Find-ProjectDuplicates {
    param($ProjectPath)
    
    Write-ProjectLog "🔍 Szukanie duplikatów w projekcie..." "INFO" $Yellow
    
    $duplicates = @()
    
    try {
        $files = Get-ChildItem -Path $ProjectPath -File -Recurse -ErrorAction SilentlyContinue |
                 Where-Object { $_.Length -gt 1KB }  # Ignoruj bardzo małe pliki
        
        # Grupuj po nazwie i rozmiarze
        $potentialDuplicates = $files | Group-Object Name, Length | Where-Object { $_.Count -gt 1 }
        
        Write-ProjectLog "🔍 Sprawdzanie $($potentialDuplicates.Count) grup potencjalnych duplikatów..." "INFO" $Blue
        
        foreach ($group in $potentialDuplicates) {
            Write-Progress -Activity "Sprawdzanie duplikatów" -Status "Grupa: $($group.Name)" -PercentComplete (($duplicates.Count / $potentialDuplicates.Count) * 100)
            
            # Sprawdź hash MD5 dla dokładnego porównania
            $filesWithHash = @()
            foreach ($file in $group.Group) {
                try {
                    $hash = Get-FileHash $file.FullName -Algorithm MD5 -ErrorAction SilentlyContinue
                    if ($hash) {
                        $filesWithHash += [PSCustomObject]@{
                            File = $file
                            Hash = $hash.Hash
                        }
                    }
                } catch {
                    # Ignoruj błędy hash
                }
            }
            
            # Znajdź prawdziwe duplikaty (identyczny hash)
            $realDuplicates = $filesWithHash | Group-Object Hash | Where-Object { $_.Count -gt 1 }
            
            foreach ($dupGroup in $realDuplicates) {
                $wastedSpace = ($dupGroup.Group[0].File.Length) * ($dupGroup.Count - 1)
                
                $duplicates += [PSCustomObject]@{
                    Hash = $dupGroup.Name
                    Files = $dupGroup.Group
                    Count = $dupGroup.Count
                    WastedSpace = $wastedSpace
                    FileSize = $dupGroup.Group[0].File.Length
                    FileName = $dupGroup.Group[0].File.Name
                }
                
                Write-ProjectLog "🔍 Duplikat: $($dupGroup.Group[0].File.Name) ($($dupGroup.Count) kopii, $(Format-FileSize $wastedSpace) zmarnowane)" "WARNING" $Yellow
            }
        }
        
        Write-Progress -Completed -Activity "Sprawdzanie duplikatów"
        
    } catch {
        Write-ProjectLog "❌ Błąd szukania duplikatów: $($_.Exception.Message)" "ERROR" $Red
    }
    
    $totalWasted = ($duplicates | Measure-Object WastedSpace -Sum).Sum
    Write-ProjectLog "📊 Znaleziono $($duplicates.Count) grup duplikatów, $(Format-FileSize $totalWasted) zmarnowane" "INFO" $Blue
    
    return $duplicates
}

function Remove-NodeModules {
    param($ProjectPath, $DryRun)
    
    Write-ProjectLog "📦 Czyszczenie node_modules..." "INFO" $Yellow
    
    $totalSize = 0
    $totalFolders = 0
    
    try {
        $nodeModulesFolders = Get-ChildItem -Path $ProjectPath -Name "node_modules" -Directory -Recurse -ErrorAction SilentlyContinue
        
        foreach ($folder in $nodeModulesFolders) {
            $fullPath = Join-Path $ProjectPath $folder
            try {
                $folderSize = (Get-ChildItem -Path $fullPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
                
                if (-not $DryRun) {
                    Remove-Item $fullPath -Recurse -Force -ErrorAction SilentlyContinue
                }
                
                Write-ProjectLog "🗑️ $(if($DryRun){'[DRY]'}) Usunięto node_modules: $fullPath ($(Format-FileSize $folderSize))" "OK" $Green
                $totalSize += $folderSize
                $totalFolders++
            } catch {
                Write-ProjectLog "⚠️ Nie można usunąć: $fullPath" "WARNING" $Yellow
            }
        }
    } catch {
        Write-ProjectLog "❌ Błąd czyszczenia node_modules: $($_.Exception.Message)" "ERROR" $Red
    }
    
    Write-ProjectLog "✅ Node modules: $totalFolders folderów, $(Format-FileSize $totalSize)" "OK" $Green
    return @{ Count = $totalFolders; Size = $totalSize }
}

function Remove-BuildArtifacts {
    param($ProjectPath, $DryRun)
    
    Write-ProjectLog "🏗️ Czyszczenie build artifacts..." "INFO" $Yellow
    
    $buildTargets = @("dist", "build", ".next", ".nuxt", "coverage", ".nyc_output", "out")
    $totalSize = 0
    $totalFolders = 0
    
    foreach ($target in $buildTargets) {
        try {
            $folders = Get-ChildItem -Path $ProjectPath -Name $target -Directory -Recurse -ErrorAction SilentlyContinue
            
            foreach ($folder in $folders) {
                $fullPath = Join-Path $ProjectPath $folder
                try {
                    $folderSize = (Get-ChildItem -Path $fullPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
                    
                    if (-not $DryRun) {
                        Remove-Item $fullPath -Recurse -Force -ErrorAction SilentlyContinue
                    }
                    
                    Write-ProjectLog "🗑️ $(if($DryRun){'[DRY]'}) Usunięto build: $fullPath ($(Format-FileSize $folderSize))" "OK" $Green
                    $totalSize += $folderSize
                    $totalFolders++
                } catch {
                    Write-ProjectLog "⚠️ Nie można usunąć: $fullPath" "WARNING" $Yellow
                }
            }
        } catch {
            # Ignoruj błędy wyszukiwania
        }
    }
    
    Write-ProjectLog "✅ Build artifacts: $totalFolders folderów, $(Format-FileSize $totalSize)" "OK" $Green
    return @{ Count = $totalFolders; Size = $totalSize }
}

function Remove-TempAndCacheFiles {
    param($ProjectPath, $DryRun)
    
    Write-ProjectLog "🗑️ Czyszczenie plików tymczasowych..." "INFO" $Yellow
    
    $tempTargets = @(
        "*.tmp", "*.temp", "*.log", "*.bak", "*.old", "*~", "*.swp", "*.swo",
        "Thumbs.db", ".DS_Store", "desktop.ini", "*.orig", "*.rej",
        ".cache", "*.cache", ".eslintcache", ".stylelintcache"
    )
    
    $totalSize = 0
    $totalFiles = 0
    
    foreach ($target in $tempTargets) {
        try {
            $files = Get-ChildItem -Path $ProjectPath -Filter $target -File -Recurse -Force -ErrorAction SilentlyContinue
            
            foreach ($file in $files) {
                try {
                    if (-not $DryRun) {
                        Remove-Item $file.FullName -Force -ErrorAction SilentlyContinue
                    }
                    
                    Write-ProjectLog "🗑️ $(if($DryRun){'[DRY]'}) Usunięto temp: $($file.Name) ($(Format-FileSize $file.Length))" "OK" $Green
                    $totalSize += $file.Length
                    $totalFiles++
                } catch {
                    Write-ProjectLog "⚠️ Nie można usunąć: $($file.FullName)" "WARNING" $Yellow
                }
            }
        } catch {
            # Ignoruj błędy wyszukiwania
        }
    }
    
    Write-ProjectLog "✅ Pliki tymczasowe: $totalFiles plików, $(Format-FileSize $totalSize)" "OK" $Green
    return @{ Count = $totalFiles; Size = $totalSize }
}

function Remove-EmptyFolders {
    param($ProjectPath, $DryRun)
    
    Write-ProjectLog "📁 Usuwanie pustych folderów..." "INFO" $Yellow
    
    $totalFolders = 0
    
    # Powtarzaj aż nie będzie więcej pustych folderów (niektóre stają się puste po usunięciu zawartości)
    do {
        $emptyFolders = Get-ChildItem -Path $ProjectPath -Directory -Recurse -Force -ErrorAction SilentlyContinue |
                       Where-Object { (Get-ChildItem $_.FullName -Force -ErrorAction SilentlyContinue).Count -eq 0 } |
                       Sort-Object FullName -Descending  # Sortuj od najgłębszych
        
        foreach ($folder in $emptyFolders) {
            try {
                if (-not $DryRun) {
                    Remove-Item $folder.FullName -Force -ErrorAction SilentlyContinue
                }
                
                Write-ProjectLog "🗑️ $(if($DryRun){'[DRY]'}) Usunięto pusty folder: $($folder.FullName)" "OK" $Green
                $totalFolders++
            } catch {
                Write-ProjectLog "⚠️ Nie można usunąć pustego folderu: $($folder.FullName)" "WARNING" $Yellow
            }
        }
    } while ($emptyFolders.Count -gt 0 -and -not $DryRun)
    
    Write-ProjectLog "✅ Puste foldery: $totalFolders folderów" "OK" $Green
    return @{ Count = $totalFolders; Size = 0 }
}

function Remove-ProjectDuplicates {
    param($Duplicates, $DryRun, $KeepBackups)
    
    Write-ProjectLog "🔄 Usuwanie duplikatów projektu..." "INFO" $Yellow
    
    if ($Duplicates.Count -eq 0) {
        Write-ProjectLog "⏭️ Brak duplikatów do usunięcia" "INFO" $Blue
        return @{ Count = 0; Size = 0 }
    }
    
    $totalDeleted = 0
    $totalRecovered = 0
    
    # Sortuj duplikaty po zmarnowanym miejscu (największe pierwsze)
    $sortedDuplicates = $Duplicates | Sort-Object WastedSpace -Descending
    
    foreach ($duplicate in $sortedDuplicates) {
        Write-ProjectLog "🔍 Duplikat: $($duplicate.FileName) ($($duplicate.Count) kopii)" "INFO" $Yellow
        
        # Sortuj pliki po dacie modyfikacji (zachowaj najnowszy)
        $sortedFiles = $duplicate.Files | Sort-Object { $_.File.LastWriteTime } -Descending
        $filesToDelete = $sortedFiles | Select-Object -Skip 1  # Pomiń najnowszy
        
        foreach ($fileToDelete in $filesToDelete) {
            try {
                # Utwórz backup jeśli wymagany
                if ($KeepBackups -and -not $DryRun) {
                    $backupPath = "$($fileToDelete.File.FullName).backup"
                    Copy-Item $fileToDelete.File.FullName $backupPath -Force -ErrorAction SilentlyContinue
                }
                
                if (-not $DryRun) {
                    Remove-Item $fileToDelete.File.FullName -Force
                }
                
                Write-ProjectLog "🗑️ $(if($DryRun){'[DRY]'}) Usunięto duplikat: $($fileToDelete.File.Name)" "OK" $Green
                $totalDeleted++
                $totalRecovered += $fileToDelete.File.Length
            } catch {
                Write-ProjectLog "⚠️ Nie można usunąć duplikatu: $($fileToDelete.File.FullName)" "WARNING" $Yellow
            }
        }
    }
    
    Write-ProjectLog "✅ Duplikaty: $totalDeleted plików, $(Format-FileSize $totalRecovered) odzyskane" "OK" $Green
    return @{ Count = $totalDeleted; Size = $totalRecovered }
}

function Optimize-ProjectStructure {
    param($ProjectPath, $DryRun)
    
    Write-ProjectLog "⚙️ Optymalizacja struktury projektu..." "INFO" $Yellow
    
    # Sprawdź czy istnieją wymagane foldery
    $requiredFolders = @("frontend", "backend", "docs", "scripts")
    $createdFolders = 0
    
    foreach ($folder in $requiredFolders) {
        $folderPath = Join-Path $ProjectPath $folder
        if (-not (Test-Path $folderPath)) {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
            }
            Write-ProjectLog "📁 $(if($DryRun){'[DRY]'}) Utworzono folder: $folder" "OK" $Green
            $createdFolders++
        }
    }
    
    # Sprawdź czy istnieje .gitignore
    $gitignorePath = Join-Path $ProjectPath ".gitignore"
    if (-not (Test-Path $gitignorePath)) {
        if (-not $DryRun) {
            $gitignoreContent = @"
# Dependencies
node_modules/
npm-debug.log*

# Production builds
dist/
build/

# Environment variables
.env
.env.local

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Cache
.cache/
*.cache

# Temporary files
*.tmp
*.temp
*.bak
*.old
*~
"@
            $gitignoreContent | Out-File -FilePath $gitignorePath -Encoding UTF8
        }
        Write-ProjectLog "📄 $(if($DryRun){'[DRY]'}) Utworzono .gitignore" "OK" $Green
    }
    
    Write-ProjectLog "✅ Optymalizacja: $createdFolders nowych folderów" "OK" $Green
    return @{ Count = $createdFolders; Size = 0 }
}

function Show-ProjectCleanupSummary {
    param($InitialStructure, $FinalStructure, $Results)
    
    Write-Host ""
    Write-ProjectLog "📊 PODSUMOWANIE CZYSZCZENIA PROJEKTU" "INFO" $Cyan
    Write-ProjectLog "====================================" "INFO" $Cyan
    
    $totalRecovered = 0
    $totalItems = 0
    
    foreach ($result in $Results) {
        $totalRecovered += $result.Size
        $totalItems += $result.Count
    }
    
    Write-ProjectLog "📁 Pliki przed: $($InitialStructure.FileCount)" "INFO" $Blue
    Write-ProjectLog "📁 Pliki po: $($FinalStructure.FileCount)" "INFO" $Blue
    Write-ProjectLog "💾 Rozmiar przed: $(Format-FileSize $InitialStructure.TotalSize)" "INFO" $Blue
    Write-ProjectLog "💾 Rozmiar po: $(Format-FileSize $FinalStructure.TotalSize)" "INFO" $Blue
    Write-ProjectLog "📈 Odzyskane miejsce: $(Format-FileSize $totalRecovered)" "OK" $Green
    Write-ProjectLog "🗑️ Usuniętych elementów: $totalItems" "OK" $Green
    
    $reductionPercent = (($InitialStructure.TotalSize - $FinalStructure.TotalSize) / $InitialStructure.TotalSize) * 100
    Write-ProjectLog "📊 Redukcja rozmiaru: {0:N2}%" -f $reductionPercent "OK" $Green
    
    Write-Host ""
    Write-ProjectLog "🎉 CZYSZCZENIE PROJEKTU ZAKOŃCZONE!" "OK" $Green
}

# Główna funkcja
function Start-InfiniCoreCipherCleanup {
    Write-Host "=== CZYSZCZENIE PROJEKTU INFINICORECIPHER ===" -ForegroundColor $Cyan
    Write-Host "Ścieżka: $ProjectPath" -ForegroundColor $Blue
    Write-Host "Dry Run: $DryRun" -ForegroundColor $Blue
    Write-Host "Zachowaj backupy: $KeepBackups" -ForegroundColor $Blue
    Write-Host ""
    
    if ($DryRun) {
        Write-ProjectLog "🔍 TRYB DRY RUN - tylko podgląd zmian" "INFO" $Yellow
    }
    
    # Analiza początkowa
    $initialStructure = Get-ProjectStructure -ProjectPath $ProjectPath
    
    if ($initialStructure.FileCount -eq 0) {
        Write-ProjectLog "❌ Projekt jest pusty lub nie istnieje" "ERROR" $Red
        return
    }
    
    # Znajdź duplikaty
    $duplicates = Find-ProjectDuplicates -ProjectPath $ProjectPath
    
    # Wykonaj czyszczenie
    $results = @()
    
    # 1. Usuń node_modules
    $nodeResult = Remove-NodeModules -ProjectPath $ProjectPath -DryRun $DryRun
    $results += $nodeResult
    
    # 2. Usuń build artifacts
    $buildResult = Remove-BuildArtifacts -ProjectPath $ProjectPath -DryRun $DryRun
    $results += $buildResult
    
    # 3. Usuń pliki tymczasowe
    $tempResult = Remove-TempAndCacheFiles -ProjectPath $ProjectPath -DryRun $DryRun
    $results += $tempResult
    
    # 4. Usuń duplikaty
    $dupResult = Remove-ProjectDuplicates -Duplicates $duplicates -DryRun $DryRun -KeepBackups $KeepBackups
    $results += $dupResult
    
    # 5. Usuń puste foldery
    $emptyResult = Remove-EmptyFolders -ProjectPath $ProjectPath -DryRun $DryRun
    $results += $emptyResult
    
    # 6. Optymalizuj strukturę
    $optimizeResult = Optimize-ProjectStructure -ProjectPath $ProjectPath -DryRun $DryRun
    $results += $optimizeResult
    
    # Analiza końcowa
    $finalStructure = Get-ProjectStructure -ProjectPath $ProjectPath
    
    # Podsumowanie
    Show-ProjectCleanupSummary -InitialStructure $initialStructure -FinalStructure $finalStructure -Results $results
    
    # Zapisz raport duplikatów
    if ($duplicates.Count -gt 0) {
        $reportPath = "InfiniCoreCipher-Duplicates-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
        $duplicateReport = @()
        
        foreach ($duplicate in $duplicates) {
            foreach ($file in $duplicate.Files) {
                $duplicateReport += [PSCustomObject]@{
                    Hash = $duplicate.Hash
                    FileName = $file.File.Name
                    FilePath = $file.File.FullName
                    Size = $file.File.Length
                    SizeFormatted = Format-FileSize $file.File.Length
                    LastModified = $file.File.LastWriteTime
                    DuplicateCount = $duplicate.Count
                    WastedSpace = $duplicate.WastedSpace
                }
            }
        }
        
        $duplicateReport | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8
        Write-ProjectLog "📄 Raport duplikatów zapisany: $reportPath" "INFO" $Blue
    }
    
    # Następne kroki
    Write-Host ""
    Write-ProjectLog "📋 NASTĘPNE KROKI:" "INFO" $Cyan
    Write-ProjectLog "1. Zainstaluj zależności: npm run install:all" "INFO" $Blue
    Write-ProjectLog "2. Uruchom testy: npm test" "INFO" $Blue
    Write-ProjectLog "3. Uruchom projekt: npm run dev" "INFO" $Blue
}

# Uruchom główną funkcję
Start-InfiniCoreCipherCleanup