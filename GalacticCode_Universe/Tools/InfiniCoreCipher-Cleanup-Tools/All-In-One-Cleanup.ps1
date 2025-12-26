# ===============================================
# All-In-One-Cleanup.ps1
# Kompletny skrypt czyszczenia OneDrive i systemu
# Wszystkie funkcje w jednym pliku!
# ===============================================

param(
    [ValidateSet("Quick", "Full", "OneDriveOnly", "SystemOnly", "DuplicatesOnly")]
    [string]$Mode = "Menu",
    [switch]$DryRun = $false,
    [string]$OneDrivePath = "",
    [string]$ProjectPath = "C:\InfiniCoreCipher",
    [int]$MinFileSize = 1024,  # 1KB
    [int]$MaxFileSize = 52428800  # 50MB
)

# ===============================================
# FUNKCJE POMOCNICZE
# ===============================================

function Write-ColorText {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

function Get-FriendlySize {
    param([long]$Bytes)
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    elseif ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    elseif ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    else { return "$Bytes B" }
}

function Get-FileHash-MD5 {
    param([string]$FilePath)
    try {
        $hash = Get-FileHash -Path $FilePath -Algorithm MD5
        return $hash.Hash
    } catch {
        return $null
    }
}

function Show-Menu {
    Clear-Host
    Write-ColorText "🧹 ALL-IN-ONE CLEANUP TOOL 🧹" "Cyan"
    Write-ColorText "=================================" "Cyan"
    Write-Host ""
    Write-ColorText "Wybierz tryb czyszczenia:" "Yellow"
    Write-Host ""
    Write-ColorText "1. Quick    - OneDrive + InfiniCoreCipher (szybko)" "Green"
    Write-ColorText "2. Full     - Wszystko (system + OneDrive + projekt)" "Red"
    Write-ColorText "3. OneDrive - Tylko OneDrive i duplikaty" "Blue"
    Write-ColorText "4. System   - Tylko czyszczenie systemowe" "Magenta"
    Write-ColorText "5. Duplicates - Tylko polowanie na duplikaty" "Yellow"
    Write-ColorText "6. Exit     - Wyjście" "Gray"
    Write-Host ""
    
    $choice = Read-Host "Wybierz opcję (1-6)"
    
    switch ($choice) {
        "1" { return "Quick" }
        "2" { return "Full" }
        "3" { return "OneDriveOnly" }
        "4" { return "SystemOnly" }
        "5" { return "DuplicatesOnly" }
        "6" { exit }
        default { 
            Write-ColorText "Nieprawidłowy wybór! Spróbuj ponownie." "Red"
            Start-Sleep 2
            return Show-Menu
        }
    }
}

function Get-OneDrivePath {
    $possiblePaths = @(
        "$env:USERPROFILE\OneDrive",
        "$env:USERPROFILE\OneDrive - Personal",
        "$env:USERPROFILE\OneDrive - Business",
        "$env:USERPROFILE\OneDrive\kasiakvk20@gmail.com\OneDrive\one drive\OneDrive infinicorecipher"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            Write-ColorText "✅ Znaleziono OneDrive: $path" "Green"
            return $path
        }
    }
    
    Write-ColorText "⚠️ Nie znaleziono OneDrive. Podaj ścieżkę ręcznie:" "Yellow"
    $manualPath = Read-Host "Ścieżka do OneDrive"
    if (Test-Path $manualPath) {
        return $manualPath
    } else {
        Write-ColorText "❌ Podana ścieżka nie istnieje!" "Red"
        return $null
    }
}

# ===============================================
# FUNKCJA 1: CZYSZCZENIE ONEDRIVE
# ===============================================

function Start-OneDriveCleanup {
    param([string]$OneDrivePath, [bool]$DryRun)
    
    Write-ColorText "`n🔍 SKANOWANIE ONEDRIVE..." "Cyan"
    Write-ColorText "Ścieżka: $OneDrivePath" "White"
    
    if (-not (Test-Path $OneDrivePath)) {
        Write-ColorText "❌ OneDrive nie znaleziony!" "Red"
        return
    }
    
    $duplicates = @{}
    $totalSize = 0
    $duplicateSize = 0
    $fileCount = 0
    
    Write-ColorText "📊 Skanowanie plików..." "Yellow"
    
    Get-ChildItem -Path $OneDrivePath -Recurse -File | ForEach-Object {
        $fileCount++
        if ($fileCount % 100 -eq 0) {
            Write-Progress -Activity "Skanowanie OneDrive" -Status "Przetworzono $fileCount plików" -PercentComplete -1
        }
        
        $hash = Get-FileHash-MD5 $_.FullName
        if ($hash) {
            $totalSize += $_.Length
            
            if ($duplicates.ContainsKey($hash)) {
                $duplicates[$hash] += @{
                    Path = $_.FullName
                    Size = $_.Length
                    LastWrite = $_.LastWriteTime
                }
                $duplicateSize += $_.Length
            } else {
                $duplicates[$hash] = @(@{
                    Path = $_.FullName
                    Size = $_.Length
                    LastWrite = $_.LastWriteTime
                })
            }
        }
    }
    
    Write-Progress -Activity "Skanowanie OneDrive" -Completed
    
    # Znajdź rzeczywiste duplikaty
    $realDuplicates = $duplicates.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }
    
    Write-ColorText "`n📋 WYNIKI SKANOWANIA ONEDRIVE:" "Green"
    Write-ColorText "Całkowity rozmiar: $(Get-FriendlySize $totalSize)" "White"
    Write-ColorText "Znalezione duplikaty: $($realDuplicates.Count) grup" "Yellow"
    Write-ColorText "Rozmiar duplikatów: $(Get-FriendlySize $duplicateSize)" "Red"
    
    if ($realDuplicates.Count -eq 0) {
        Write-ColorText "✅ Brak duplikatów w OneDrive!" "Green"
        return
    }
    
    # Pokaż top 5 największych duplikatów
    Write-ColorText "`n🔝 TOP 5 NAJWIĘKSZYCH DUPLIKATÓW:" "Cyan"
    $realDuplicates | Sort-Object { ($_.Value | Measure-Object Size -Sum).Sum } -Descending | Select-Object -First 5 | ForEach-Object {
        $groupSize = ($_.Value | Measure-Object Size -Sum).Sum
        $fileName = Split-Path $_.Value[0].Path -Leaf
        Write-ColorText "• $fileName - $(Get-FriendlySize $groupSize) ($($_.Value.Count) kopii)" "White"
    }
    
    if (-not $DryRun) {
        Write-ColorText "`n❓ Czy usunąć duplikaty? (zachowa najnowsze wersje)" "Yellow"
        $confirm = Read-Host "Wpisz 'TAK' aby kontynuować"
        
        if ($confirm -eq "TAK") {
            $removedSize = 0
            $removedCount = 0
            
            foreach ($group in $realDuplicates) {
                $files = $group.Value | Sort-Object LastWrite -Descending
                # Zachowaj najnowszy, usuń resztę
                for ($i = 1; $i -lt $files.Count; $i++) {
                    try {
                        Remove-Item $files[$i].Path -Force
                        $removedSize += $files[$i].Size
                        $removedCount++
                        Write-ColorText "🗑️ Usunięto: $(Split-Path $files[$i].Path -Leaf)" "Gray"
                    } catch {
                        Write-ColorText "❌ Błąd usuwania: $($files[$i].Path)" "Red"
                    }
                }
            }
            
            Write-ColorText "`n✅ ONEDRIVE CLEANUP ZAKOŃCZONY!" "Green"
            Write-ColorText "Usunięto: $removedCount plików" "White"
            Write-ColorText "Odzyskano: $(Get-FriendlySize $removedSize)" "Green"
        }
    } else {
        Write-ColorText "`n👁️ TRYB PODGLĄDU - nic nie zostało usunięte" "Yellow"
    }
}

# ===============================================
# FUNKCJA 2: CZYSZCZENIE SYSTEMU
# ===============================================

function Start-SystemCleanup {
    param([bool]$DryRun)
    
    Write-ColorText "`n🧹 CZYSZCZENIE SYSTEMU..." "Cyan"
    
    $cleanupPaths = @(
        "$env:TEMP",
        "$env:LOCALAPPDATA\Temp",
        "$env:WINDIR\Temp",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
        "$env:APPDATA\Microsoft\Windows\Recent",
        "$env:LOCALAPPDATA\CrashDumps"
    )
    
    $totalCleaned = 0
    $filesCleaned = 0
    
    foreach ($path in $cleanupPaths) {
        if (Test-Path $path) {
            Write-ColorText "🔍 Czyszczenie: $path" "Yellow"
            
            try {
                $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue
                foreach ($file in $files) {
                    try {
                        if (-not $DryRun) {
                            Remove-Item $file.FullName -Force -ErrorAction SilentlyContinue
                        }
                        $totalCleaned += $file.Length
                        $filesCleaned++
                    } catch {
                        # Ignoruj błędy - niektóre pliki mogą być zablokowane
                    }
                }
            } catch {
                Write-ColorText "⚠️ Nie można wyczyścić: $path" "Yellow"
            }
        }
    }
    
    # Uruchom Windows Disk Cleanup
    if (-not $DryRun) {
        Write-ColorText "🔧 Uruchamianie Windows Disk Cleanup..." "Yellow"
        try {
            Start-Process "cleanmgr" -ArgumentList "/sagerun:1" -Wait -WindowStyle Hidden
        } catch {
            Write-ColorText "⚠️ Nie można uruchomić Disk Cleanup" "Yellow"
        }
    }
    
    Write-ColorText "`n✅ CZYSZCZENIE SYSTEMU ZAKOŃCZONE!" "Green"
    Write-ColorText "Pliki: $filesCleaned" "White"
    Write-ColorText "Rozmiar: $(Get-FriendlySize $totalCleaned)" "Green"
}

# ===============================================
# FUNKCJA 3: CZYSZCZENIE PROJEKTU INFINICORECIPHER
# ===============================================

function Start-ProjectCleanup {
    param([string]$ProjectPath, [bool]$DryRun)
    
    Write-ColorText "`n🎯 CZYSZCZENIE PROJEKTU INFINICORECIPHER..." "Cyan"
    
    if (-not (Test-Path $ProjectPath)) {
        Write-ColorText "⚠️ Projekt nie znaleziony: $ProjectPath" "Yellow"
        return
    }
    
    $cleanupPatterns = @(
        "node_modules",
        "dist",
        "build", 
        ".next",
        "coverage",
        "*.log",
        "*.tmp",
        "*.temp",
        ".cache",
        "*.swp",
        "*.swo"
    )
    
    $totalCleaned = 0
    $itemsCleaned = 0
    
    foreach ($pattern in $cleanupPatterns) {
        Write-ColorText "🔍 Szukanie: $pattern" "Yellow"
        
        try {
            $items = Get-ChildItem -Path $ProjectPath -Recurse -Name $pattern -ErrorAction SilentlyContinue
            
            foreach ($item in $items) {
                $fullPath = Join-Path $ProjectPath $item
                try {
                    if (Test-Path $fullPath) {
                        $size = (Get-ChildItem $fullPath -Recurse -File | Measure-Object Length -Sum).Sum
                        
                        if (-not $DryRun) {
                            Remove-Item $fullPath -Recurse -Force -ErrorAction SilentlyContinue
                        }
                        
                        $totalCleaned += $size
                        $itemsCleaned++
                        Write-ColorText "🗑️ $(if($DryRun){'[PODGLĄD]'}) Usunięto: $item" "Gray"
                    }
                } catch {
                    Write-ColorText "❌ Błąd usuwania: $item" "Red"
                }
            }
        } catch {
            # Ignoruj błędy wyszukiwania
        }
    }
    
    Write-ColorText "`n✅ CZYSZCZENIE PROJEKTU ZAKOŃCZONE!" "Green"
    Write-ColorText "Elementy: $itemsCleaned" "White"
    Write-ColorText "Rozmiar: $(Get-FriendlySize $totalCleaned)" "Green"
}

# ===============================================
# FUNKCJA 4: POLOWANIE NA DUPLIKATY
# ===============================================

function Start-DuplicateHunt {
    param([bool]$DryRun, [int]$MinSize, [int]$MaxSize)
    
    Write-ColorText "`n🎯 POLOWANIE NA DUPLIKATY..." "Cyan"
    
    $searchPaths = @(
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Documents", 
        "$env:USERPROFILE\Pictures",
        "$env:USERPROFILE\Videos",
        "$env:USERPROFILE\Desktop"
    )
    
    $duplicates = @{}
    $totalScanned = 0
    $duplicateSize = 0
    
    foreach ($searchPath in $searchPaths) {
        if (Test-Path $searchPath) {
            Write-ColorText "🔍 Skanowanie: $searchPath" "Yellow"
            
            Get-ChildItem -Path $searchPath -Recurse -File | Where-Object { 
                $_.Length -ge $MinSize -and $_.Length -le $MaxSize 
            } | ForEach-Object {
                $totalScanned++
                if ($totalScanned % 50 -eq 0) {
                    Write-Progress -Activity "Skanowanie duplikatów" -Status "Przetworzono $totalScanned plików" -PercentComplete -1
                }
                
                $hash = Get-FileHash-MD5 $_.FullName
                if ($hash) {
                    if ($duplicates.ContainsKey($hash)) {
                        $duplicates[$hash] += @{
                            Path = $_.FullName
                            Size = $_.Length
                            LastWrite = $_.LastWriteTime
                        }
                        $duplicateSize += $_.Length
                    } else {
                        $duplicates[$hash] = @(@{
                            Path = $_.FullName
                            Size = $_.Length
                            LastWrite = $_.LastWriteTime
                        })
                    }
                }
            }
        }
    }
    
    Write-Progress -Activity "Skanowanie duplikatów" -Completed
    
    $realDuplicates = $duplicates.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }
    
    Write-ColorText "`n📋 WYNIKI POLOWANIA NA DUPLIKATY:" "Green"
    Write-ColorText "Przeskanowano: $totalScanned plików" "White"
    Write-ColorText "Znalezione duplikaty: $($realDuplicates.Count) grup" "Yellow"
    Write-ColorText "Potencjalne oszczędności: $(Get-FriendlySize $duplicateSize)" "Red"
    
    if ($realDuplicates.Count -eq 0) {
        Write-ColorText "✅ Brak duplikatów!" "Green"
        return
    }
    
    # Pokaż szczegóły
    Write-ColorText "`n🔝 NAJWIĘKSZE DUPLIKATY:" "Cyan"
    $realDuplicates | Sort-Object { ($_.Value | Measure-Object Size -Sum).Sum } -Descending | Select-Object -First 10 | ForEach-Object {
        $groupSize = ($_.Value | Measure-Object Size -Sum).Sum
        $fileName = Split-Path $_.Value[0].Path -Leaf
        Write-ColorText "• $fileName - $(Get-FriendlySize $groupSize) ($($_.Value.Count) kopii)" "White"
        
        # Pokaż lokalizacje
        $_.Value | ForEach-Object {
            $dir = Split-Path $_.Path -Parent
            Write-ColorText "  📁 $dir" "Gray"
        }
        Write-Host ""
    }
    
    if (-not $DryRun) {
        Write-ColorText "❓ Czy usunąć duplikaty? (zachowa najnowsze wersje)" "Yellow"
        $confirm = Read-Host "Wpisz 'TAK' aby kontynuować"
        
        if ($confirm -eq "TAK") {
            $removedSize = 0
            $removedCount = 0
            
            foreach ($group in $realDuplicates) {
                $files = $group.Value | Sort-Object LastWrite -Descending
                # Zachowaj najnowszy, usuń resztę
                for ($i = 1; $i -lt $files.Count; $i++) {
                    try {
                        Remove-Item $files[$i].Path -Force
                        $removedSize += $files[$i].Size
                        $removedCount++
                        Write-ColorText "🗑️ Usunięto: $(Split-Path $files[$i].Path -Leaf)" "Gray"
                    } catch {
                        Write-ColorText "❌ Błąd usuwania: $($files[$i].Path)" "Red"
                    }
                }
            }
            
            Write-ColorText "`n✅ POLOWANIE ZAKOŃCZONE!" "Green"
            Write-ColorText "Usunięto: $removedCount plików" "White"
            Write-ColorText "Odzyskano: $(Get-FriendlySize $removedSize)" "Green"
        }
    }
}

# ===============================================
# GŁÓWNA FUNKCJA
# ===============================================

function Start-AllInOneCleanup {
    $startTime = Get-Date
    Write-ColorText "🚀 ROZPOCZYNANIE CZYSZCZENIA..." "Cyan"
    Write-ColorText "Czas rozpoczęcia: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))" "White"
    Write-ColorText "Tryb: $Mode $(if($DryRun){'(PODGLĄD)'})" "Yellow"
    Write-Host ""
    
    # Sprawdź dostępne miejsce przed
    $beforeSpace = (Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace
    Write-ColorText "💾 Wolne miejsce przed: $(Get-FriendlySize $beforeSpace)" "White"
    
    # Wykonaj czyszczenie według trybu
    switch ($Mode) {
        "Quick" {
            Write-ColorText "⚡ TRYB SZYBKI - OneDrive + InfiniCoreCipher" "Green"
            if (-not $OneDrivePath) { $OneDrivePath = Get-OneDrivePath }
            if ($OneDrivePath) { Start-OneDriveCleanup -OneDrivePath $OneDrivePath -DryRun $DryRun }
            Start-ProjectCleanup -ProjectPath $ProjectPath -DryRun $DryRun
        }
        
        "Full" {
            Write-ColorText "🔥 TRYB PEŁNY - Wszystko!" "Red"
            if (-not $OneDrivePath) { $OneDrivePath = Get-OneDrivePath }
            if ($OneDrivePath) { Start-OneDriveCleanup -OneDrivePath $OneDrivePath -DryRun $DryRun }
            Start-ProjectCleanup -ProjectPath $ProjectPath -DryRun $DryRun
            Start-SystemCleanup -DryRun $DryRun
            Start-DuplicateHunt -DryRun $DryRun -MinSize $MinFileSize -MaxSize $MaxFileSize
        }
        
        "OneDriveOnly" {
            Write-ColorText "☁️ TRYB ONEDRIVE" "Blue"
            if (-not $OneDrivePath) { $OneDrivePath = Get-OneDrivePath }
            if ($OneDrivePath) { Start-OneDriveCleanup -OneDrivePath $OneDrivePath -DryRun $DryRun }
        }
        
        "SystemOnly" {
            Write-ColorText "🖥️ TRYB SYSTEMOWY" "Magenta"
            Start-SystemCleanup -DryRun $DryRun
        }
        
        "DuplicatesOnly" {
            Write-ColorText "🎯 TRYB DUPLIKATÓW" "Yellow"
            Start-DuplicateHunt -DryRun $DryRun -MinSize $MinFileSize -MaxSize $MaxFileSize
        }
    }
    
    # Sprawdź dostępne miejsce po
    $afterSpace = (Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace
    $recoveredSpace = $afterSpace - $beforeSpace
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-ColorText "`n🎉 CZYSZCZENIE ZAKOŃCZONE!" "Green"
    Write-ColorText "=================================" "Green"
    Write-ColorText "💾 Wolne miejsce przed: $(Get-FriendlySize $beforeSpace)" "White"
    Write-ColorText "💾 Wolne miejsce po: $(Get-FriendlySize $afterSpace)" "White"
    Write-ColorText "✨ Odzyskano: $(Get-FriendlySize $recoveredSpace)" "Green"
    Write-ColorText "⏱️ Czas wykonania: $($duration.ToString('mm\:ss'))" "White"
    Write-ColorText "🎯 Tryb: $Mode $(if($DryRun){'(PODGLĄD)'})" "Yellow"
}

# ===============================================
# URUCHOMIENIE SKRYPTU
# ===============================================

Clear-Host
Write-ColorText @"
╔══════════════════════════════════════════════════════════════╗
║                    🧹 ALL-IN-ONE CLEANUP 🧹                  ║
║              Kompletne czyszczenie OneDrive i systemu        ║
║                     Wersja: 1.0 (2024)                      ║
╚══════════════════════════════════════════════════════════════╝
"@ "Cyan"

Write-Host ""

# Sprawdź uprawnienia administratora
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-ColorText "⚠️ UWAGA: Skrypt nie jest uruchomiony jako Administrator!" "Yellow"
    Write-ColorText "Niektóre funkcje mogą nie działać poprawnie." "Yellow"
    Write-Host ""
}

# Jeśli nie podano trybu, pokaż menu
if ($Mode -eq "Menu") {
    $Mode = Show-Menu
}

# Uruchom czyszczenie
Start-AllInOneCleanup

Write-ColorText "`n✨ Dziękujemy za użycie All-In-One Cleanup! ✨" "Green"
Write-ColorText "Naciśnij Enter aby zakończyć..." "Gray"
Read-Host