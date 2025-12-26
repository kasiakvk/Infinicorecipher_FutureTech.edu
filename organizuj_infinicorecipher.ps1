# Skrypt PowerShell do organizacji plików Infinicorecipher Platform
# Przenieś kluczowe skrypty, dokumenty i konfiguracje do docelowych katalogów
# Usuń niepotrzebne pliki i foldery (np. backup_final_organization_*, stare wersje, duplikaty)

# Utwórz katalogi docelowe jeśli nie istnieją
$folders = @(
    "tools/scripts",
    "config",
    "docs/platform"
)
foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    }
}

# Przenieś skrypty automatyzacji
gci organize_infinicorecipher_structure.ps1,quick_organize_infinicorecipher.ps1,structure_validator.ps1,roadmap_manager.ps1 -ea SilentlyContinue | Move-Item -Destination "tools/scripts" -Force

# Przenieś konfiguracje
gci infinicorecipher_config_updated.json,organization_config.json -ea SilentlyContinue | Move-Item -Destination "config" -Force

# Przenieś dokumentację i manifesty
gci README.md,PLATFORM_MANIFEST.md,PROJECT_MANIFEST.md,STRUCTURE.md,PRIVACY.md,SECURITY.md -ea SilentlyContinue | Move-Item -Destination "docs/platform" -Force

# Przenieś checklisty i przewodniki wdrożeniowe (jeśli istnieją)
gci *checklist*.md,*przewodnik*.md,*guide*.md -ea SilentlyContinue | Move-Item -Destination "docs/platform" -Force

# Usuń stare backupy, duplikaty, nieużywane pliki
$toDelete = @("backup_final_organization_*", "Backups", "*.bak", "*old*", "*copy*", "*tmp*", "*temp*")
foreach ($pattern in $toDelete) {
    gci -Recurse -Filter $pattern -ea SilentlyContinue | Remove-Item -Recurse -Force
}

Write-Host "Organizacja zakończona. Kluczowe pliki przeniesione, niepotrzebne usunięte." -ForegroundColor Green
