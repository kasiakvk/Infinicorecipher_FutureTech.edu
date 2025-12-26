<#
.SYNOPSIS
    Szybki skrypt do sprawdzania podstawowych informacji o OneDrive

.DESCRIPTION
    Uproszczona wersja skryptu do szybkiego sprawdzenia lokalizacji OneDrive
    i podstawowych statystyk bez głębokiej analizy duplikatów.
#>

# Funkcja do formatowania rozmiaru
function Format-Size {
    param([long]$Size)
    if ($Size -gt 1GB) { return "{0:N2} GB" -f ($Size / 1GB) }
    elseif ($Size -gt 1MB) { return "{0:N2} MB" -f ($Size / 1MB) }
    elseif ($Size -gt 1KB) { return "{0:N2} KB" -f ($Size / 1KB) }
    else { return "$Size B" }
}

Write-Host "=== SZYBKIE SPRAWDZENIE ONEDRIVE ===" -ForegroundColor Cyan
Write-Host ""

# Sprawdzenie procesów OneDrive
$oneDriveProcesses = Get-Process -Name "*OneDrive*" -ErrorAction SilentlyContinue
if ($oneDriveProcesses) {
    Write-Host "✓ OneDrive jest uruchomiony:" -ForegroundColor Green
    foreach ($process in $oneDriveProcesses) {
        Write-Host "  - $($process.ProcessName) (PID: $($process.Id))" -ForegroundColor Gray
    }
} else {
    Write-Host "✗ OneDrive nie jest uruchomiony" -ForegroundColor Red
}

Write-Host ""

# Sprawdzenie ścieżek OneDrive w rejestrze
Write-Host "Sprawdzanie konfiguracji OneDrive..." -ForegroundColor Yellow

try {
    $regPaths = Get-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive\Accounts\*" -ErrorAction SilentlyContinue
    if ($regPaths) {
        Write-Host "✓ Znalezione konta OneDrive:" -ForegroundColor Green
        foreach ($account in $regPaths) {
            if ($account.UserFolder) {
                Write-Host "  - Folder: $($account.UserFolder)" -ForegroundColor Gray
                if ($account.UserEmail) {
                    Write-Host "    Email: $($account.UserEmail)" -ForegroundColor Gray
                }
                
                # Sprawdzenie czy folder istnieje i podstawowe statystyki
                if (Test-Path $account.UserFolder) {
                    try {
                        $files = Get-ChildItem -Path $account.UserFolder -File -Recurse -ErrorAction SilentlyContinue
                        $totalSize = ($files | Measure-Object Length -Sum).Sum
                        Write-Host "    Pliki: $($files.Count), Rozmiar: $(Format-Size $totalSize)" -ForegroundColor Gray
                    } catch {
                        Write-Host "    Błąd dostępu do folderu" -ForegroundColor Red
                    }
                } else {
                    Write-Host "    ⚠ Folder nie istnieje!" -ForegroundColor Yellow
                }
            }
        }
    } else {
        Write-Host "✗ Nie znaleziono konfiguracji OneDrive w rejestrze" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Błąd odczytu rejestru: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Sprawdzenie standardowych lokalizacji
$standardPaths = @(
    "$env:USERPROFILE\OneDrive",
    "$env:USERPROFILE\OneDrive - Personal",
    "$env:USERPROFILE\OneDrive for Business"
)

Write-Host "Sprawdzanie standardowych lokalizacji..." -ForegroundColor Yellow
foreach ($path in $standardPaths) {
    if (Test-Path $path) {
        Write-Host "✓ Znaleziono: $path" -ForegroundColor Green
        try {
            $items = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
            Write-Host "  Elementów: $($items.Count)" -ForegroundColor Gray
        } catch {
            Write-Host "  Błąd dostępu" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "Sprawdzenie zakończone." -ForegroundColor Cyan