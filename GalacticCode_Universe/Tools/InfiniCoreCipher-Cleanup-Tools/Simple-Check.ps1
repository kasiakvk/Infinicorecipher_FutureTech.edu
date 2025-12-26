# Simple-Check.ps1
# Bardzo prosty skrypt sprawdzający lokalizacje

Write-Host "=== SPRAWDZANIE LOKALIZACJI ===" -ForegroundColor Cyan
Write-Host ""

# Sprawdź C:\InfiniCoreCipher-Startup
Write-Host "1. Sprawdzanie C:\InfiniCoreCipher-Startup..." -ForegroundColor Yellow
if (Test-Path "C:\InfiniCoreCipher-Startup") {
    Write-Host "   ✅ ZNALEZIONO!" -ForegroundColor Green
    $items = Get-ChildItem "C:\InfiniCoreCipher-Startup"
    Write-Host "   📋 Zawiera $($items.Count) elementów:" -ForegroundColor Cyan
    $items | Select-Object -First 5 | ForEach-Object {
        Write-Host "      - $($_.Name)" -ForegroundColor Yellow
    }
    if ($items.Count -gt 5) {
        Write-Host "      ... i $($items.Count - 5) więcej" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ❌ Nie istnieje" -ForegroundColor Red
}

Write-Host ""

# Sprawdź pulpit
Write-Host "2. Sprawdzanie pulpitu..." -ForegroundColor Yellow
$desktop = "$env:USERPROFILE\Desktop"
if (Test-Path $desktop) {
    Write-Host "   ✅ Dostęp do pulpitu: $desktop" -ForegroundColor Green
    
    # Szukaj folderów z "Infini"
    $infiniDirs = Get-ChildItem $desktop -Directory | Where-Object {$_.Name -like "*Infini*"}
    if ($infiniDirs) {
        Write-Host "   ✅ Znaleziono foldery z 'Infini':" -ForegroundColor Green
        $infiniDirs | ForEach-Object {
            Write-Host "      📁 $($_.Name)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ❌ Brak folderów z 'Infini'" -ForegroundColor Red
    }
    
    # Pokaż wszystkie foldery
    $allDirs = Get-ChildItem $desktop -Directory
    Write-Host "   📋 Wszystkie foldery na pulpicie ($($allDirs.Count)):" -ForegroundColor Cyan
    $allDirs | ForEach-Object {
        Write-Host "      📁 $($_.Name)" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ❌ Brak dostępu do pulpitu" -ForegroundColor Red
}

Write-Host ""

# Sprawdź inne lokalizacje
$locations = @(
    "D:\InfiniCoreCipher-Startup",
    "$env:USERPROFILE\Documents\InfiniCoreCipher-Startup",
    "$env:USERPROFILE\Downloads\InfiniCoreCipher-Startup"
)

Write-Host "3. Sprawdzanie innych lokalizacji..." -ForegroundColor Yellow
foreach ($loc in $locations) {
    if (Test-Path $loc) {
        Write-Host "   ✅ $loc" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $loc" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== KONIEC ===" -ForegroundColor Cyan