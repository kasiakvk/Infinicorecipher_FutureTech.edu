#!/usr/bin/env pwsh
# Szybki Organizator Infinicorecipher Platform
# Uproszczona wersja do codziennego użytku

param(
    [switch]$Preview = $false,
    [switch]$Refresh = $false,
    [switch]$Verify = $false,
    [switch]$Help = $false
)

if ($Help) {
    Write-Host "🏛️ SZYBKI ORGANIZATOR INFINICORECIPHER PLATFORM" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "UŻYCIE:" -ForegroundColor Yellow
    Write-Host "  ./quick_organize_infinicorecipher.ps1           # Organizuj pliki"
    Write-Host "  ./quick_organize_infinicorecipher.ps1 -Preview  # Podgląd zmian"
    Write-Host "  ./quick_organize_infinicorecipher.ps1 -Refresh  # Odśwież strukturę"
    Write-Host "  ./quick_organize_infinicorecipher.ps1 -Verify   # Sprawdź strukturę"
    Write-Host "  ./quick_organize_infinicorecipher.ps1 -Help     # Ta pomoc"
    Write-Host ""
    Write-Host "PRZYKŁADY:" -ForegroundColor Yellow
    Write-Host "  # Bezpieczny podgląd przed organizacją"
    Write-Host "  ./quick_organize_infinicorecipher.ps1 -Preview"
    Write-Host ""
    Write-Host "  # Organizacja nowych plików"
    Write-Host "  ./quick_organize_infinicorecipher.ps1"
    Write-Host ""
    Write-Host "  # Odświeżenie po dodaniu nowych plików"
    Write-Host "  ./quick_organize_infinicorecipher.ps1 -Refresh"
    Write-Host ""
    return
}

Write-Host "🏛️ SZYBKI ORGANIZATOR INFINICORECIPHER PLATFORM" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Przekieruj do głównego skryptu z odpowiednimi parametrami
if ($Preview) {
    Write-Host "🔍 Uruchamianie w trybie podglądu..." -ForegroundColor Yellow
    & "./organize_infinicorecipher_structure.ps1" -DryRun -Verbose
} elseif ($Refresh) {
    Write-Host "🔄 Odświeżanie struktury..." -ForegroundColor Blue
    & "./organize_infinicorecipher_structure.ps1" -RefreshOnly
} elseif ($Verify) {
    Write-Host "✅ Weryfikacja struktury..." -ForegroundColor Green
    & "./organize_infinicorecipher_structure.ps1" -VerifyStructure
} else {
    Write-Host "🚀 Organizowanie plików..." -ForegroundColor Green
    & "./organize_infinicorecipher_structure.ps1"
}

Write-Host "`n💡 Wskazówka: Użyj -Help aby zobaczyć wszystkie opcje" -ForegroundColor Gray