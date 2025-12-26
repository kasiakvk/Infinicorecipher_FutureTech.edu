<#
.SYNOPSIS
    Bezpieczny skrypt do usuwania duplikatów OneDrive

.DESCRIPTION
    Interaktywny skrypt do bezpiecznego usuwania duplikatów wykrytych przez OneDrive-Check-Script.ps1
    z opcjami backup i weryfikacji przed usunięciem.
#>

# Kolory
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Blue = "Blue"

function Write-CleanupStatus {
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

function Show-DuplicateGroup {
    param($Group, $Index)
    
    Write-Host ""
    Write-CleanupStatus "=== GRUPA DUPLIKATÓW #$Index ===" "INFO" $Cyan
    Write-CleanupStatus "Hash: $($Group.Hash)" "INFO" $Blue
    Write-CleanupStatus "Liczba kopii: $($Group.Count)" "INFO" $Yellow
    Write-CleanupStatus "Rozmiar pliku: $(Format-FileSize $Group.Files[0].Size)" "INFO" $Yellow
    Write-CleanupStatus "Zmarnowane miejsce: $(Format-FileSize $Group.WastedSpace)" "ERROR" $Red
    
    Write-Host ""
    Write-CleanupStatus "Lokalizacje plików:" "INFO" $Blue
    for ($i = 0; $i -lt $Group.Files.Count; $i++) {
        $file = $Group.Files[$i]
        $fileInfo = Get-Item $file.FullPath -ErrorAction SilentlyContinue
        if ($fileInfo) {
            $lastModified = $fileInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            Write-CleanupStatus "  [$i] $($file.FullPath)" "INFO" $Yellow
            Write-CleanupStatus "      Ostatnia modyfikacja: $lastModified" "INFO" $Blue
        } else {
            Write-CleanupStatus "  [$i] $($file.FullPath) [PLIK NIE ISTNIEJE]" "ERROR" $Red
        }
    }
}

function Get-UserChoice {
    param($Group, $Index)
    
    while ($true) {
        Write-Host ""
        Write-CleanupStatus "Wybierz akcję dla grupy #$Index :" "INFO" $Cyan
        Write-Host "  [s] Pomiń tę grupę" -ForegroundColor $Yellow
        Write-Host "  [b] Utwórz backup przed usunięciem" -ForegroundColor $Green
        Write-Host "  [d] Usuń duplikaty (zachowaj najnowszy)" -ForegroundColor $Red
        Write-Host "  [c] Wybierz ręcznie które pliki usunąć" -ForegroundColor $Blue
        Write-Host "  [q] Zakończ program" -ForegroundColor $Red
        
        $choice = Read-Host "Twój wybór"
        
        switch ($choice.ToLower()) {
            's' { return 'skip' }
            'b' { return 'backup' }
            'd' { return 'delete' }
            'c' { return 'custom' }
            'q' { return 'quit' }
            default { 
                Write-CleanupStatus "Nieprawidłowy wybór. Spróbuj ponownie." "ERROR" $Red 
            }
        }
    }
}

function Create-BackupFolder {
    $backupPath = "C:\OneDrive-Backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    try {
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
        Write-CleanupStatus "✅ Utworzono folder backup: $backupPath" "OK" $Green
        return $backupPath
    } catch {
        Write-CleanupStatus "❌ Błąd tworzenia folderu backup: $($_.Exception.Message)" "ERROR" $Red
        return $null
    }
}

function Backup-File {
    param($SourcePath, $BackupFolder)
    
    try {
        $fileName = Split-Path $SourcePath -Leaf
        $backupPath = Join-Path $BackupFolder $fileName
        
        # Jeśli plik o tej nazwie już istnieje w backup, dodaj timestamp
        if (Test-Path $backupPath) {
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $extension = [System.IO.Path]::GetExtension($fileName)
            $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
            $backupPath = Join-Path $BackupFolder "$nameWithoutExt-$timestamp$extension"
        }
        
        Copy-Item $SourcePath $backupPath -Force
        Write-CleanupStatus "✅ Backup: $fileName → $backupPath" "OK" $Green
        return $true
    } catch {
        Write-CleanupStatus "❌ Błąd backup $SourcePath : $($_.Exception.Message)" "ERROR" $Red
        return $false
    }
}

function Remove-DuplicateFiles {
    param($FilesToDelete, $BackupFolder = $null)
    
    $deletedCount = 0
    $deletedSize = 0
    
    foreach ($file in $FilesToDelete) {
        try {
            # Backup jeśli wymagany
            if ($BackupFolder) {
                $backupSuccess = Backup-File -SourcePath $file.FullPath -BackupFolder $BackupFolder
                if (-not $backupSuccess) {
                    Write-CleanupStatus "⚠️  Pominięto usunięcie $($file.FullPath) - błąd backup" "WARNING" $Yellow
                    continue
                }
            }
            
            # Usuń plik
            $fileSize = (Get-Item $file.FullPath).Length
            Remove-Item $file.FullPath -Force
            Write-CleanupStatus "🗑️  Usunięto: $($file.FullPath)" "OK" $Green
            
            $deletedCount++
            $deletedSize += $fileSize
            
        } catch {
            Write-CleanupStatus "❌ Błąd usuwania $($file.FullPath) : $($_.Exception.Message)" "ERROR" $Red
        }
    }
    
    return @{
        Count = $deletedCount
        Size = $deletedSize
    }
}

# Główna funkcja
function Start-OneDriveCleanup {
    Write-Host "=== BEZPIECZNE CZYSZCZENIE ONEDRIVE ===" -ForegroundColor $Cyan
    Write-Host ""
    
    # Znajdź najnowszy raport duplikatów
    $duplicateReports = Get-ChildItem -Path "OneDrive-Duplicates-*.csv" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
    
    if ($duplicateReports.Count -eq 0) {
        Write-CleanupStatus "❌ Nie znaleziono raportów duplikatów" "ERROR" $Red
        Write-CleanupStatus "Uruchom najpierw: .\OneDrive-Check-Script.ps1" "INFO" $Yellow
        return
    }
    
    $latestReport = $duplicateReports[0]
    Write-CleanupStatus "📊 Używam raportu: $($latestReport.Name)" "INFO" $Blue
    
    # Wczytaj dane duplikatów
    try {
        $duplicateData = Import-Csv $latestReport.FullName
        Write-CleanupStatus "✅ Wczytano $($duplicateData.Count) rekordów duplikatów" "OK" $Green
    } catch {
        Write-CleanupStatus "❌ Błąd odczytu raportu: $($_.Exception.Message)" "ERROR" $Red
        return
    }
    
    # Grupuj duplikaty po hash
    $duplicateGroups = $duplicateData | Group-Object Hash | Where-Object { $_.Count -gt 1 } | ForEach-Object {
        [PSCustomObject]@{
            Hash = $_.Name
            Files = $_.Group
            Count = $_.Count
            WastedSpace = ($_.Group | Measure-Object WastedSpace -Sum).Sum
        }
    }
    
    # Sortuj grupy po zmarnowanym miejscu (największe pierwsze)
    $duplicateGroups = $duplicateGroups | Sort-Object WastedSpace -Descending
    
    Write-CleanupStatus "🔍 Znaleziono $($duplicateGroups.Count) grup duplikatów" "INFO" $Cyan
    
    $totalWastedSpace = ($duplicateGroups | Measure-Object WastedSpace -Sum).Sum
    Write-CleanupStatus "💾 Łączne zmarnowane miejsce: $(Format-FileSize $totalWastedSpace)" "ERROR" $Red
    
    # Statystyki
    $totalDeletedFiles = 0
    $totalRecoveredSpace = 0
    $backupFolder = $null
    
    # Przetwarzaj każdą grupę duplikatów
    for ($i = 0; $i -lt $duplicateGroups.Count; $i++) {
        $group = $duplicateGroups[$i]
        
        Show-DuplicateGroup -Group $group -Index ($i + 1)
        
        $choice = Get-UserChoice -Group $group -Index ($i + 1)
        
        switch ($choice) {
            'skip' {
                Write-CleanupStatus "⏭️  Pominięto grupę #$($i + 1)" "INFO" $Yellow
                continue
            }
            
            'quit' {
                Write-CleanupStatus "🛑 Zakończono na żądanie użytkownika" "INFO" $Blue
                break
            }
            
            'backup' {
                if (-not $backupFolder) {
                    $backupFolder = Create-BackupFolder
                    if (-not $backupFolder) { continue }
                }
                
                # Usuń duplikaty, zachowaj najnowszy
                $sortedFiles = $group.Files | Sort-Object { (Get-Item $_.FullPath -ErrorAction SilentlyContinue).LastWriteTime } -Descending
                $filesToDelete = $sortedFiles | Select-Object -Skip 1  # Pomiń najnowszy
                
                if ($filesToDelete.Count -gt 0) {
                    $result = Remove-DuplicateFiles -FilesToDelete $filesToDelete -BackupFolder $backupFolder
                    $totalDeletedFiles += $result.Count
                    $totalRecoveredSpace += $result.Size
                    Write-CleanupStatus "✅ Usunięto $($result.Count) duplikatów z backup" "OK" $Green
                }
            }
            
            'delete' {
                # Usuń duplikaty bez backup, zachowaj najnowszy
                $sortedFiles = $group.Files | Sort-Object { (Get-Item $_.FullPath -ErrorAction SilentlyContinue).LastWriteTime } -Descending
                $filesToDelete = $sortedFiles | Select-Object -Skip 1  # Pomiń najnowszy
                
                if ($filesToDelete.Count -gt 0) {
                    Write-CleanupStatus "⚠️  UWAGA: Usuwanie bez backup!" "WARNING" $Red
                    $confirm = Read-Host "Czy na pewno chcesz usunąć $($filesToDelete.Count) plików? (tak/nie)"
                    
                    if ($confirm.ToLower() -eq 'tak') {
                        $result = Remove-DuplicateFiles -FilesToDelete $filesToDelete
                        $totalDeletedFiles += $result.Count
                        $totalRecoveredSpace += $result.Size
                        Write-CleanupStatus "✅ Usunięto $($result.Count) duplikatów" "OK" $Green
                    } else {
                        Write-CleanupStatus "⏭️  Anulowano usuwanie" "INFO" $Yellow
                    }
                }
            }
            
            'custom' {
                Write-Host ""
                Write-CleanupStatus "Wybierz pliki do usunięcia (oddziel spacjami, np: 0 2):" "INFO" $Cyan
                for ($j = 0; $j -lt $group.Files.Count; $j++) {
                    Write-Host "  [$j] $($group.Files[$j].FullPath)" -ForegroundColor $Yellow
                }
                
                $selection = Read-Host "Indeksy plików do usunięcia"
                $indices = $selection -split '\s+' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
                
                $filesToDelete = @()
                foreach ($index in $indices) {
                    if ($index -ge 0 -and $index -lt $group.Files.Count) {
                        $filesToDelete += $group.Files[$index]
                    }
                }
                
                if ($filesToDelete.Count -gt 0) {
                    if (-not $backupFolder) {
                        $createBackup = Read-Host "Czy utworzyć backup przed usunięciem? (tak/nie)"
                        if ($createBackup.ToLower() -eq 'tak') {
                            $backupFolder = Create-BackupFolder
                        }
                    }
                    
                    $result = Remove-DuplicateFiles -FilesToDelete $filesToDelete -BackupFolder $backupFolder
                    $totalDeletedFiles += $result.Count
                    $totalRecoveredSpace += $result.Size
                    Write-CleanupStatus "✅ Usunięto $($result.Count) wybranych plików" "OK" $Green
                }
            }
        }
    }
    
    # Podsumowanie
    Write-Host ""
    Write-CleanupStatus "📊 PODSUMOWANIE CZYSZCZENIA" "INFO" $Cyan
    Write-CleanupStatus "=========================" "INFO" $Cyan
    Write-CleanupStatus "Usunięto plików: $totalDeletedFiles" "OK" $Green
    Write-CleanupStatus "Odzyskano miejsca: $(Format-FileSize $totalRecoveredSpace)" "OK" $Green
    
    if ($backupFolder) {
        Write-CleanupStatus "Backup utworzony w: $backupFolder" "INFO" $Blue
    }
    
    Write-CleanupStatus "🎉 Czyszczenie zakończone!" "OK" $Green
}

# Uruchom główną funkcję
Start-OneDriveCleanup