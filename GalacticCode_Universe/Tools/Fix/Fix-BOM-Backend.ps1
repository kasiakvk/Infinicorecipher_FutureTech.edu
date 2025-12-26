# Fix-BOM-Backend.ps1
# Naprawa konkretnego problemu BOM w backend/package.json

param(
    [string]$ProjectPath = "C:\InfiniCoreCipher-Startup"
)

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

Write-Host "🔧 NAPRAWA BOM W BACKEND/PACKAGE.JSON" -ForegroundColor $Cyan
Write-Host "====================================" -ForegroundColor $Cyan
Write-Host "Projekt: $ProjectPath" -ForegroundColor $Yellow
Write-Host ""

if (-not (Test-Path $ProjectPath)) {
    Write-Host "❌ Folder projektu nie istnieje: $ProjectPath" -ForegroundColor $Red
    exit 1
}

Push-Location $ProjectPath

try {
    $BackendPackageJson = "backend/package.json"
    
    Write-Host "🔍 Sprawdzanie pliku: $BackendPackageJson" -ForegroundColor $Yellow
    
    if (-not (Test-Path $BackendPackageJson)) {
        Write-Host "❌ Plik nie istnieje: $BackendPackageJson" -ForegroundColor $Red
        exit 1
    }
    
    # Sprawdź rozmiar pliku
    $FileInfo = Get-Item $BackendPackageJson
    Write-Host "📊 Rozmiar pliku: $($FileInfo.Length) bajtów" -ForegroundColor $Yellow
    
    # Odczytaj pierwsze bajty
    $bytes = [System.IO.File]::ReadAllBytes($BackendPackageJson)
    Write-Host "📊 Pierwsze 10 bajtów: $($bytes[0..9] -join ', ')" -ForegroundColor $Yellow
    
    # Sprawdź BOM
    $hasBOM = $false
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $hasBOM = $true
        Write-Host "❌ WYKRYTO BOM (Byte Order Mark): EF BB BF" -ForegroundColor $Red
    } else {
        Write-Host "ℹ️  Brak BOM w pliku" -ForegroundColor $Yellow
    }
    
    # Odczytaj zawartość jako tekst
    Write-Host ""
    Write-Host "📄 Odczytywanie zawartości..." -ForegroundColor $Yellow
    
    try {
        $content = Get-Content $BackendPackageJson -Raw -Encoding UTF8
        Write-Host "📊 Długość zawartości: $($content.Length) znaków" -ForegroundColor $Yellow
        
        # Sprawdź pierwszy znak
        if ($content.Length -gt 0) {
            $firstChar = $content[0]
            $firstCharCode = [int][char]$firstChar
            Write-Host "📊 Pierwszy znak: '$firstChar' (kod: $firstCharCode)" -ForegroundColor $Yellow
            
            if ($firstCharCode -eq 65279) {
                Write-Host "❌ WYKRYTO BOM JAKO PIERWSZY ZNAK (U+FEFF)" -ForegroundColor $Red
                $hasBOM = $true
            }
        }
        
        # Spróbuj sparsować JSON
        Write-Host ""
        Write-Host "🧪 Test parsowania JSON..." -ForegroundColor $Yellow
        
        try {
            $jsonObject = $content | ConvertFrom-Json
            Write-Host "✅ JSON jest poprawny po odczytaniu" -ForegroundColor $Green
            
            if (-not $hasBOM) {
                Write-Host "✅ Plik nie wymaga naprawy" -ForegroundColor $Green
                exit 0
            }
        } catch {
            Write-Host "❌ Błąd parsowania JSON: $($_.Exception.Message)" -ForegroundColor $Red
            $hasBOM = $true
        }
        
        if ($hasBOM) {
            Write-Host ""
            Write-Host "🔧 NAPRAWIANIE PLIKU..." -ForegroundColor $Cyan
            
            # Utwórz kopię zapasową
            $backupFile = "$BackendPackageJson.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Write-Host "📦 Tworzenie kopii zapasowej: $backupFile" -ForegroundColor $Yellow
            Copy-Item $BackendPackageJson $backupFile
            
            # Usuń BOM
            $cleanContent = $content.TrimStart([char]0xFEFF)
            Write-Host "🧹 Usunięto BOM z zawartości" -ForegroundColor $Yellow
            
            # Test naprawionej zawartości
            try {
                $testJson = $cleanContent | ConvertFrom-Json
                Write-Host "✅ Naprawiona zawartość jest poprawnym JSON" -ForegroundColor $Green
                
                # Zapisz bez BOM
                Write-Host "💾 Zapisywanie naprawionego pliku..." -ForegroundColor $Yellow
                [System.IO.File]::WriteAllText($BackendPackageJson, $cleanContent, [System.Text.UTF8Encoding]::new($false))
                
                # Weryfikacja
                Write-Host ""
                Write-Host "🔍 WERYFIKACJA NAPRAWY..." -ForegroundColor $Cyan
                
                $newBytes = [System.IO.File]::ReadAllBytes($BackendPackageJson)
                Write-Host "📊 Nowe pierwsze 10 bajtów: $($newBytes[0..9] -join ', ')" -ForegroundColor $Yellow
                
                $newContent = Get-Content $BackendPackageJson -Raw -Encoding UTF8
                $newFirstCharCode = if ($newContent.Length -gt 0) { [int][char]$newContent[0] } else { 0 }
                Write-Host "📊 Nowy pierwszy znak (kod): $newFirstCharCode" -ForegroundColor $Yellow
                
                # Test końcowy
                try {
                    $finalTest = $newContent | ConvertFrom-Json
                    Write-Host "✅ NAPRAWA ZAKOŃCZONA SUKCESEM!" -ForegroundColor $Green
                    Write-Host ""
                    Write-Host "🎉 PLIK NAPRAWIONY:" -ForegroundColor $Green
                    Write-Host "   📄 Plik: $BackendPackageJson" -ForegroundColor $Yellow
                    Write-Host "   📦 Kopia zapasowa: $backupFile" -ForegroundColor $Yellow
                    Write-Host "   🧹 BOM usunięty" -ForegroundColor $Yellow
                    Write-Host "   ✅ JSON poprawny" -ForegroundColor $Yellow
                    
                } catch {
                    Write-Host "❌ BŁĄD: Naprawiony plik nadal ma problemy: $($_.Exception.Message)" -ForegroundColor $Red
                    
                    # Przywróć kopię zapasową
                    Write-Host "🔄 Przywracanie kopii zapasowej..." -ForegroundColor $Yellow
                    Copy-Item $backupFile $BackendPackageJson -Force
                    exit 1
                }
                
            } catch {
                Write-Host "❌ Nie można naprawić pliku: $($_.Exception.Message)" -ForegroundColor $Red
                exit 1
            }
        }
        
    } catch {
        Write-Host "❌ Błąd odczytu pliku: $($_.Exception.Message)" -ForegroundColor $Red
        exit 1
    }
    
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "🚀 NASTĘPNE KROKI:" -ForegroundColor $Cyan
Write-Host "1. Spróbuj uruchomić backend:" -ForegroundColor $Yellow
Write-Host "   cd `"$ProjectPath`"" -ForegroundColor $Green
Write-Host "   npm run dev:backend" -ForegroundColor $Green
Write-Host ""
Write-Host "2. Lub uruchom cały projekt:" -ForegroundColor $Yellow
Write-Host "   npm run dev" -ForegroundColor $Green

Write-Host ""
Write-Host "=== KONIEC NAPRAWY BOM ===" -ForegroundColor $Cyan