<#
.SYNOPSIS
    Zaawansowany skrypt do znajdowania i usuwania duplikatów na całym dysku C:\

.DESCRIPTION
    Skanuje cały dysk C:\ w poszukiwaniu duplikatów plików, z opcjami filtrowania,
    priorytetyzacji i bezpiecznego usuwania z backup.

.PARAMETER TargetDrive
    Dysk do skanowania (domyślnie C:\)

.PARAMETER MinFileSize
    Minimalny rozmiar pliku do skanowania (domyślnie 1KB)

.PARAMETER MaxFileSize
    Maksymalny rozmiar pliku do skanowania (domyślnie 100MB)

.PARAMETER DryRun
    Tryb podglądu bez usuwania plików

.PARAMETER CreateBackup
    Utwórz backup przed usunięciem

.EXAMPLE
    .\System-Wide-Duplicate-Hunter.ps1 -DryRun
    .\System-Wide-Duplicate-Hunter.ps1 -MinFileSize 10KB -MaxFileSize 50MB
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$TargetDrive = "C:\",
    
    [Parameter(Mandatory=$false)]
    [long]$MinFileSize = 1KB,
    
    [Parameter(Mandatory=$false)]
    [long]$MaxFileSize = 100MB,
    
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
$Magenta = "Magenta"

function Write-HunterLog {
    param(
        [string]$Message,
        [string]$Status = "INFO",
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMessage = "[$timestamp] [$Status] $Message"
    Write-Host $logMessage -ForegroundColor $Color
    Add-Content -Path "Duplicate-Hunter-Log.txt" -Value $logMessage
}

function Format-FileSize {
    param([long]$Size)
    if ($Size -gt 1TB) { return "{0:N2} TB" -f ($Size / 1TB) }
    elseif ($Size -gt 1GB) { return "{0:N2} GB" -f ($Size / 1GB) }
    elseif ($Size -gt 1MB) { return "{0:N2} MB" -f ($Size / 1MB) }
    elseif ($Size -gt 1KB) { return "{0:N2} KB" -f ($Size / 1KB) }
    else { return "$Size B" }
}

function Get-ExcludedPaths {
    # Ścieżki do pominięcia podczas skanowania
    return @(
        "$env:WINDIR\System32",
        "$env:WINDIR\SysWOW64",
        "$env:WINDIR\WinSxS",
        "$env:ProgramFiles",
        "${env:ProgramFiles(x86)}",
        "$env:WINDIR\servicing",
        "$env:WINDIR\assembly",
        "C:\`$Recycle.Bin",
        "C:\System Volume Information",
        "C:\Recovery",
        "C:\PerfLogs"
    )
}

function Get-PriorityPaths {
    # Ścieżki o wysokim priorytecie (prawdopodobnie zawierają duplikaty)
    return @(
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\Pictures",
        "$env:USERPROFILE\Videos",
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\OneDrive",
        "$env:LOCALAPPDATA\Temp",
        "$env:TEMP"
    )
}

function Test-ShouldScanPath {
    param($Path, $ExcludedPaths)
    
    foreach ($excludedPath in $ExcludedPaths) {
        if ($Path.StartsWith($excludedPath, [StringComparison]::OrdinalIgnoreCase)) {
            return $false
        }
    }
    return $true
}

function Get-FilesBySize {
    param($TargetDrive, $MinFileSize, $MaxFileSize, $ExcludedPaths)
    
    Write-HunterLog "🔍 Skanowanie plików na dysku $TargetDrive..." "INFO" $Yellow
    Write-HunterLog "   Rozmiar: $(Format-FileSize $MinFileSize) - $(Format-FileSize $MaxFileSize)" "INFO" $Blue
    
    $allFiles = @()
    $scannedFiles = 0
    $skippedPaths = 0
    
    try {
        # Pobierz wszystkie pliki z dysku
        $files = Get-ChildItem -Path $TargetDrive -File -Recurse -Force -ErrorAction SilentlyContinue |
                 Where-Object { 
                     $_.Length -ge $MinFileSize -and 
                     $_.Length -le $MaxFileSize -and
                     (Test-ShouldScanPath -Path $_.DirectoryName -ExcludedPaths $ExcludedPaths)
                 }
        
        foreach ($file in $files) {
            $scannedFiles++
            
            if ($scannedFiles % 1000 -eq 0) {
                Write-Progress -Activity "Skanowanie plików" -Status "Przeskanowano: $scannedFiles plików" -PercentComplete -1
                Write-HunterLog "📊 Przeskanowano: $scannedFiles plików..." "INFO" $Blue
            }
            
            $allFiles += $file
        }
        
        Write-Progress -Completed -Activity "Skanowanie plików"
        
    } catch {
        Write-HunterLog "❌ Błąd skanowania: $($_.Exception.Message)" "ERROR" $Red
    }
    
    Write-HunterLog "✅ Skanowanie zakończone: $scannedFiles plików znalezionych" "OK" $Green
    return $allFiles
}

function Find-DuplicatesByHash {
    param($Files)
    
    Write-HunterLog "🔍 Szukanie duplikatów przez hash MD5..." "INFO" $Yellow
    
    $duplicateGroups = @()
    $processedFiles = 0
    $totalFiles = $Files.Count
    
    # Najpierw grupuj po rozmiarze (szybsze)
    $filesBySize = $Files | Group-Object Length | Where-Object { $_.Count -gt 1 }
    
    Write-HunterLog "📊 Znaleziono $($filesBySize.Count) grup plików o tym samym rozmiarze" "INFO" $Blue
    
    foreach ($sizeGroup in $filesBySize) {
        Write-Progress -Activity "Sprawdzanie hash MD5" -Status "Grupa rozmiaru: $(Format-FileSize $sizeGroup.Name)" -PercentComplete (($processedFiles / $totalFiles) * 100)
        
        # Oblicz hash dla plików o tym samym rozmiarze
        $filesWithHash = @()
        foreach ($file in $sizeGroup.Group) {
            try {
                $hash = Get-FileHash $file.FullName -Algorithm MD5 -ErrorAction SilentlyContinue
                if ($hash) {
                    $filesWithHash += [PSCustomObject]@{
                        File = $file
                        Hash = $hash.Hash
                    }
                }
                $processedFiles++
            } catch {
                # Ignoruj błędy hash (plik może być zablokowany)
                $processedFiles++
            }
        }
        
        # Grupuj po hash - prawdziwe duplikaty
        $hashGroups = $filesWithHash | Group-Object Hash | Where-Object { $_.Count -gt 1 }
        
        foreach ($hashGroup in $hashGroups) {
            $wastedSpace = ($hashGroup.Group[0].File.Length) * ($hashGroup.Count - 1)
            
            $duplicateGroups += [PSCustomObject]@{
                Hash = $hashGroup.Name
                Files = $hashGroup.Group
                Count = $hashGroup.Count
                WastedSpace = $wastedSpace
                FileSize = $hashGroup.Group[0].File.Length
                FileName = $hashGroup.Group[0].File.Name
                Priority = Get-DuplicatePriority -Files $hashGroup.Group
            }
        }
    }
    
    Write-Progress -Completed -Activity "Sprawdzanie hash MD5"
    
    $totalWasted = ($duplicateGroups | Measure-Object WastedSpace -Sum).Sum
    Write-HunterLog "📊 Znaleziono $($duplicateGroups.Count) grup duplikatów" "INFO" $Blue
    Write-HunterLog "💾 Łączne zmarnowane miejsce: $(Format-FileSize $totalWasted)" "WARNING" $Red
    
    return $duplicateGroups
}

function Get-DuplicatePriority {
    param($Files)
    
    # Priorytet na podstawie lokalizacji plików
    $priorityPaths = Get-PriorityPaths
    $priority = 0
    
    foreach ($file in $Files) {
        foreach ($priorityPath in $priorityPaths) {
            if ($file.File.DirectoryName.StartsWith($priorityPath, [StringComparison]::OrdinalIgnoreCase)) {
                $priority += 10
                break
            }
        }
        
        # Dodatkowe punkty za rozmiar pliku
        if ($file.File.Length -gt 10MB) { $priority += 5 }
        elseif ($file.File.Length -gt 1MB) { $priority += 2 }
    }
    
    return $priority
}

function Show-DuplicateAnalysis {
    param($DuplicateGroups)
    
    Write-HunterLog "📊 ANALIZA DUPLIKATÓW" "INFO" $Cyan
    Write-HunterLog "===================" "INFO" $Cyan
    
    # Top 10 największych grup duplikatów
    $topDuplicates = $DuplicateGroups | Sort-Object WastedSpace -Descending | Select-Object -First 10
    
    Write-HunterLog "🔴 TOP 10 NAJWIĘKSZYCH DUPLIKATÓW:" "WARNING" $Red
    foreach ($duplicate in $topDuplicates) {
        Write-HunterLog "   $($duplicate.FileName) - $($duplicate.Count) kopii, $(Format-FileSize $duplicate.WastedSpace) zmarnowane" "WARNING" $Yellow
    }
    
    # Analiza według rozszerzeń
    $extensionAnalysis = $DuplicateGroups | Group-Object { [System.IO.Path]::GetExtension($_.FileName) } |
                        Sort-Object { ($_.Group | Measure-Object WastedSpace -Sum).Sum } -Descending |
                        Select-Object -First 5
    
    Write-HunterLog "" "INFO" $White
    Write-HunterLog "📁 TOP 5 ROZSZERZEŃ Z DUPLIKATAMI:" "INFO" $Blue
    foreach ($ext in $extensionAnalysis) {
        $totalWasted = ($ext.Group | Measure-Object WastedSpace -Sum).Sum
        $extName = if ($ext.Name) { $ext.Name } else { "(brak rozszerzenia)" }
        Write-HunterLog "   $extName - $(Format-FileSize $totalWasted) zmarnowane" "INFO" $Yellow
    }
    
    # Analiza według lokalizacji
    $locationAnalysis = @{}
    foreach ($duplicate in $DuplicateGroups) {
        foreach ($file in $duplicate.Files) {
            $drive = [System.IO.Path]::GetPathRoot($file.File.FullName)
            if (-not $locationAnalysis.ContainsKey($drive)) {
                $locationAnalysis[$drive] = 0
            }
            $locationAnalysis[$drive] += $duplicate.WastedSpace / $duplicate.Count
        }
    }
    
    Write-HunterLog "" "INFO" $White
    Write-HunterLog "💽 DUPLIKATY WEDŁUG DYSKÓW:" "INFO" $Blue
    foreach ($location in $locationAnalysis.GetEnumerator() | Sort-Object Value -Descending) {
        Write-HunterLog "   $($location.Key) - $(Format-FileSize $location.Value) zmarnowane" "INFO" $Yellow
    }
}

function Remove-SelectedDuplicates {
    param($DuplicateGroups, $DryRun, $CreateBackup)
    
    Write-HunterLog "🗑️ USUWANIE DUPLIKATÓW" "INFO" $Cyan
    
    if ($DuplicateGroups.Count -eq 0) {
        Write-HunterLog "⏭️ Brak duplikatów do usunięcia" "INFO" $Blue
        return @{ Count = 0; Size = 0 }
    }
    
    # Sortuj duplikaty po priorytecie i zmarnowanym miejscu
    $sortedDuplicates = $DuplicateGroups | Sort-Object Priority, WastedSpace -Descending
    
    $totalDeleted = 0
    $totalRecovered = 0
    $backupFolder = $null
    
    if ($CreateBackup -and -not $DryRun) {
        $backupFolder = "C:\Duplicate-Backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
        Write-HunterLog "💾 Utworzono folder backup: $backupFolder" "INFO" $Blue
    }
    
    foreach ($duplicate in $sortedDuplicates) {
        Write-HunterLog "🔍 Przetwarzanie: $($duplicate.FileName) ($($duplicate.Count) kopii)" "INFO" $Yellow
        
        # Sortuj pliki po dacie modyfikacji (zachowaj najnowszy)
        $sortedFiles = $duplicate.Files | Sort-Object { $_.File.LastWriteTime } -Descending
        $fileToKeep = $sortedFiles[0]
        $filesToDelete = $sortedFiles | Select-Object -Skip 1
        
        Write-HunterLog "✅ Zachowuję: $($fileToKeep.File.FullName)" "OK" $Green
        
        foreach ($fileToDelete in $filesToDelete) {
            try {
                # Backup jeśli wymagany
                if ($backupFolder -and -not $DryRun) {
                    $backupPath = Join-Path $backupFolder $fileToDelete.File.Name
                    if (Test-Path $backupPath) {
                        $backupPath = Join-Path $backupFolder "$($fileToDelete.File.BaseName)-$(Get-Date -Format 'HHmmss')$($fileToDelete.File.Extension)"
                    }
                    Copy-Item $fileToDelete.File.FullName $backupPath -Force -ErrorAction SilentlyContinue
                }
                
                if (-not $DryRun) {
                    Remove-Item $fileToDelete.File.FullName -Force
                }
                
                Write-HunterLog "🗑️ $(if($DryRun){'[DRY]'}) Usunięto: $($fileToDelete.File.FullName)" "OK" $Green
                $totalDeleted++
                $totalRecovered += $fileToDelete.File.Length
                
            } catch {
                Write-HunterLog "⚠️ Nie można usunąć: $($fileToDelete.File.FullName) - $($_.Exception.Message)" "WARNING" $Yellow
            }
        }
        
        # Pokaż postęp co 10 grup
        if ($totalDeleted % 10 -eq 0) {
            Write-HunterLog "📊 Postęp: $totalDeleted plików usuniętych, $(Format-FileSize $totalRecovered) odzyskane" "INFO" $Blue
        }
    }
    
    Write-HunterLog "✅ Duplikaty: $totalDeleted plików, $(Format-FileSize $totalRecovered) odzyskane" "OK" $Green
    
    if ($backupFolder) {
        Write-HunterLog "💾 Backup dostępny w: $backupFolder" "INFO" $Blue
    }
    
    return @{ Count = $totalDeleted; Size = $totalRecovered }
}

function Export-DuplicateReport {
    param($DuplicateGroups)
    
    $reportPath = "System-Duplicates-Report-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
    $duplicateReport = @()
    
    foreach ($duplicate in $DuplicateGroups) {
        foreach ($file in $duplicate.Files) {
            $duplicateReport += [PSCustomObject]@{
                Hash = $duplicate.Hash
                FileName = $file.File.Name
                FilePath = $file.File.FullName
                Directory = $file.File.DirectoryName
                Size = $file.File.Length
                SizeFormatted = Format-FileSize $file.File.Length
                LastModified = $file.File.LastWriteTime
                Extension = $file.File.Extension
                DuplicateCount = $duplicate.Count
                WastedSpace = $duplicate.WastedSpace
                Priority = $duplicate.Priority
            }
        }
    }
    
    $duplicateReport | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8
    Write-HunterLog "📄 Raport duplikatów zapisany: $reportPath" "INFO" $Blue
    
    return $reportPath
}

# Główna funkcja
function Start-SystemWideDuplicateHunt {
    Write-Host "=== POLOWANIE NA DUPLIKATY W CAŁYM SYSTEMIE ===" -ForegroundColor $Cyan
    Write-Host "Dysk: $TargetDrive" -ForegroundColor $Blue
    Write-Host "Rozmiar plików: $(Format-FileSize $MinFileSize) - $(Format-FileSize $MaxFileSize)" -ForegroundColor $Blue
    Write-Host "Dry Run: $DryRun" -ForegroundColor $Blue
    Write-Host "Backup: $CreateBackup" -ForegroundColor $Blue
    Write-Host ""
    
    if ($DryRun) {
        Write-HunterLog "🔍 TRYB DRY RUN - tylko podgląd zmian" "INFO" $Yellow
    }
    
    # Pobierz ścieżki do wykluczenia
    $excludedPaths = Get-ExcludedPaths
    Write-HunterLog "🚫 Wykluczono $($excludedPaths.Count) ścieżek systemowych" "INFO" $Blue
    
    # Skanuj pliki
    $files = Get-FilesBySize -TargetDrive $TargetDrive -MinFileSize $MinFileSize -MaxFileSize $MaxFileSize -ExcludedPaths $excludedPaths
    
    if ($files.Count -eq 0) {
        Write-HunterLog "❌ Nie znaleziono plików do skanowania" "ERROR" $Red
        return
    }
    
    # Znajdź duplikaty
    $duplicates = Find-DuplicatesByHash -Files $files
    
    if ($duplicates.Count -eq 0) {
        Write-HunterLog "🎉 Nie znaleziono duplikatów!" "OK" $Green
        return
    }
    
    # Pokaż analizę
    Show-DuplicateAnalysis -DuplicateGroups $duplicates
    
    # Eksportuj raport
    $reportPath = Export-DuplicateReport -DuplicateGroups $duplicates
    
    # Zapytaj o usunięcie duplikatów
    if (-not $DryRun) {
        Write-Host ""
        $totalWasted = ($duplicates | Measure-Object WastedSpace -Sum).Sum
        Write-HunterLog "💾 Można odzyskać: $(Format-FileSize $totalWasted)" "WARNING" $Red
        
        $removeDuplicates = Read-Host "Czy chcesz usunąć duplikaty? (t/n)"
        if ($removeDuplicates.ToLower() -eq 't' -or $removeDuplicates.ToLower() -eq 'tak') {
            $result = Remove-SelectedDuplicates -DuplicateGroups $duplicates -DryRun $DryRun -CreateBackup $CreateBackup
            Write-HunterLog "🎉 Usunięto $($result.Count) duplikatów, odzyskano $(Format-FileSize $result.Size)" "OK" $Green
        } else {
            Write-HunterLog "⏭️ Pominięto usuwanie duplikatów" "INFO" $Yellow
        }
    } else {
        $result = Remove-SelectedDuplicates -DuplicateGroups $duplicates -DryRun $DryRun -CreateBackup $CreateBackup
        Write-HunterLog "🔍 [DRY RUN] Można usunąć $($result.Count) duplikatów i odzyskać $(Format-FileSize $result.Size)" "INFO" $Blue
    }
    
    Write-Host ""
    Write-HunterLog "📄 Szczegółowy raport dostępny w: $reportPath" "INFO" $Blue
    Write-HunterLog "🎉 POLOWANIE NA DUPLIKATY ZAKOŃCZONE!" "OK" $Green
}

# Uruchom główną funkcję
Start-SystemWideDuplicateHunt