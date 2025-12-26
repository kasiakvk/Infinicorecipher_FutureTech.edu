# Naprawa Skryptu PowerShell - Problem z Kolorami
# Poprawia błędy z ForegroundColor w skryptach

Write-Host "=== NAPRAWA SKRYPTOW POWERSHELL ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Problem:" -ForegroundColor Yellow
Write-Host "Skrypty PowerShell mają błędy z parametrem ForegroundColor" -ForegroundColor White
Write-Host "Błąd: Cannot convert value '*60' to type 'System.ConsoleColor'" -ForegroundColor Red
Write-Host ""

Write-Host "PRZYCZYNA:" -ForegroundColor Yellow
Write-Host "Skrypt próbuje użyć kodów ANSI zamiast nazw kolorów PowerShell" -ForegroundColor White
Write-Host ""

# Funkcja do naprawy pliku
function Fix-PowerShellScript {
    param($FilePath)
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "Plik nie istnieje: $FilePath" -ForegroundColor Red
        return
    }
    
    Write-Host "Naprawiam: $FilePath" -ForegroundColor Gray
    
    try {
        $content = Get-Content $FilePath -Raw
        $originalContent = $content
        
        # Zamień problematyczne kody kolorów
        $colorMappings = @{
            '"\*60"' = '"Yellow"'
            '"+"' = '"Green"'
            '""' = '"White"'
            '\$Color\s*=\s*"\*60"' = '$Color = "Yellow"'
            '\$Color\s*=\s*"\+"' = '$Color = "Green"'
            '\$Color\s*=\s*""' = '$Color = "White"'
        }
        
        foreach ($pattern in $colorMappings.Keys) {
            $replacement = $colorMappings[$pattern]
            $content = $content -replace $pattern, $replacement
        }
        
        # Sprawdź czy były zmiany
        if ($content -ne $originalContent) {
            # Utwórz backup
            $backupPath = $FilePath + ".backup"
            Copy-Item $FilePath $backupPath -Force
            
            # Zapisz naprawiony plik
            $content | Out-File -FilePath $FilePath -Encoding UTF8
            
            Write-Host "  ✓ Naprawiono i utworzono backup: $backupPath" -ForegroundColor Green
        } else {
            Write-Host "  - Brak zmian potrzebnych" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "  ✗ Błąd: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Lista skryptów do naprawy
$scriptsToFix = @(
    "FIND_PRIVATE_KEY.ps1",
    "MANAGE_MULTIPLE_KEYS.ps1",
    "FIX_GPG_PROBLEM.ps1",
    "IMPORT_GPG_KEY.ps1"
)

Write-Host "NAPRAWIANIE SKRYPTÓW:" -ForegroundColor Yellow
Write-Host ""

foreach ($script in $scriptsToFix) {
    Fix-PowerShellScript -FilePath $script
}

Write-Host ""
Write-Host "=== ALTERNATYWNE ROZWIĄZANIE ===" -ForegroundColor Cyan
Write-Host ""

# Utwórz uproszczony skrypt bez kolorów
$simpleScript = @'
# Prosty Skrypt Importu Klucza GPG (bez kolorów)
# Importuje znaleziony klucz prywatny

param(
    [string]$KeyPath = ""
)

Write-Host "=== IMPORT KLUCZA GPG ==="
Write-Host ""

# Jeśli nie podano ścieżki, sprawdź standardowe lokalizacje
if (-not $KeyPath) {
    $possiblePaths = @(
        "C:\Users\kasia\Desktop\infinicorecipher-private.key",
        "C:\Users\kasia\Downloads\infinicorecipher-private.key"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path $path) {
            $KeyPath = $path
            Write-Host "Znaleziono klucz: $KeyPath"
            break
        }
    }
}

if (-not $KeyPath -or -not (Test-Path $KeyPath)) {
    Write-Host "BLAD: Nie znaleziono pliku klucza!"
    Write-Host "Uzycie: .\PROSTY_IMPORT_KLUCZA.ps1 -KeyPath 'sciezka\do\klucza.key'"
    exit 1
}

Write-Host "Importuje klucz z: $KeyPath"
Write-Host ""

# Import klucza
try {
    $importResult = gpg --import $KeyPath 2>&1
    Write-Host "Wynik importu:"
    Write-Host $importResult
    
    # Sprawdź zaimportowane klucze
    Write-Host ""
    Write-Host "Dostepne klucze prywatne:"
    gpg --list-secret-keys --keyid-format LONG
    
    # Sprawdź czy to szukany klucz
    $targetKeyId = "1023184AA0F0214C"
    $secretKeys = gpg --list-secret-keys --keyid-format LONG 2>$null
    
    if ($secretKeys -match $targetKeyId) {
        Write-Host ""
        Write-Host "SUKCES! Znaleziono szukany klucz: $targetKeyId"
        
        # Konfiguruj Git
        Write-Host "Konfiguruje Git..."
        git config --global user.signingkey $targetKeyId
        git config --global commit.gpgsign true
        
        # Eksportuj klucz publiczny
        Write-Host "Eksportuje klucz publiczny..."
        gpg --armor --export $targetKeyId > "klucz_publiczny_github.txt"
        
        Write-Host ""
        Write-Host "=== NASTEPNE KROKI ==="
        Write-Host "1. Otwórz: klucz_publiczny_github.txt"
        Write-Host "2. Skopiuj zawartosc"
        Write-Host "3. Idz na: https://github.com/settings/keys"
        Write-Host "4. Dodaj nowy GPG key"
        Write-Host "5. Przetestuj commit"
        
    } else {
        Write-Host ""
        Write-Host "Klucz zaimportowany, ale to nie jest szukany klucz $targetKeyId"
        Write-Host "Mozesz uzyc dostepnego klucza lub wygenerowac nowy"
    }
    
} catch {
    Write-Host "BLAD podczas importu: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "Nacisnij Enter aby zakonczyc..."
Read-Host
'@

# Zapisz prosty skrypt
$simpleScript | Out-File -FilePath "PROSTY_IMPORT_KLUCZA.ps1" -Encoding UTF8

Write-Host "✓ Utworzono prosty skrypt: PROSTY_IMPORT_KLUCZA.ps1" -ForegroundColor Green
Write-Host ""

Write-Host "REKOMENDACJA:" -ForegroundColor Yellow
Write-Host "Użyj prostego skryptu bez kolorów:" -ForegroundColor White
Write-Host "  .\PROSTY_IMPORT_KLUCZA.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Lub zaimportuj ręcznie:" -ForegroundColor White
Write-Host "  gpg --import 'C:\Users\kasia\Desktop\infinicorecipher-private.key'" -ForegroundColor Gray

Write-Host ""
Write-Host "Naciśnij Enter aby zakończyć..."
Read-Host