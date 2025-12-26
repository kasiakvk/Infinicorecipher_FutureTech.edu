<#
.SYNOPSIS
    Główny launcher do kompleksowego czyszczenia systemu

.DESCRIPTION
    Centralny punkt uruchamiania wszystkich skryptów czyszczenia:
    - OneDrive cleanup
    - System-wide cleanup
    - InfiniCoreCipher cleanup
    - Duplicate hunting

.PARAMETER Mode
    Tryb czyszczenia: Quick, Full, Custom, OneDriveOnly, ProjectOnly

.PARAMETER DryRun
    Tryb podglądu bez usuwania plików

.EXAMPLE
    .\Master-Cleanup-Launcher.ps1 -Mode Quick -DryRun
    .\Master-Cleanup-Launcher.ps1 -Mode Full
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Quick", "Full", "Custom", "OneDriveOnly", "ProjectOnly")]
    [string]$Mode = "Custom",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false
)

# Kolory
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Blue = "Blue"
$Magenta = "Magenta"

function Write-MasterLog {
    param(
        [string]$Message,
        [string]$Status = "INFO",
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMessage = "[$timestamp] [$Status] $Message"
    Write-Host $logMessage -ForegroundColor $Color
    Add-Content -Path "Master-Cleanup-Log.txt" -Value $logMessage
}

function Format-FileSize {
    param([long]$Size)
    if ($Size -gt 1TB) { return "{0:N2} TB" -f ($Size / 1TB) }
    elseif ($Size -gt 1GB) { return "{0:N2} GB" -f ($Size / 1GB) }
    elseif ($Size -gt 1MB) { return "{0:N2} MB" -f ($Size / 1MB) }
    elseif ($Size -gt 1KB) { return "{0:N2} KB" -f ($Size / 1KB) }
    else { return "$Size B" }
}

function Get-DiskSpace {
    param([string]$Drive = "C:")
    
    try {
        $disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$Drive'"
        return @{
            TotalSize = $disk.Size
            FreeSpace = $disk.FreeSpace
            UsedSpace = $disk.Size - $disk.FreeSpace
        }
    } catch {
        return $null
    }
}

function Test-ScriptAvailability {
    $scripts = @{
        "OneDrive-Check-Script.ps1" = "Skanowanie OneDrive i wykrywanie duplikatów"
        "OneDrive-Safe-Cleanup.ps1" = "Bezpieczne czyszczenie duplikatów OneDrive"
        "Deep-System-Cleanup.ps1" = "Głębokie czyszczenie systemu"
        "InfiniCoreCipher-Specific-Cleanup.ps1" = "Czyszczenie projektu InfiniCoreCipher"
        "System-Wide-Duplicate-Hunter.ps1" = "Polowanie na duplikaty w całym systemie"
    }
    
    Write-MasterLog "🔍 Sprawdzanie dostępnych skryptów..." "INFO" $Yellow
    
    $availableScripts = @{}
    foreach ($script in $scripts.GetEnumerator()) {
        if (Test-Path $script.Key) {
            Write-MasterLog "✅ $($script.Key) - dostępny" "OK" $Green
            $availableScripts[$script.Key] = $script.Value
        } else {
            Write-MasterLog "❌ $($script.Key) - brak" "ERROR" $Red
        }
    }
    
    return $availableScripts
}

function Show-CleanupMenu {
    param($AvailableScripts)
    
    Write-Host ""
    Write-MasterLog "📋 DOSTĘPNE OPCJE CZYSZCZENIA:" "INFO" $Cyan
    Write-Host ""
    
    Write-Host "🚀 TRYBY AUTOMATYCZNE:" -ForegroundColor $Magenta
    Write-Host "  1. Quick Clean    - OneDrive + InfiniCoreCipher (szybko)" -ForegroundColor $Blue
    Write-Host "  2. Full Clean     - Wszystko + duplikaty systemowe (dokładnie)" -ForegroundColor $Blue
    Write-Host "  3. OneDrive Only  - Tylko czyszczenie OneDrive" -ForegroundColor $Blue
    Write-Host "  4. Project Only   - Tylko projekt InfiniCoreCipher" -ForegroundColor $Blue
    Write-Host ""
    
    Write-Host "🎯 OPCJE RĘCZNE:" -ForegroundColor $Magenta
    $menuIndex = 5
    $scriptMenu = @{}
    
    foreach ($script in $AvailableScripts.GetEnumerator()) {
        Write-Host "  $menuIndex. $($script.Value)" -ForegroundColor $Yellow
        $scriptMenu[$menuIndex] = $script.Key
        $menuIndex++
    }
    
    Write-Host ""
    Write-Host "  0. ❌ Anuluj" -ForegroundColor $Red
    Write-Host ""
    
    return $scriptMenu
}

function Execute-QuickClean {
    param($DryRun)
    
    Write-MasterLog "🚀 ROZPOCZĘCIE QUICK CLEAN" "INFO" $Cyan
    
    $results = @()
    
    # 1. OneDrive Quick Check
    if (Test-Path "OneDrive-Quick-Check.ps1") {
        Write-MasterLog "📊 Krok 1/3: OneDrive Quick Check" "INFO" $Yellow
        & ".\OneDrive-Quick-Check.ps1"
        $results += "OneDrive Quick Check - zakończony"
    }
    
    # 2. InfiniCoreCipher Cleanup
    if (Test-Path "InfiniCoreCipher-Specific-Cleanup.ps1") {
        Write-MasterLog "🔧 Krok 2/3: InfiniCoreCipher Cleanup" "INFO" $Yellow
        if ($DryRun) {
            & ".\InfiniCoreCipher-Specific-Cleanup.ps1" -DryRun
        } else {
            & ".\InfiniCoreCipher-Specific-Cleanup.ps1"
        }
        $results += "InfiniCoreCipher Cleanup - zakończony"
    }
    
    # 3. OneDrive Duplicates (tylko skanowanie)
    if (Test-Path "OneDrive-Check-Script.ps1") {
        Write-MasterLog "🔍 Krok 3/3: OneDrive Duplicate Scan" "INFO" $Yellow
        & ".\OneDrive-Check-Script.ps1"
        $results += "OneDrive Duplicate Scan - zakończony"
    }
    
    return $results
}

function Execute-FullClean {
    param($DryRun)
    
    Write-MasterLog "🚀 ROZPOCZĘCIE FULL CLEAN" "INFO" $Cyan
    
    $results = @()
    
    # 1. OneDrive Full Scan
    if (Test-Path "OneDrive-Check-Script.ps1") {
        Write-MasterLog "📊 Krok 1/5: OneDrive Full Scan" "INFO" $Yellow
        & ".\OneDrive-Check-Script.ps1"
        $results += "OneDrive Full Scan - zakończony"
    }
    
    # 2. OneDrive Cleanup
    if (Test-Path "OneDrive-Safe-Cleanup.ps1") {
        Write-MasterLog "🧹 Krok 2/5: OneDrive Cleanup" "INFO" $Yellow
        & ".\OneDrive-Safe-Cleanup.ps1"
        $results += "OneDrive Cleanup - zakończony"
    }
    
    # 3. InfiniCoreCipher Cleanup
    if (Test-Path "InfiniCoreCipher-Specific-Cleanup.ps1") {
        Write-MasterLog "🔧 Krok 3/5: InfiniCoreCipher Cleanup" "INFO" $Yellow
        if ($DryRun) {
            & ".\InfiniCoreCipher-Specific-Cleanup.ps1" -DryRun
        } else {
            & ".\InfiniCoreCipher-Specific-Cleanup.ps1"
        }
        $results += "InfiniCoreCipher Cleanup - zakończony"
    }
    
    # 4. System-wide Cleanup
    if (Test-Path "Deep-System-Cleanup.ps1") {
        Write-MasterLog "🗑️ Krok 4/5: Deep System Cleanup" "INFO" $Yellow
        if ($DryRun) {
            & ".\Deep-System-Cleanup.ps1" -DryRun
        } else {
            & ".\Deep-System-Cleanup.ps1"
        }
        $results += "Deep System Cleanup - zakończony"
    }
    
    # 5. System-wide Duplicate Hunt
    if (Test-Path "System-Wide-Duplicate-Hunter.ps1") {
        Write-MasterLog "🎯 Krok 5/5: System-wide Duplicate Hunt" "INFO" $Yellow
        if ($DryRun) {
            & ".\System-Wide-Duplicate-Hunter.ps1" -DryRun
        } else {
            & ".\System-Wide-Duplicate-Hunter.ps1"
        }
        $results += "System-wide Duplicate Hunt - zakończony"
    }
    
    return $results
}

function Execute-OneDriveOnly {
    param($DryRun)
    
    Write-MasterLog "🚀 ROZPOCZĘCIE ONEDRIVE ONLY CLEAN" "INFO" $Cyan
    
    $results = @()
    
    # 1. OneDrive Scan
    if (Test-Path "OneDrive-Check-Script.ps1") {
        Write-MasterLog "📊 Krok 1/2: OneDrive Scan" "INFO" $Yellow
        & ".\OneDrive-Check-Script.ps1"
        $results += "OneDrive Scan - zakończony"
    }
    
    # 2. OneDrive Cleanup
    if (Test-Path "OneDrive-Safe-Cleanup.ps1") {
        Write-MasterLog "🧹 Krok 2/2: OneDrive Cleanup" "INFO" $Yellow
        & ".\OneDrive-Safe-Cleanup.ps1"
        $results += "OneDrive Cleanup - zakończony"
    }
    
    return $results
}

function Execute-ProjectOnly {
    param($DryRun)
    
    Write-MasterLog "🚀 ROZPOCZĘCIE PROJECT ONLY CLEAN" "INFO" $Cyan
    
    $results = @()
    
    # InfiniCoreCipher Cleanup
    if (Test-Path "InfiniCoreCipher-Specific-Cleanup.ps1") {
        Write-MasterLog "🔧 InfiniCoreCipher Cleanup" "INFO" $Yellow
        if ($DryRun) {
            & ".\InfiniCoreCipher-Specific-Cleanup.ps1" -DryRun
        } else {
            & ".\InfiniCoreCipher-Specific-Cleanup.ps1"
        }
        $results += "InfiniCoreCipher Cleanup - zakończony"
    }
    
    return $results
}

function Execute-CustomScript {
    param($ScriptPath, $DryRun)
    
    Write-MasterLog "🎯 Uruchamianie: $ScriptPath" "INFO" $Yellow
    
    try {
        if ($DryRun -and $ScriptPath -notlike "*OneDrive-Quick-Check*") {
            & ".\$ScriptPath" -DryRun
        } else {
            & ".\$ScriptPath"
        }
        Write-MasterLog "✅ $ScriptPath - zakończony pomyślnie" "OK" $Green
        return "$ScriptPath - zakończony pomyślnie"
    } catch {
        Write-MasterLog "❌ $ScriptPath - błąd: $($_.Exception.Message)" "ERROR" $Red
        return "$ScriptPath - błąd"
    }
}

function Show-CleanupSummary {
    param($InitialSpace, $FinalSpace, $Results, $ExecutionTime)
    
    Write-Host ""
    Write-MasterLog "📊 PODSUMOWANIE MASTER CLEANUP" "INFO" $Cyan
    Write-MasterLog "==============================" "INFO" $Cyan
    
    if ($InitialSpace -and $FinalSpace) {
        $recoveredSpace = $FinalSpace.FreeSpace - $InitialSpace.FreeSpace
        Write-MasterLog "💾 Miejsce przed: $(Format-FileSize $InitialSpace.FreeSpace)" "INFO" $Blue
        Write-MasterLog "💾 Miejsce po: $(Format-FileSize $FinalSpace.FreeSpace)" "INFO" $Blue
        
        if ($recoveredSpace -gt 0) {
            Write-MasterLog "📈 Odzyskane miejsce: $(Format-FileSize $recoveredSpace)" "OK" $Green
            $improvementPercent = ($recoveredSpace / $InitialSpace.TotalSize) * 100
            Write-MasterLog "📊 Poprawa: {0:N2}% dysku" -f $improvementPercent "OK" $Green
        } else {
            Write-MasterLog "📊 Brak znaczącej zmiany miejsca na dysku" "INFO" $Yellow
        }
    }
    
    Write-MasterLog "⏱️ Czas wykonania: $($ExecutionTime.ToString('hh\:mm\:ss'))" "INFO" $Blue
    Write-MasterLog "🔧 Wykonane operacje: $($Results.Count)" "INFO" $Blue
    
    Write-Host ""
    Write-MasterLog "📋 LISTA WYKONANYCH OPERACJI:" "INFO" $Blue
    foreach ($result in $Results) {
        Write-MasterLog "   ✅ $result" "OK" $Green
    }
    
    Write-Host ""
    Write-MasterLog "📄 Szczegółowe logi dostępne w:" "INFO" $Blue
    $logFiles = Get-ChildItem -Filter "*-Log.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 5
    foreach ($logFile in $logFiles) {
        Write-MasterLog "   📄 $($logFile.Name)" "INFO" $Yellow
    }
    
    Write-Host ""
    Write-MasterLog "🎉 MASTER CLEANUP ZAKOŃCZONY!" "OK" $Green
}

# Główna funkcja
function Start-MasterCleanup {
    $startTime = Get-Date
    
    Write-Host "=== MASTER CLEANUP LAUNCHER ===" -ForegroundColor $Cyan
    Write-Host "Tryb: $Mode" -ForegroundColor $Blue
    Write-Host "Dry Run: $DryRun" -ForegroundColor $Blue
    Write-Host ""
    
    if ($DryRun) {
        Write-MasterLog "🔍 TRYB DRY RUN - tylko podgląd zmian" "INFO" $Yellow
    }
    
    # Sprawdź początkowe miejsce na dysku
    $initialSpace = Get-DiskSpace
    if ($initialSpace) {
        Write-MasterLog "💾 Wolne miejsce na początku: $(Format-FileSize $initialSpace.FreeSpace)" "INFO" $Blue
    }
    
    # Sprawdź dostępne skrypty
    $availableScripts = Test-ScriptAvailability
    
    if ($availableScripts.Count -eq 0) {
        Write-MasterLog "❌ Brak dostępnych skryptów czyszczenia!" "ERROR" $Red
        return
    }
    
    $results = @()
    
    # Wykonaj czyszczenie według trybu
    switch ($Mode) {
        "Quick" {
            $results = Execute-QuickClean -DryRun $DryRun
        }
        "Full" {
            $results = Execute-FullClean -DryRun $DryRun
        }
        "OneDriveOnly" {
            $results = Execute-OneDriveOnly -DryRun $DryRun
        }
        "ProjectOnly" {
            $results = Execute-ProjectOnly -DryRun $DryRun
        }
        "Custom" {
            $scriptMenu = Show-CleanupMenu -AvailableScripts $availableScripts
            
            do {
                $choice = Read-Host "Wybierz opcję (0-$($scriptMenu.Count + 4))"
                
                switch ($choice) {
                    "1" { $results = Execute-QuickClean -DryRun $DryRun; break }
                    "2" { $results = Execute-FullClean -DryRun $DryRun; break }
                    "3" { $results = Execute-OneDriveOnly -DryRun $DryRun; break }
                    "4" { $results = Execute-ProjectOnly -DryRun $DryRun; break }
                    "0" { 
                        Write-MasterLog "❌ Anulowano przez użytkownika" "INFO" $Yellow
                        return
                    }
                    default {
                        $choiceInt = [int]$choice
                        if ($scriptMenu.ContainsKey($choiceInt)) {
                            $result = Execute-CustomScript -ScriptPath $scriptMenu[$choiceInt] -DryRun $DryRun
                            $results += $result
                        } else {
                            Write-MasterLog "❌ Nieprawidłowy wybór: $choice" "ERROR" $Red
                            continue
                        }
                    }
                }
                break
            } while ($true)
        }
    }
    
    # Sprawdź końcowe miejsce na dysku
    $finalSpace = Get-DiskSpace
    $executionTime = (Get-Date) - $startTime
    
    # Podsumowanie
    Show-CleanupSummary -InitialSpace $initialSpace -FinalSpace $finalSpace -Results $results -ExecutionTime $executionTime
}

# Uruchom główną funkcję
Start-MasterCleanup