# Fix-JSON-Files.ps1
# Naprawa błędów JSON (BOM encoding) w plikach package.json

param(
    [string]$ProjectPath = "C:\InfiniCoreCipher-Startup"
)

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

Write-Host "🔧 NAPRAWA PLIKÓW JSON" -ForegroundColor $Cyan
Write-Host "======================" -ForegroundColor $Cyan
Write-Host "Projekt: $ProjectPath" -ForegroundColor $Yellow
Write-Host ""

if (-not (Test-Path $ProjectPath)) {
    Write-Host "❌ Folder projektu nie istnieje: $ProjectPath" -ForegroundColor $Red
    exit 1
}

Push-Location $ProjectPath

try {
    # Lista plików JSON do sprawdzenia
    $JsonFiles = @(
        "package.json",
        "frontend/package.json", 
        "backend/package.json",
        "frontend/tsconfig.json",
        "backend/tsconfig.json"
    )
    
    Write-Host "🔍 SPRAWDZANIE PLIKÓW JSON" -ForegroundColor $Cyan
    Write-Host ""
    
    $FixedFiles = 0
    $ErrorFiles = 0
    
    foreach ($JsonFile in $JsonFiles) {
        Write-Host "📄 Sprawdzanie: $JsonFile" -ForegroundColor $Yellow
        
        if (-not (Test-Path $JsonFile)) {
            Write-Host "   ⚠️  Plik nie istnieje" -ForegroundColor $Yellow
            continue
        }
        
        try {
            # Sprawdź czy plik ma BOM
            $bytes = [System.IO.File]::ReadAllBytes($JsonFile)
            $hasBOM = $false
            
            if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
                $hasBOM = $true
                Write-Host "   ❌ Wykryto BOM (Byte Order Mark)" -ForegroundColor $Red
            }
            
            # Odczytaj zawartość
            $content = Get-Content $JsonFile -Raw -Encoding UTF8
            
            # Sprawdź czy to poprawny JSON
            try {
                $jsonObject = $content | ConvertFrom-Json
                if (-not $hasBOM) {
                    Write-Host "   ✅ Plik JSON jest poprawny" -ForegroundColor $Green
                    continue
                }
            } catch {
                Write-Host "   ❌ Błąd parsowania JSON: $($_.Exception.Message)" -ForegroundColor $Red
                $ErrorFiles++
            }
            
            # Napraw plik
            Write-Host "   🔧 Naprawianie pliku..." -ForegroundColor $Yellow
            
            # Usuń BOM i zapisz ponownie
            $cleanContent = $content.TrimStart([char]0xFEFF)
            
            # Sprawdź czy naprawiona zawartość jest poprawnym JSON
            try {
                $testJson = $cleanContent | ConvertFrom-Json
                
                # Zapisz bez BOM
                [System.IO.File]::WriteAllText($JsonFile, $cleanContent, [System.Text.UTF8Encoding]::new($false))
                
                Write-Host "   ✅ Plik naprawiony pomyślnie" -ForegroundColor $Green
                $FixedFiles++
                
            } catch {
                Write-Host "   ❌ Nie można naprawić pliku: $($_.Exception.Message)" -ForegroundColor $Red
                $ErrorFiles++
            }
            
        } catch {
            Write-Host "   ❌ Błąd przetwarzania pliku: $($_.Exception.Message)" -ForegroundColor $Red
            $ErrorFiles++
        }
        
        Write-Host ""
    }
    
    # Podsumowanie
    Write-Host "📊 PODSUMOWANIE NAPRAWY:" -ForegroundColor $Cyan
    Write-Host "   ✅ Naprawione pliki: $FixedFiles" -ForegroundColor $Green
    Write-Host "   ❌ Pliki z błędami: $ErrorFiles" -ForegroundColor $(if($ErrorFiles -eq 0){$Green}else{$Red})
    
    if ($FixedFiles -gt 0) {
        Write-Host ""
        Write-Host "🎉 PLIKI JSON NAPRAWIONE!" -ForegroundColor $Green
        Write-Host ""
        Write-Host "💡 NASTĘPNE KROKI:" -ForegroundColor $Cyan
        Write-Host "1. Spróbuj uruchomić projekt ponownie:" -ForegroundColor $Yellow
        Write-Host "   npm run dev" -ForegroundColor $Green
        Write-Host ""
        Write-Host "2. Jeśli nadal są problemy, sprawdź logi:" -ForegroundColor $Yellow
        Write-Host "   npm run dev:backend" -ForegroundColor $Green
        Write-Host "   npm run dev:frontend" -ForegroundColor $Green
    }
    
    if ($ErrorFiles -gt 0) {
        Write-Host ""
        Write-Host "⚠️  NIEKTÓRE PLIKI WYMAGAJĄ RĘCZNEJ NAPRAWY" -ForegroundColor $Yellow
        Write-Host "Sprawdź pliki z błędami i popraw je ręcznie." -ForegroundColor $Yellow
    }
    
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "=== KONIEC NAPRAWY JSON ===" -ForegroundColor $Cyan