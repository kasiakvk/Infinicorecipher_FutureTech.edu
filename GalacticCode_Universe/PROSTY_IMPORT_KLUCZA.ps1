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
