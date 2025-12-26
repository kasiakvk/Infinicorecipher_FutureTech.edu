# 🚀 SZYBKI UPLOAD PAKIET - Wszystkie pliki gotowe do GitHub

Write-Host "=== INFINICORECIPHER PROJECT - UPLOAD PACKAGE ===" -ForegroundColor Cyan
Write-Host "Przygotowywanie wszystkich plików do upload na GitHub..." -ForegroundColor Yellow

# Sprawdź czy jesteśmy w workspace
if (!(Test-Path "Master-Cleanup-Launcher.ps1")) {
    Write-Host "❌ BŁĄD: Uruchom ten skrypt z folderu workspace!" -ForegroundColor Red
    Write-Host "Folder powinien zawierać Master-Cleanup-Launcher.ps1" -ForegroundColor Red
    pause
    exit 1
}

# Lista wszystkich plików PowerShell
$PowerShellFiles = @(
    "All-In-One-Cleanup.ps1",
    "Master-Cleanup-Launcher.ps1", 
    "OneDrive-Check-Script.ps1",
    "OneDrive-Safe-Cleanup.ps1",
    "OneDrive-Quick-Check.ps1",
    "OneDrive-GitHub-Sync.ps1",
    "Run-OneDrive-Cleanup.ps1",
    "Copy-Missing-OneDrive-Scripts.ps1",
    "Windows-Auto-Copy.ps1",
    "Quick-Push-Commands.ps1",
    "SZYBKI-UPLOAD-PAKIET.ps1"
)

# Lista wszystkich plików dokumentacji
$DocumentationFiles = @(
    "README.md",
    "INSTRUKCJA-URUCHOMIENIA.md",
    "Windows-Git-Sync-Guide.md",
    "GitHub-Permission-Fix.md",
    "Token-Troubleshooting.md",
    "Final-GitHub-Solution.md",
    "OSTATECZNE-ROZWIAZANIE-GITHUB.md",
    "todo.md"
)

Write-Host "`n📊 SPRAWDZANIE PLIKÓW..." -ForegroundColor Green

$TotalFiles = 0
$TotalSize = 0

# Sprawdź pliki PowerShell
Write-Host "`n🔧 PowerShell Scripts:" -ForegroundColor Cyan
foreach ($file in $PowerShellFiles) {
    if (Test-Path $file) {
        $size = (Get-Item $file).Length
        $TotalSize += $size
        $TotalFiles++
        Write-Host "  ✅ $file ($([math]::Round($size/1KB, 1)) KB)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file (BRAK)" -ForegroundColor Red
    }
}

# Sprawdź pliki dokumentacji
Write-Host "`n📚 Documentation Files:" -ForegroundColor Cyan
foreach ($file in $DocumentationFiles) {
    if (Test-Path $file) {
        $size = (Get-Item $file).Length
        $TotalSize += $size
        $TotalFiles++
        Write-Host "  ✅ $file ($([math]::Round($size/1KB, 1)) KB)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file (BRAK)" -ForegroundColor Red
    }
}

# Sprawdź dodatkowe pliki
$AdditionalFiles = Get-ChildItem -File | Where-Object { 
    $_.Name -notin ($PowerShellFiles + $DocumentationFiles) -and
    $_.Name -notlike ".*" -and
    $_.Name -ne "SZYBKI-UPLOAD-PAKIET.ps1"
}

if ($AdditionalFiles) {
    Write-Host "`n📁 Additional Files:" -ForegroundColor Cyan
    foreach ($file in $AdditionalFiles) {
        $TotalSize += $file.Length
        $TotalFiles++
        Write-Host "  ✅ $($file.Name) ($([math]::Round($file.Length/1KB, 1)) KB)" -ForegroundColor Green
    }
}

Write-Host "`n📈 PODSUMOWANIE:" -ForegroundColor Yellow
Write-Host "  📁 Łączna liczba plików: $TotalFiles" -ForegroundColor White
Write-Host "  💾 Łączny rozmiar: $([math]::Round($TotalSize/1KB, 1)) KB" -ForegroundColor White
Write-Host "  🎯 Status: GOTOWE DO UPLOAD" -ForegroundColor Green

Write-Host "`n🚀 OPCJE UPLOAD:" -ForegroundColor Cyan
Write-Host "1. GitHub Desktop (REKOMENDOWANE)" -ForegroundColor Green
Write-Host "   - Pobierz: https://desktop.github.com/" -ForegroundColor Gray
Write-Host "   - Clone: Infinicorecipher-FutureTechEdu/Infinicorecipher" -ForegroundColor Gray
Write-Host "   - Skopiuj wszystkie pliki i push" -ForegroundColor Gray

Write-Host "`n2. Manual Upload przez przeglądarkę" -ForegroundColor Yellow
Write-Host "   - Idź do: https://github.com/Infinicorecipher-FutureTechEdu/Infinicorecipher" -ForegroundColor Gray
Write-Host "   - Kliknij 'uploading an existing file'" -ForegroundColor Gray
Write-Host "   - Przeciągnij wszystkie pliki" -ForegroundColor Gray

Write-Host "`n3. Nowy SSH Key" -ForegroundColor Blue
Write-Host "   - Wygeneruj klucz SSH" -ForegroundColor Gray
Write-Host "   - Dodaj do GitHub Settings" -ForegroundColor Gray
Write-Host "   - Użyj git@github.com:Infinicorecipher-FutureTechEdu/Infinicorecipher.git" -ForegroundColor Gray

Write-Host "`n✅ WSZYSTKIE PLIKI SĄ GOTOWE!" -ForegroundColor Green
Write-Host "Wybierz jedną z opcji powyżej aby upload projekt na GitHub." -ForegroundColor White

Write-Host "`n📋 LISTA PLIKÓW DO SKOPIOWANIA:" -ForegroundColor Cyan
Get-ChildItem -File | Where-Object { $_.Name -notlike ".*" } | Sort-Object Name | ForEach-Object {
    Write-Host "  📄 $($_.Name)" -ForegroundColor White
}

pause