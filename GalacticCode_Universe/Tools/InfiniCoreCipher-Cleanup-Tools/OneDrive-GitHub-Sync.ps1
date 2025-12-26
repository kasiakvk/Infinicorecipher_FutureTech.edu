<#
.SYNOPSIS
    Skrypt synchronizacji OneDrive z GitHub dla projektu InfiniCoreCipher

.DESCRIPTION
    Automatyzuje synchronizację plików między OneDrive a repozytorium GitHub,
    z opcjami backup, filtrowania i zarządzania wersjami.

.PARAMETER OneDrivePath
    Ścieżka do folderu OneDrive z projektem

.PARAMETER GitRepoPath
    Ścieżka do lokalnego repozytorium Git

.PARAMETER SyncMode
    Tryb synchronizacji: ToGit, ToOneDrive, Bidirectional

.EXAMPLE
    .\OneDrive-GitHub-Sync.ps1 -OneDrivePath "C:\Users\kasia\OneDrive\InfiniCoreCipher-Project" -GitRepoPath "C:\Projects\InfiniCoreCipher" -SyncMode "ToGit"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$OneDrivePath = "$env:USERPROFILE\OneDrive\kasiakvk20@gmail.com\OneDrive\one drive\OneDrive infinicorecipher",
    
    [Parameter(Mandatory=$false)]
    [string]$GitRepoPath = "C:\InfiniCoreCipher-Startup",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("ToGit", "ToOneDrive", "Bidirectional")]
    [string]$SyncMode = "ToGit",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$CreateBackup = $true
)

# Kolory
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Blue = "Blue"

function Write-SyncStatus {
    param(
        [string]$Message,
        [string]$Status = "INFO",
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Status] $Message" -ForegroundColor $Color
}

function Format-FileSize {
    param([long]$Size)
    if ($Size -gt 1GB) { return "{0:N2} GB" -f ($Size / 1GB) }
    elseif ($Size -gt 1MB) { return "{0:N2} MB" -f ($Size / 1MB) }
    elseif ($Size -gt 1KB) { return "{0:N2} KB" -f ($Size / 1KB) }
    else { return "$Size B" }
}

function Test-Paths {
    param($OneDrivePath, $GitRepoPath)
    
    Write-SyncStatus "🔍 Sprawdzanie ścieżek..." "INFO" $Yellow
    
    if (-not (Test-Path $OneDrivePath)) {
        Write-SyncStatus "❌ OneDrive path nie istnieje: $OneDrivePath" "ERROR" $Red
        return $false
    }
    
    if (-not (Test-Path $GitRepoPath)) {
        Write-SyncStatus "❌ Git repo path nie istnieje: $GitRepoPath" "ERROR" $Red
        return $false
    }
    
    # Sprawdź czy GitRepoPath to repozytorium Git
    if (-not (Test-Path (Join-Path $GitRepoPath ".git"))) {
        Write-SyncStatus "❌ $GitRepoPath nie jest repozytorium Git" "ERROR" $Red
        return $false
    }
    
    Write-SyncStatus "✅ Wszystkie ścieżki są poprawne" "OK" $Green
    return $true
}

function Get-SyncMapping {
    # Mapowanie folderów OneDrive na strukturę Git
    return @{
        # OneDrive folder -> Git folder
        "OneDrive\Attachments\Documents Personal" = "docs/personal"
        "OneDrive\Attachments\InfiniCoreCipher Project" = "assets/project"
        "OneDrive\Attachments\InfiniCoreCipher Project\avatars samples" = "assets/avatars"
        "Scripts" = "scripts/onedrive"
        "Documentation" = "docs"
        "Development" = "src"
        "Assets" = "assets"
        "Backups" = "backups"
    }
}

function Get-FileFilters {
    # Pliki do pominięcia podczas synchronizacji
    return @{
        Extensions = @(".tmp", ".log", ".cache", ".lock", ".bak")
        Patterns = @("*~", "*.swp", "Thumbs.db", ".DS_Store", "desktop.ini")
        Folders = @("node_modules", ".git", ".vscode", "temp", "tmp")
        MaxSize = 100MB  # Maksymalny rozmiar pliku
    }
}

function Test-FileFilter {
    param($FilePath, $Filters)
    
    $fileName = Split-Path $FilePath -Leaf
    $extension = [System.IO.Path]::GetExtension($FilePath)
    $fileInfo = Get-Item $FilePath -ErrorAction SilentlyContinue
    
    # Sprawdź rozszerzenia
    if ($extension -in $Filters.Extensions) {
        return $false
    }
    
    # Sprawdź wzorce nazw
    foreach ($pattern in $Filters.Patterns) {
        if ($fileName -like $pattern) {
            return $false
        }
    }
    
    # Sprawdź rozmiar pliku
    if ($fileInfo -and $fileInfo.Length -gt $Filters.MaxSize) {
        Write-SyncStatus "⚠️ Plik za duży ($(Format-FileSize $fileInfo.Length)): $fileName" "WARNING" $Yellow
        return $false
    }
    
    return $true
}

function Create-SyncBackup {
    param($TargetPath)
    
    if (-not $CreateBackup) {
        return $null
    }
    
    $backupPath = "$TargetPath-Backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    try {
        Write-SyncStatus "💾 Tworzenie backup: $backupPath" "INFO" $Blue
        
        if (Test-Path $TargetPath) {
            robocopy $TargetPath $backupPath /MIR /XD .git node_modules /NFL /NDL /NJH /NJS
            Write-SyncStatus "✅ Backup utworzony" "OK" $Green
        }
        
        return $backupPath
    } catch {
        Write-SyncStatus "❌ Błąd tworzenia backup: $($_.Exception.Message)" "ERROR" $Red
        return $null
    }
}

function Sync-OneDriveToGit {
    param($OneDrivePath, $GitRepoPath, $Mapping, $Filters)
    
    Write-SyncStatus "📤 Synchronizacja OneDrive → Git" "INFO" $Cyan
    
    $syncedFiles = 0
    $syncedSize = 0
    $skippedFiles = 0
    
    foreach ($oneDriveFolder in $Mapping.Keys) {
        $gitFolder = $Mapping[$oneDriveFolder]
        $sourcePath = Join-Path $OneDrivePath $oneDriveFolder
        $targetPath = Join-Path $GitRepoPath $gitFolder
        
        if (-not (Test-Path $sourcePath)) {
            Write-SyncStatus "⏭️ Pominięto (brak źródła): $oneDriveFolder" "INFO" $Blue
            continue
        }
        
        Write-SyncStatus "📁 Synchronizacja: $oneDriveFolder → $gitFolder" "INFO" $Yellow
        
        # Utwórz folder docelowy jeśli nie istnieje
        if (-not (Test-Path $targetPath)) {
            New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        }
        
        # Pobierz pliki do synchronizacji
        $files = Get-ChildItem -Path $sourcePath -File -Recurse -ErrorAction SilentlyContinue
        
        foreach ($file in $files) {
            if (Test-FileFilter -FilePath $file.FullName -Filters $Filters) {
                $relativePath = $file.FullName.Substring($sourcePath.Length + 1)
                $targetFilePath = Join-Path $targetPath $relativePath
                $targetFileDir = Split-Path $targetFilePath -Parent
                
                # Utwórz katalog docelowy jeśli nie istnieje
                if (-not (Test-Path $targetFileDir)) {
                    New-Item -ItemType Directory -Path $targetFileDir -Force | Out-Null
                }
                
                # Sprawdź czy plik wymaga aktualizacji
                $needsUpdate = $true
                if (Test-Path $targetFilePath) {
                    $sourceHash = Get-FileHash $file.FullName -Algorithm MD5
                    $targetHash = Get-FileHash $targetFilePath -Algorithm MD5
                    $needsUpdate = $sourceHash.Hash -ne $targetHash.Hash
                }
                
                if ($needsUpdate) {
                    if (-not $DryRun) {
                        try {
                            Copy-Item $file.FullName $targetFilePath -Force
                            Write-SyncStatus "✅ Skopiowano: $relativePath" "OK" $Green
                            $syncedFiles++
                            $syncedSize += $file.Length
                        } catch {
                            Write-SyncStatus "❌ Błąd kopiowania $relativePath : $($_.Exception.Message)" "ERROR" $Red
                        }
                    } else {
                        Write-SyncStatus "🔍 [DRY RUN] Skopiowałbym: $relativePath" "INFO" $Blue
                        $syncedFiles++
                        $syncedSize += $file.Length
                    }
                } else {
                    Write-SyncStatus "⏭️ Aktualny: $relativePath" "INFO" $Blue
                }
            } else {
                $skippedFiles++
            }
        }
    }
    
    Write-SyncStatus "📊 Synchronizacja OneDrive → Git zakończona:" "INFO" $Cyan
    Write-SyncStatus "   Zsynchronizowano: $syncedFiles plików ($(Format-FileSize $syncedSize))" "OK" $Green
    Write-SyncStatus "   Pominięto: $skippedFiles plików" "INFO" $Yellow
}

function Sync-GitToOneDrive {
    param($GitRepoPath, $OneDrivePath, $Mapping, $Filters)
    
    Write-SyncStatus "📥 Synchronizacja Git → OneDrive" "INFO" $Cyan
    
    $syncedFiles = 0
    $syncedSize = 0
    
    # Odwróć mapowanie
    $reverseMapping = @{}
    foreach ($key in $Mapping.Keys) {
        $reverseMapping[$Mapping[$key]] = $key
    }
    
    foreach ($gitFolder in $reverseMapping.Keys) {
        $oneDriveFolder = $reverseMapping[$gitFolder]
        $sourcePath = Join-Path $GitRepoPath $gitFolder
        $targetPath = Join-Path $OneDrivePath $oneDriveFolder
        
        if (-not (Test-Path $sourcePath)) {
            Write-SyncStatus "⏭️ Pominięto (brak źródła): $gitFolder" "INFO" $Blue
            continue
        }
        
        Write-SyncStatus "📁 Synchronizacja: $gitFolder → $oneDriveFolder" "INFO" $Yellow
        
        # Utwórz folder docelowy jeśli nie istnieje
        if (-not (Test-Path $targetPath)) {
            New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        }
        
        # Synchronizuj pliki (podobnie jak wyżej)
        $files = Get-ChildItem -Path $sourcePath -File -Recurse -ErrorAction SilentlyContinue
        
        foreach ($file in $files) {
            if (Test-FileFilter -FilePath $file.FullName -Filters $Filters) {
                $relativePath = $file.FullName.Substring($sourcePath.Length + 1)
                $targetFilePath = Join-Path $targetPath $relativePath
                $targetFileDir = Split-Path $targetFilePath -Parent
                
                if (-not (Test-Path $targetFileDir)) {
                    New-Item -ItemType Directory -Path $targetFileDir -Force | Out-Null
                }
                
                $needsUpdate = $true
                if (Test-Path $targetFilePath) {
                    $sourceHash = Get-FileHash $file.FullName -Algorithm MD5
                    $targetHash = Get-FileHash $targetFilePath -Algorithm MD5
                    $needsUpdate = $sourceHash.Hash -ne $targetHash.Hash
                }
                
                if ($needsUpdate) {
                    if (-not $DryRun) {
                        try {
                            Copy-Item $file.FullName $targetFilePath -Force
                            Write-SyncStatus "✅ Skopiowano: $relativePath" "OK" $Green
                            $syncedFiles++
                            $syncedSize += $file.Length
                        } catch {
                            Write-SyncStatus "❌ Błąd kopiowania $relativePath : $($_.Exception.Message)" "ERROR" $Red
                        }
                    } else {
                        Write-SyncStatus "🔍 [DRY RUN] Skopiowałbym: $relativePath" "INFO" $Blue
                        $syncedFiles++
                        $syncedSize += $file.Length
                    }
                }
            }
        }
    }
    
    Write-SyncStatus "📊 Synchronizacja Git → OneDrive zakończona:" "INFO" $Cyan
    Write-SyncStatus "   Zsynchronizowano: $syncedFiles plików ($(Format-FileSize $syncedSize))" "OK" $Green
}

function Update-GitRepository {
    param($GitRepoPath)
    
    Write-SyncStatus "🔄 Aktualizacja repozytorium Git..." "INFO" $Yellow
    
    try {
        Push-Location $GitRepoPath
        
        # Sprawdź status
        $status = git status --porcelain 2>$null
        if ($status) {
            Write-SyncStatus "📝 Znaleziono zmiany do commit" "INFO" $Blue
            
            if (-not $DryRun) {
                $commitMessage = "sync: update from OneDrive $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
                
                git add .
                git commit -m $commitMessage
                
                Write-SyncStatus "✅ Utworzono commit: $commitMessage" "OK" $Green
                
                # Zapytaj o push
                $pushChoice = Read-Host "Czy chcesz wypchnąć zmiany na GitHub? (t/n)"
                if ($pushChoice.ToLower() -eq 't' -or $pushChoice.ToLower() -eq 'tak') {
                    git push origin main
                    Write-SyncStatus "✅ Zmiany wypchnięte na GitHub" "OK" $Green
                }
            } else {
                Write-SyncStatus "🔍 [DRY RUN] Utworzyłbym commit z zmianami" "INFO" $Blue
            }
        } else {
            Write-SyncStatus "⏭️ Brak zmian do commit" "INFO" $Blue
        }
        
    } catch {
        Write-SyncStatus "❌ Błąd aktualizacji Git: $($_.Exception.Message)" "ERROR" $Red
    } finally {
        Pop-Location
    }
}

function Show-SyncSummary {
    param($OneDrivePath, $GitRepoPath, $SyncMode)
    
    Write-Host ""
    Write-SyncStatus "📊 PODSUMOWANIE SYNCHRONIZACJI" "INFO" $Cyan
    Write-SyncStatus "=============================" "INFO" $Cyan
    Write-SyncStatus "OneDrive: $OneDrivePath" "INFO" $Blue
    Write-SyncStatus "Git Repo: $GitRepoPath" "INFO" $Blue
    Write-SyncStatus "Tryb: $SyncMode" "INFO" $Blue
    Write-SyncStatus "Dry Run: $DryRun" "INFO" $Blue
    Write-SyncStatus "Backup: $CreateBackup" "INFO" $Blue
    
    if ($DryRun) {
        Write-Host ""
        Write-SyncStatus "🔍 To był DRY RUN - żadne pliki nie zostały zmienione" "INFO" $Yellow
        Write-SyncStatus "Uruchom ponownie bez -DryRun aby wykonać synchronizację" "INFO" $Blue
    }
}

# Główna funkcja
function Start-OneDriveGitSync {
    Write-Host "=== SYNCHRONIZACJA ONEDRIVE ↔ GITHUB ===" -ForegroundColor $Cyan
    Write-Host ""
    
    if ($DryRun) {
        Write-SyncStatus "🔍 TRYB DRY RUN - tylko podgląd zmian" "INFO" $Yellow
    }
    
    # Sprawdź ścieżki
    if (-not (Test-Paths -OneDrivePath $OneDrivePath -GitRepoPath $GitRepoPath)) {
        return
    }
    
    # Pobierz konfigurację
    $mapping = Get-SyncMapping
    $filters = Get-FileFilters
    
    Write-SyncStatus "📋 Konfiguracja synchronizacji:" "INFO" $Blue
    Write-SyncStatus "   Mapowań folderów: $($mapping.Count)" "INFO" $Blue
    Write-SyncStatus "   Filtrów plików: $($filters.Extensions.Count) rozszerzeń, $($filters.Patterns.Count) wzorców" "INFO" $Blue
    
    # Utwórz backup jeśli wymagany
    $backupPath = $null
    if ($CreateBackup -and -not $DryRun) {
        $backupPath = Create-SyncBackup -TargetPath $GitRepoPath
    }
    
    # Wykonaj synchronizację według trybu
    switch ($SyncMode) {
        "ToGit" {
            Sync-OneDriveToGit -OneDrivePath $OneDrivePath -GitRepoPath $GitRepoPath -Mapping $mapping -Filters $filters
            if (-not $DryRun) {
                Update-GitRepository -GitRepoPath $GitRepoPath
            }
        }
        "ToOneDrive" {
            Sync-GitToOneDrive -GitRepoPath $GitRepoPath -OneDrivePath $OneDrivePath -Mapping $mapping -Filters $filters
        }
        "Bidirectional" {
            Write-SyncStatus "🔄 Synchronizacja dwukierunkowa" "INFO" $Cyan
            Sync-OneDriveToGit -OneDrivePath $OneDrivePath -GitRepoPath $GitRepoPath -Mapping $mapping -Filters $filters
            Sync-GitToOneDrive -GitRepoPath $GitRepoPath -OneDrivePath $OneDrivePath -Mapping $mapping -Filters $filters
            if (-not $DryRun) {
                Update-GitRepository -GitRepoPath $GitRepoPath
            }
        }
    }
    
    # Podsumowanie
    Show-SyncSummary -OneDrivePath $OneDrivePath -GitRepoPath $GitRepoPath -SyncMode $SyncMode
    
    if ($backupPath) {
        Write-SyncStatus "💾 Backup dostępny w: $backupPath" "INFO" $Blue
    }
    
    Write-SyncStatus "🎉 Synchronizacja zakończona!" "OK" $Green
}

# Uruchom główną funkcję
Start-OneDriveGitSync