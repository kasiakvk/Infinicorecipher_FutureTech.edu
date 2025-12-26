<#
.SYNOPSIS
    Główny skrypt uruchamiający czyszczenie OneDrive

.DESCRIPTION
    Automatycznie uruchamia sekwencję skryptów do czyszczenia i organizacji OneDrive
#>

# Kolory
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Blue = "Blue"

function Write-CleanupLog {
    param(
        [string]$Message,
        [string]$Status = "INFO",
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Status] $Message" -ForegroundColor $Color
}

Write-Host "=== URUCHAMIANIE SKRYPTÓW ONEDRIVE ===" -ForegroundColor $Cyan
Write-Host ""

# Sprawdź dostępne skrypty
$scripts = @(
    @{ Name = "OneDrive-Check-Script.ps1"; Desc = "Główny skrypt skanowania i wykrywania duplikatów" },
    @{ Name = "OneDrive-Quick-Check.ps1"; Desc = "Szybka diagnostyka OneDrive" },
    @{ Name = "OneDrive-Safe-Cleanup.ps1"; Desc = "Bezpieczne usuwanie duplikatów" }
)

Write-CleanupLog "🔍 Sprawdzanie dostępnych skryptów..." "INFO" $Yellow

$availableScripts = @()
foreach ($script in $scripts) {
    if (Test-Path $script.Name) {
        Write-CleanupLog "✅ $($script.Name) - dostępny" "OK" $Green
        $availableScripts += $script
    } else {
        Write-CleanupLog "❌ $($script.Name) - brak" "ERROR" $Red
    }
}

if ($availableScripts.Count -eq 0) {
    Write-CleanupLog "❌ Brak dostępnych skryptów OneDrive!" "ERROR" $Red
    Write-CleanupLog "Upewnij się, że jesteś w odpowiednim katalogu" "INFO" $Yellow
    exit 1
}

Write-Host ""
Write-CleanupLog "📋 DOSTĘPNE OPCJE:" "INFO" $Cyan

# Menu wyboru
Write-Host "1. 🔍 Szybka diagnostyka OneDrive (OneDrive-Quick-Check.ps1)" -ForegroundColor $Blue
Write-Host "2. 📊 Pełne skanowanie i wykrywanie duplikatów (OneDrive-Check-Script.ps1)" -ForegroundColor $Blue
Write-Host "3. 🧹 Bezpieczne czyszczenie duplikatów (OneDrive-Safe-Cleanup.ps1)" -ForegroundColor $Blue
Write-Host "4. 🚀 Automatyczna sekwencja (wszystkie skrypty po kolei)" -ForegroundColor $Green
Write-Host "5. ❌ Anuluj" -ForegroundColor $Red

Write-Host ""
$choice = Read-Host "Wybierz opcję (1-5)"

switch ($choice) {
    "1" {
        Write-CleanupLog "🔍 Uruchamianie szybkiej diagnostyki..." "INFO" $Yellow
        if (Test-Path "OneDrive-Quick-Check.ps1") {
            & ".\OneDrive-Quick-Check.ps1"
        } else {
            Write-CleanupLog "❌ Skrypt OneDrive-Quick-Check.ps1 nie istnieje" "ERROR" $Red
        }
    }
    
    "2" {
        Write-CleanupLog "📊 Uruchamianie pełnego skanowania..." "INFO" $Yellow
        if (Test-Path "OneDrive-Check-Script.ps1") {
            & ".\OneDrive-Check-Script.ps1"
        } else {
            Write-CleanupLog "❌ Skrypt OneDrive-Check-Script.ps1 nie istnieje" "ERROR" $Red
        }
    }
    
    "3" {
        Write-CleanupLog "🧹 Uruchamianie bezpiecznego czyszczenia..." "INFO" $Yellow
        if (Test-Path "OneDrive-Safe-Cleanup.ps1") {
            & ".\OneDrive-Safe-Cleanup.ps1"
        } else {
            Write-CleanupLog "❌ Skrypt OneDrive-Safe-Cleanup.ps1 nie istnieje" "ERROR" $Red
        }
    }
    
    "4" {
        Write-CleanupLog "🚀 Uruchamianie automatycznej sekwencji..." "INFO" $Green
        Write-Host ""
        
        # Krok 1: Szybka diagnostyka
        Write-CleanupLog "KROK 1/3: Szybka diagnostyka" "INFO" $Cyan
        if (Test-Path "OneDrive-Quick-Check.ps1") {
            & ".\OneDrive-Quick-Check.ps1"
        }
        
        Write-Host ""
        Read-Host "Naciśnij Enter aby kontynuować do pełnego skanowania..."
        
        # Krok 2: Pełne skanowanie
        Write-CleanupLog "KROK 2/3: Pełne skanowanie duplikatów" "INFO" $Cyan
        if (Test-Path "OneDrive-Check-Script.ps1") {
            & ".\OneDrive-Check-Script.ps1"
        }
        
        Write-Host ""
        $continueCleanup = Read-Host "Czy chcesz przejść do czyszczenia duplikatów? (t/n)"
        
        if ($continueCleanup.ToLower() -eq 't' -or $continueCleanup.ToLower() -eq 'tak') {
            # Krok 3: Czyszczenie
            Write-CleanupLog "KROK 3/3: Bezpieczne czyszczenie" "INFO" $Cyan
            if (Test-Path "OneDrive-Safe-Cleanup.ps1") {
                & ".\OneDrive-Safe-Cleanup.ps1"
            }
        } else {
            Write-CleanupLog "⏭️ Pominięto czyszczenie na żądanie użytkownika" "INFO" $Yellow
        }
    }
    
    "5" {
        Write-CleanupLog "❌ Anulowano przez użytkownika" "INFO" $Yellow
        exit 0
    }
    
    default {
        Write-CleanupLog "❌ Nieprawidłowy wybór: $choice" "ERROR" $Red
        exit 1
    }
}

Write-Host ""
Write-CleanupLog "🎉 Operacja zakończona!" "OK" $Green

# Pokaż następne kroki
Write-Host ""
Write-CleanupLog "📋 NASTĘPNE KROKI:" "INFO" $Cyan
Write-CleanupLog "1. Sprawdź wygenerowane raporty (OneDrive-Report-*.csv)" "INFO" $Blue
Write-CleanupLog "2. Przejrzyj raport duplikatów (OneDrive-Duplicates-*.csv)" "INFO" $Blue
Write-CleanupLog "3. Uruchom GitHub setup: .\GitHub-Auto-Setup.ps1" "INFO" $Blue
Write-CleanupLog "4. Skonfiguruj synchronizację: .\OneDrive-GitHub-Sync.ps1" "INFO" $Blue

Write-Host ""
Write-CleanupLog "=== KONIEC ===" "INFO" $Cyan