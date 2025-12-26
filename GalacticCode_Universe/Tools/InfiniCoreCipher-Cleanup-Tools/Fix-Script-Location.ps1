# Fix-Script-Location.ps1
# Szybkie rozwiązanie problemu z lokalizacją skryptów

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

Write-Host "🔧 NAPRAWIANIE PROBLEMU Z LOKALIZACJĄ SKRYPTÓW" -ForegroundColor $Cyan
Write-Host ""

# Sprawdź gdzie jesteś
$CurrentLocation = Get-Location
Write-Host "📍 Bieżąca lokalizacja: $CurrentLocation" -ForegroundColor $Yellow

# Sprawdź czy skrypty są w bieżącym folderze
$ScriptsHere = Get-ChildItem "*.ps1" | Where-Object { $_.Name -like "*Infinicorecipher*" }

if ($ScriptsHere.Count -gt 0) {
    Write-Host "✅ Znaleziono skrypty w bieżącym folderze:" -ForegroundColor $Green
    foreach ($Script in $ScriptsHere) {
        Write-Host "  - $($Script.Name)" -ForegroundColor $Green
    }
    
    Write-Host ""
    Write-Host "🎯 ROZWIĄZANIE: Uruchom stąd główny skrypt:" -ForegroundColor $Cyan
    Write-Host ".\Setup-InfinicocipherProject.ps1 -AutoStart" -ForegroundColor $Yellow
    
} else {
    Write-Host "❌ Brak skryptów w bieżącym folderze" -ForegroundColor $Red
    Write-Host ""
    Write-Host "🔍 Szukanie skryptów..." -ForegroundColor $Yellow
    
    # Sprawdź typowe lokalizacje
    $SearchPaths = @(
        "C:\workspace",
        "$env:USERPROFILE\workspace", 
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\Downloads",
        "C:\Users\$env:USERNAME\workspace"
    )
    
    $Found = $false
    
    foreach ($Path in $SearchPaths) {
        if (Test-Path $Path) {
            $FoundScripts = Get-ChildItem "$Path\*InfinicocipherProject*.ps1" -ErrorAction SilentlyContinue
            
            if ($FoundScripts) {
                Write-Host "✅ Znaleziono skrypty w: $Path" -ForegroundColor $Green
                foreach ($Script in $FoundScripts) {
                    Write-Host "  - $($Script.Name)" -ForegroundColor $Green
                }
                
                Write-Host ""
                Write-Host "🎯 ROZWIĄZANIE:" -ForegroundColor $Cyan
                Write-Host "cd `"$Path`"" -ForegroundColor $Yellow
                Write-Host ".\Setup-InfinicocipherProject.ps1 -AutoStart" -ForegroundColor $Yellow
                
                $Found = $true
                break
            }
        }
    }
    
    if (-not $Found) {
        Write-Host "❌ Nie znaleziono skryptów w typowych lokalizacjach" -ForegroundColor $Red
        Write-Host ""
        Write-Host "🔍 Wyszukiwanie na całym dysku C:..." -ForegroundColor $Yellow
        
        try {
            $GlobalSearch = Get-ChildItem -Path "C:\" -Name "Setup-InfinicocipherProject.ps1" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            
            if ($GlobalSearch) {
                $ScriptPath = Split-Path "C:\$GlobalSearch" -Parent
                Write-Host "✅ Znaleziono skrypty w: $ScriptPath" -ForegroundColor $Green
                Write-Host ""
                Write-Host "🎯 ROZWIĄZANIE:" -ForegroundColor $Cyan
                Write-Host "cd `"$ScriptPath`"" -ForegroundColor $Yellow
                Write-Host ".\Setup-InfinicocipherProject.ps1 -AutoStart" -ForegroundColor $Yellow
            } else {
                Write-Host "❌ Skrypty nie zostały znalezione na dysku" -ForegroundColor $Red
                Write-Host ""
                Write-Host "💡 MOŻLIWE PRZYCZYNY:" -ForegroundColor $Yellow
                Write-Host "1. Skrypty nie zostały jeszcze pobrane/utworzone" -ForegroundColor $Yellow
                Write-Host "2. Skrypty są w innej lokalizacji" -ForegroundColor $Yellow
                Write-Host "3. Brak uprawnień do przeszukiwania" -ForegroundColor $Yellow
            }
        } catch {
            Write-Host "❌ Błąd podczas wyszukiwania: $($_.Exception.Message)" -ForegroundColor $Red
        }
    }
}

Write-Host ""
Write-Host "📋 ALTERNATYWNE ROZWIĄZANIA:" -ForegroundColor $Cyan
Write-Host "1. Sprawdź folder Downloads - może skrypty są tam" -ForegroundColor $Yellow
Write-Host "2. Sprawdź pulpit" -ForegroundColor $Yellow
Write-Host "3. Poproś o ponowne utworzenie skryptów" -ForegroundColor $Yellow

Write-Host ""
Write-Host "🆘 JEŚLI NADAL PROBLEM:" -ForegroundColor $Cyan
Write-Host "Uruchom PowerShell jako Administrator i spróbuj ponownie" -ForegroundColor $Yellow

Write-Host ""
Write-Host "=== KONIEC DIAGNOZY ===" -ForegroundColor $Cyan