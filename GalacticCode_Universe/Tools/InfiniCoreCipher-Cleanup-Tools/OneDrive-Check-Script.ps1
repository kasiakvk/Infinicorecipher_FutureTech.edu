<#
.SYNOPSIS
    Skrypt do sprawdzania plików OneDrive w połączeniach C:\ i wykrywania duplikatów

.DESCRIPTION
    Ten skrypt skanuje dysk C:\ w poszukiwaniu folderów OneDrive, analizuje ich zawartość
    i wykrywa potencjalne duplikaty plików na podstawie nazwy, rozmiaru i hash MD5.

.AUTHOR
    Office Agent

.VERSION
    1.0
#>

# Ustawienia kolorów dla lepszej czytelności
$Host.UI.RawUI.ForegroundColor = "White"

# Funkcja do logowania z timestampem
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path "OneDrive-Check-Log.txt" -Value $logMessage
}

# Funkcja do obliczania hash MD5
function Get-FileHashMD5 {
    param([string]$FilePath)
    try {
        $hash = Get-FileHash -Path $FilePath -Algorithm MD5
        return $hash.Hash
    }
    catch {
        return $null
    }
}

# Funkcja do formatowania rozmiaru pliku
function Format-FileSize {
    param([long]$Size)
    if ($Size -gt 1GB) {
        return "{0:N2} GB" -f ($Size / 1GB)
    }
    elseif ($Size -gt 1MB) {
        return "{0:N2} MB" -f ($Size / 1MB)
    }
    elseif ($Size -gt 1KB) {
        return "{0:N2} KB" -f ($Size / 1KB)
    }
    else {
        return "$Size B"
    }
}

# Główna funkcja skryptu
function Start-OneDriveCheck {
    Write-Log "=== ROZPOCZĘCIE SKANOWANIA ONEDRIVE ===" "INFO"
    
    # Sprawdzenie czy dysk C:\ istnieje
    if (-not (Test-Path "C:\")) {
        Write-Log "Dysk C:\ nie jest dostępny!" "ERROR"
        return
    }

    # Wyszukiwanie folderów OneDrive
    Write-Log "Wyszukiwanie folderów OneDrive..." "INFO"
    
    $oneDrivePaths = @()
    $commonPaths = @(
        "C:\Users\*\OneDrive*",
        "C:\OneDrive*",
        "C:\Users\*\Documents\OneDrive*"
    )

    foreach ($path in $commonPaths) {
        try {
            $foundPaths = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue
            if ($foundPaths) {
                $oneDrivePaths += $foundPaths
            }
        }
        catch {
            Write-Log "Błąd podczas skanowania ścieżki $path : $($_.Exception.Message)" "WARNING"
        }
    }

    # Dodatkowe wyszukiwanie w rejestrze
    try {
        $regPaths = Get-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive\Accounts\*" -Name "UserFolder" -ErrorAction SilentlyContinue
        foreach ($regPath in $regPaths) {
            if ($regPath.UserFolder -and (Test-Path $regPath.UserFolder)) {
                $oneDrivePaths += Get-Item $regPath.UserFolder
            }
        }
    }
    catch {
        Write-Log "Nie można odczytać ścieżek OneDrive z rejestru" "WARNING"
    }

    # Usunięcie duplikatów ścieżek
    $oneDrivePaths = $oneDrivePaths | Sort-Object FullName | Get-Unique -AsString

    if ($oneDrivePaths.Count -eq 0) {
        Write-Log "Nie znaleziono żadnych folderów OneDrive!" "WARNING"
        return
    }

    Write-Log "Znaleziono $($oneDrivePaths.Count) folder(ów) OneDrive:" "INFO"
    foreach ($path in $oneDrivePaths) {
        Write-Log "  - $($path.FullName)" "INFO"
    }

    # Analiza każdego folderu OneDrive
    $allFiles = @()
    $totalSize = 0
    $totalFiles = 0

    foreach ($oneDriveFolder in $oneDrivePaths) {
        Write-Log "Analizowanie: $($oneDriveFolder.FullName)" "INFO"
        
        try {
            $files = Get-ChildItem -Path $oneDriveFolder.FullName -File -Recurse -ErrorAction SilentlyContinue
            
            foreach ($file in $files) {
                $fileInfo = [PSCustomObject]@{
                    Name = $file.Name
                    FullPath = $file.FullName
                    Size = $file.Length
                    LastModified = $file.LastWriteTime
                    OneDriveFolder = $oneDriveFolder.FullName
                    Hash = $null
                }
                
                $allFiles += $fileInfo
                $totalSize += $file.Length
                $totalFiles++
            }
            
            Write-Log "  Znaleziono $($files.Count) plików, rozmiar: $(Format-FileSize ($files | Measure-Object Length -Sum).Sum)" "INFO"
        }
        catch {
            Write-Log "Błąd podczas analizy $($oneDriveFolder.FullName): $($_.Exception.Message)" "ERROR"
        }
    }

    Write-Log "PODSUMOWANIE SKANOWANIA:" "INFO"
    Write-Log "  Łączna liczba plików: $totalFiles" "INFO"
    Write-Log "  Łączny rozmiar: $(Format-FileSize $totalSize)" "INFO"

    # Wykrywanie duplikatów
    Write-Log "=== WYKRYWANIE DUPLIKATÓW ===" "INFO"
    
    # Grupowanie po nazwie i rozmiarze
    $potentialDuplicates = $allFiles | Group-Object Name, Size | Where-Object { $_.Count -gt 1 }
    
    if ($potentialDuplicates.Count -eq 0) {
        Write-Log "Nie znaleziono potencjalnych duplikatów na podstawie nazwy i rozmiaru." "INFO"
    }
    else {
        Write-Log "Znaleziono $($potentialDuplicates.Count) grup potencjalnych duplikatów:" "WARNING"
        
        $duplicateGroups = @()
        
        foreach ($group in $potentialDuplicates) {
            Write-Log "Grupa duplikatów: $($group.Name)" "INFO"
            
            # Obliczanie hash dla dokładnego porównania
            $filesWithHash = @()
            foreach ($file in $group.Group) {
                Write-Progress -Activity "Obliczanie hash MD5" -Status "Plik: $($file.Name)" -PercentComplete (($filesWithHash.Count / $group.Group.Count) * 100)
                
                $file.Hash = Get-FileHashMD5 -FilePath $file.FullPath
                $filesWithHash += $file
                
                Write-Log "  - $($file.FullPath) [$(Format-FileSize $file.Size)] [Hash: $($file.Hash)]" "INFO"
            }
            
            # Grupowanie po hash - prawdziwe duplikaty
            $realDuplicates = $filesWithHash | Where-Object { $_.Hash -ne $null } | Group-Object Hash | Where-Object { $_.Count -gt 1 }
            
            if ($realDuplicates) {
                foreach ($dupGroup in $realDuplicates) {
                    $duplicateGroups += [PSCustomObject]@{
                        Hash = $dupGroup.Name
                        Files = $dupGroup.Group
                        Count = $dupGroup.Count
                        TotalSize = ($dupGroup.Group | Measure-Object Size -Sum).Sum
                        WastedSpace = ($dupGroup.Group | Measure-Object Size -Sum).Sum * ($dupGroup.Count - 1)
                    }
                }
            }
        }
        
        Write-Progress -Completed -Activity "Obliczanie hash MD5"
        
        if ($duplicateGroups.Count -gt 0) {
            Write-Log "=== PRAWDZIWE DUPLIKATY (identyczny hash MD5) ===" "ERROR"
            
            $totalWastedSpace = 0
            foreach ($dupGroup in $duplicateGroups) {
                Write-Log "Duplikat - Hash: $($dupGroup.Hash)" "ERROR"
                Write-Log "  Liczba kopii: $($dupGroup.Count)" "ERROR"
                Write-Log "  Rozmiar pojedynczego pliku: $(Format-FileSize ($dupGroup.Files[0].Size))" "ERROR"
                Write-Log "  Zmarnowane miejsce: $(Format-FileSize $dupGroup.WastedSpace)" "ERROR"
                
                foreach ($file in $dupGroup.Files) {
                    Write-Log "    -> $($file.FullPath)" "ERROR"
                }
                Write-Log "" "INFO"
                
                $totalWastedSpace += $dupGroup.WastedSpace
            }
            
            Write-Log "ŁĄCZNE ZMARNOWANE MIEJSCE: $(Format-FileSize $totalWastedSpace)" "ERROR"
        }
        else {
            Write-Log "Pliki o identycznych nazwach i rozmiarach mają różne hash - nie są duplikatami." "INFO"
        }
    }

    # Generowanie raportu CSV
    Write-Log "Generowanie raportu CSV..." "INFO"
    
    $reportPath = "OneDrive-Report-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
    $allFiles | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8
    
    Write-Log "Raport zapisany w: $reportPath" "INFO"
    
    # Generowanie raportu duplikatów
    if ($duplicateGroups.Count -gt 0) {
        $duplicateReportPath = "OneDrive-Duplicates-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
        $duplicateReport = @()
        
        foreach ($dupGroup in $duplicateGroups) {
            foreach ($file in $dupGroup.Files) {
                $duplicateReport += [PSCustomObject]@{
                    Hash = $dupGroup.Hash
                    FileName = $file.Name
                    FilePath = $file.FullPath
                    Size = $file.Size
                    SizeFormatted = Format-FileSize $file.Size
                    LastModified = $file.LastModified
                    OneDriveFolder = $file.OneDriveFolder
                    DuplicateCount = $dupGroup.Count
                    WastedSpace = $dupGroup.WastedSpace
                }
            }
        }
        
        $duplicateReport | Export-Csv -Path $duplicateReportPath -NoTypeInformation -Encoding UTF8
        Write-Log "Raport duplikatów zapisany w: $duplicateReportPath" "INFO"
    }

    Write-Log "=== SKANOWANIE ZAKOŃCZONE ===" "INFO"
}

# Sprawdzenie uprawnień administratora
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Główne wykonanie skryptu
Clear-Host
Write-Host "=== SKRYPT SPRAWDZANIA ONEDRIVE I DUPLIKATÓW ===" -ForegroundColor Cyan
Write-Host "Autor: Office Agent" -ForegroundColor Gray
Write-Host "Data: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

if (-not (Test-Administrator)) {
    Write-Host "UWAGA: Skrypt nie jest uruchomiony jako administrator." -ForegroundColor Yellow
    Write-Host "Niektóre foldery mogą być niedostępne." -ForegroundColor Yellow
    Write-Host ""
}

# Potwierdzenie uruchomienia
$confirmation = Read-Host "Czy chcesz rozpocząć skanowanie OneDrive? (T/N)"
if ($confirmation -eq 'T' -or $confirmation -eq 't' -or $confirmation -eq 'Y' -or $confirmation -eq 'y') {
    Start-OneDriveCheck
}
else {
    Write-Host "Skanowanie anulowane przez użytkownika." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Naciśnij dowolny klawisz aby zakończyć..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")