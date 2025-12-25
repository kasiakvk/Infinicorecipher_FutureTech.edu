#!/usr/bin/env pwsh
# Walidator Struktury Infinicorecipher Platform
# Sprawdza zgodność z wymaganiami i standardami

param(
    [string]$TargetPath = "./Infinicorecipher_Platform",
    [switch]$Detailed = $false,
    [switch]$Fix = $false,
    [switch]$Report = $false,
    [switch]$Help = $false
)

if ($Help) {
    Write-Host "🔍 WALIDATOR STRUKTURY INFINICORECIPHER PLATFORM" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "UŻYCIE:" -ForegroundColor Yellow
    Write-Host "  ./structure_validator.ps1                    # Podstawowa walidacja"
    Write-Host "  ./structure_validator.ps1 -Detailed          # Szczegółowa walidacja"
    Write-Host "  ./structure_validator.ps1 -Fix               # Napraw problemy"
    Write-Host "  ./structure_validator.ps1 -Report            # Generuj raport"
    Write-Host "  ./structure_validator.ps1 -Help              # Ta pomoc"
    Write-Host ""
    Write-Host "PRZYKŁADY:" -ForegroundColor Yellow
    Write-Host "  # Szybka walidacja struktury"
    Write-Host "  ./structure_validator.ps1"
    Write-Host ""
    Write-Host "  # Szczegółowa analiza z raportem"
    Write-Host "  ./structure_validator.ps1 -Detailed -Report"
    Write-Host ""
    Write-Host "  # Automatyczne naprawianie problemów"
    Write-Host "  ./structure_validator.ps1 -Fix"
    Write-Host ""
    return
}

Write-Host "🔍 WALIDATOR STRUKTURY INFINICORECIPHER PLATFORM" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "📅 Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
Write-Host "📂 Ścieżka: $TargetPath" -ForegroundColor Yellow

# Definicja wymaganych katalogów
$requiredDirectories = @{
    # Platform Core
    "platform/core/config" = @{ priority = "critical"; description = "Konfiguracja podstawowa platformy" }
    "platform/core/services" = @{ priority = "critical"; description = "Usługi podstawowe platformy" }
    "platform/core/models" = @{ priority = "high"; description = "Modele danych platformy" }
    "platform/security/encryption" = @{ priority = "critical"; description = "Szyfrowanie Infinicorecipher" }
    "platform/security/auth" = @{ priority = "critical"; description = "System autentykacji" }
    "platform/education/curriculum" = @{ priority = "high"; description = "Programy nauczania" }
    "platform/education/analytics" = @{ priority = "high"; description = "Analityka edukacyjna" }
    
    # Applications
    "applications/galactic-code/web-client/src" = @{ priority = "critical"; description = "Kod źródłowy React" }
    "applications/galactic-code/backend/Controllers" = @{ priority = "critical"; description = "Kontrolery API .NET" }
    "applications/galactic-code/backend/Services" = @{ priority = "high"; description = "Logika biznesowa" }
    "applications/galactic-code/shared/contracts" = @{ priority = "medium"; description = "Kontrakty API" }
    
    # Services
    "services/platform-gateway/src" = @{ priority = "critical"; description = "Kod źródłowy bramy API" }
    "services/auth-service/src" = @{ priority = "critical"; description = "Kod usługi autentykacji" }
    "services/user-service/src" = @{ priority = "critical"; description = "Zarządzanie użytkownikami" }
    "services/analytics-service/src" = @{ priority = "high"; description = "Analityka i metryki" }
    "services/education-service/src" = @{ priority = "high"; description = "Framework edukacyjny" }
    "services/content-service/src" = @{ priority = "medium"; description = "Zarządzanie treścią" }
    
    # Infrastructure
    "infrastructure/docker/compose" = @{ priority = "critical"; description = "Docker Compose files" }
    "infrastructure/kubernetes/deployments" = @{ priority = "high"; description = "Wdrożenia K8s" }
    "infrastructure/database/migrations" = @{ priority = "critical"; description = "Migracje bazy danych" }
    "infrastructure/monitoring/prometheus" = @{ priority = "high"; description = "Konfiguracja Prometheus" }
    "infrastructure/monitoring/grafana" = @{ priority = "medium"; description = "Dashboardy Grafana" }
    
    # Documentation
    "docs/platform/architecture" = @{ priority = "high"; description = "Dokumentacja architektury" }
    "docs/platform/security" = @{ priority = "high"; description = "Dokumentacja bezpieczeństwa" }
    "docs/services/api-reference" = @{ priority = "high"; description = "Referencje API usług" }
    "docs/deployment" = @{ priority = "high"; description = "Przewodniki wdrażania" }
    
    # Tools
    "tools/scripts/setup" = @{ priority = "high"; description = "Skrypty konfiguracji" }
    "tools/generators/service" = @{ priority = "medium"; description = "Generatory usług" }
    "tools/migration/legacy" = @{ priority = "medium"; description = "Migracja starych systemów" }
    
    # Tests
    "tests/unit/platform" = @{ priority = "high"; description = "Testy jednostkowe platformy" }
    "tests/integration/api" = @{ priority = "high"; description = "Testy integracyjne API" }
    "tests/e2e/web" = @{ priority = "medium"; description = "Testy end-to-end webowe" }
    
    # Packages
    "packages/ui-components/src" = @{ priority = "medium"; description = "Komponenty UI" }
    "packages/utils/src" = @{ priority = "medium"; description = "Narzędzia współdzielone" }
    
    # Config
    "config/environments" = @{ priority = "high"; description = "Konfiguracje środowisk" }
    "config/security" = @{ priority = "critical"; description = "Konfiguracja bezpieczeństwa" }
}

# Wymagane pliki
$requiredFiles = @{
    "README.md" = @{ priority = "critical"; description = "Główny plik README" }
    ".gitignore" = @{ priority = "high"; description = "Plik gitignore" }
    "platform/core/config/platform.json" = @{ priority = "critical"; description = "Konfiguracja platformy" }
    "infrastructure/docker/docker-compose.yml" = @{ priority = "critical"; description = "Docker Compose" }
    "docs/platform/architecture/README.md" = @{ priority = "high"; description = "Dokumentacja architektury" }
    "tools/scripts/setup/organize-structure.ps1" = @{ priority = "high"; description = "Skrypt organizacji" }
}

# Standardy nazewnictwa
$namingStandards = @{
    "directories" = @{
        "pattern" = "^[a-z0-9-]+$"
        "description" = "Katalogi: małe litery, cyfry, myślniki"
        "examples" = @("platform-gateway", "auth-service", "web-client")
    }
    "files_config" = @{
        "pattern" = "^[a-z0-9-]+\.(json|yml|yaml|env)$"
        "description" = "Pliki konfiguracyjne: małe litery, myślniki"
        "examples" = @("platform.json", "docker-compose.yml", ".env")
    }
    "files_scripts" = @{
        "pattern" = "^[a-z0-9-_]+\.(ps1|sh|bat)$"
        "description" = "Skrypty: małe litery, myślniki, podkreślenia"
        "examples" = @("organize-structure.ps1", "setup_platform.sh")
    }
    "files_docs" = @{
        "pattern" = "^[A-Z0-9_-]+\.(md|txt|rst)$"
        "description" = "Dokumentacja: wielkie litery, myślniki, podkreślenia"
        "examples" = @("README.md", "API_REFERENCE.md", "DEPLOYMENT_GUIDE.md")
    }
}

# Funkcja walidacji katalogów
function Test-DirectoryStructure {
    Write-Host "`n📁 Walidacja struktury katalogów..." -ForegroundColor Blue
    
    $results = @{
        missing = @()
        existing = @()
        critical_missing = @()
        high_missing = @()
    }
    
    foreach ($dir in $requiredDirectories.Keys) {
        $fullPath = Join-Path $TargetPath $dir
        $info = $requiredDirectories[$dir]
        
        if (Test-Path $fullPath -PathType Container) {
            $results.existing += @{ path = $dir; info = $info }
            if ($Detailed) {
                Write-Host "  ✅ $dir" -ForegroundColor Green
            }
        } else {
            $results.missing += @{ path = $dir; info = $info }
            
            $color = switch ($info.priority) {
                "critical" { "Red"; $results.critical_missing += $dir }
                "high" { "Yellow"; $results.high_missing += $dir }
                "medium" { "Gray" }
                default { "Gray" }
            }
            
            Write-Host "  ❌ $dir ($($info.priority))" -ForegroundColor $color
        }
    }
    
    return $results
}

# Funkcja walidacji plików
function Test-RequiredFiles {
    Write-Host "`n📄 Walidacja wymaganych plików..." -ForegroundColor Blue
    
    $results = @{
        missing = @()
        existing = @()
        critical_missing = @()
    }
    
    foreach ($file in $requiredFiles.Keys) {
        $fullPath = Join-Path $TargetPath $file
        $info = $requiredFiles[$file]
        
        if (Test-Path $fullPath -PathType Leaf) {
            $results.existing += @{ path = $file; info = $info }
            if ($Detailed) {
                Write-Host "  ✅ $file" -ForegroundColor Green
            }
        } else {
            $results.missing += @{ path = $file; info = $info }
            
            if ($info.priority -eq "critical") {
                $results.critical_missing += $file
                Write-Host "  ❌ $file (KRYTYCZNY)" -ForegroundColor Red
            } else {
                Write-Host "  ❌ $file ($($info.priority))" -ForegroundColor Yellow
            }
        }
    }
    
    return $results
}

# Funkcja walidacji nazewnictwa
function Test-NamingConventions {
    Write-Host "`n📝 Walidacja standardów nazewnictwa..." -ForegroundColor Blue
    
    $violations = @()
    
    if (Test-Path $TargetPath) {
        # Sprawdź katalogi
        $directories = Get-ChildItem -Path $TargetPath -Directory -Recurse | Where-Object {
            $_.FullName -notmatch "\\\.git\\" -and 
            $_.FullName -notmatch "\\node_modules\\" -and
            $_.FullName -notmatch "\\bin\\" -and
            $_.FullName -notmatch "\\obj\\"
        }
        
        foreach ($dir in $directories) {
            $relativePath = $dir.FullName.Substring($TargetPath.Length + 1)
            $dirName = $dir.Name
            
            if ($dirName -notmatch $namingStandards.directories.pattern) {
                $violations += @{
                    type = "directory"
                    path = $relativePath
                    name = $dirName
                    issue = "Nieprawidłowe nazewnictwo katalogu"
                    standard = $namingStandards.directories.description
                }
                
                if ($Detailed) {
                    Write-Host "  ❌ Katalog: $relativePath" -ForegroundColor Red
                    Write-Host "    Standard: $($namingStandards.directories.description)" -ForegroundColor Gray
                }
            }
        }
        
        # Sprawdź pliki konfiguracyjne
        $configFiles = Get-ChildItem -Path $TargetPath -File -Recurse | Where-Object {
            $_.Extension -in @(".json", ".yml", ".yaml", ".env") -and
            $_.FullName -notmatch "\\\.git\\" -and
            $_.FullName -notmatch "\\node_modules\\"
        }
        
        foreach ($file in $configFiles) {
            $relativePath = $file.FullName.Substring($TargetPath.Length + 1)
            
            if ($file.Name -notmatch $namingStandards.files_config.pattern) {
                $violations += @{
                    type = "config_file"
                    path = $relativePath
                    name = $file.Name
                    issue = "Nieprawidłowe nazewnictwo pliku konfiguracyjnego"
                    standard = $namingStandards.files_config.description
                }
            }
        }
    }
    
    return $violations
}

# Funkcja naprawiania problemów
function Repair-Structure {
    param($directoryResults, $fileResults)
    
    Write-Host "`n🔧 Naprawianie struktury..." -ForegroundColor Yellow
    
    $fixed = 0
    
    # Utwórz brakujące katalogi krytyczne i wysokiej ważności
    foreach ($missing in $directoryResults.missing) {
        if ($missing.info.priority -in @("critical", "high")) {
            $fullPath = Join-Path $TargetPath $missing.path
            
            try {
                New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
                Write-Host "  ✅ Utworzono: $($missing.path)" -ForegroundColor Green
                $fixed++
                
                # Utwórz README.md w katalogu
                $readmePath = Join-Path $fullPath "README.md"
                if (!(Test-Path $readmePath)) {
                    $readmeContent = @"
# $(Split-Path $missing.path -Leaf)

$($missing.info.description)

## Przeznaczenie

Ten katalog jest częścią Platformy Edukacyjnej Infinicorecipher.

## Zawartość

*Katalog zostanie wypełniony podczas implementacji platformy.*

---
*Wygenerowano automatycznie przez structure_validator.ps1*
"@
                    Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8
                    Write-Host "    📄 Utworzono README.md" -ForegroundColor Gray
                }
            } catch {
                Write-Host "  ❌ Błąd tworzenia $($missing.path): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    # Utwórz brakujące pliki krytyczne
    foreach ($missing in $fileResults.missing) {
        if ($missing.info.priority -eq "critical") {
            $fullPath = Join-Path $TargetPath $missing.path
            $directory = Split-Path $fullPath -Parent
            
            try {
                # Utwórz katalog jeśli nie istnieje
                if (!(Test-Path $directory)) {
                    New-Item -ItemType Directory -Path $directory -Force | Out-Null
                }
                
                # Utwórz plik z podstawową zawartością
                $content = switch ($missing.path) {
                    "README.md" {
                        @"
# 🏛️ Infinicorecipher Platform

Zaawansowana Platforma Edukacyjna z Kryptograficznym Zabezpieczeniem

## Przegląd

*Dokumentacja zostanie uzupełniona podczas implementacji.*

---
*Wygenerowano automatycznie przez structure_validator.ps1*
"@
                    }
                    ".gitignore" {
                        @"
# Pliki systemowe
.DS_Store
Thumbs.db
*.log
*.tmp

# Środowiska
.env
.env.local

# Budowanie
bin/
obj/
dist/
build/
node_modules/

# IDE
.vs/
.vscode/

# Kopie zapasowe
backup_*/
*.backup_*
"@
                    }
                    "platform/core/config/platform.json" {
                        @"
{
  "platform": {
    "name": "Infinicorecipher",
    "version": "1.0.0",
    "environment": "development"
  },
  "security": {
    "encryption": {
      "algorithm": "infinicorecipher"
    }
  }
}
"@
                    }
                    default {
                        "# $($missing.info.description)`n`n*Plik zostanie uzupełniony podczas implementacji.*"
                    }
                }
                
                Set-Content -Path $fullPath -Value $content -Encoding UTF8
                Write-Host "  ✅ Utworzono: $($missing.path)" -ForegroundColor Green
                $fixed++
            } catch {
                Write-Host "  ❌ Błąd tworzenia $($missing.path): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    Write-Host "`n🎉 Naprawiono $fixed problemów" -ForegroundColor Green
}

# Funkcja generowania raportu
function Generate-ValidationReport {
    param($directoryResults, $fileResults, $namingViolations)
    
    $reportPath = Join-Path $TargetPath "STRUCTURE_VALIDATION_REPORT.md"
    
    $report = @"
# 🔍 Raport Walidacji Struktury Infinicorecipher Platform

**Data:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Walidator:** structure_validator.ps1  
**Ścieżka:** $TargetPath

## 📊 Podsumowanie

### Katalogi
- **Istniejące:** $($directoryResults.existing.Count)
- **Brakujące:** $($directoryResults.missing.Count)
- **Krytyczne brakujące:** $($directoryResults.critical_missing.Count)
- **Wysokiej ważności brakujące:** $($directoryResults.high_missing.Count)

### Pliki
- **Istniejące:** $($fileResults.existing.Count)
- **Brakujące:** $($fileResults.missing.Count)
- **Krytyczne brakujące:** $($fileResults.critical_missing.Count)

### Nazewnictwo
- **Naruszenia standardów:** $($namingViolations.Count)

## ❌ Problemy Krytyczne

"@

    if ($directoryResults.critical_missing.Count -gt 0) {
        $report += "`n### Brakujące katalogi krytyczne:`n"
        foreach ($dir in $directoryResults.critical_missing) {
            $info = $requiredDirectories[$dir]
            $report += "- **$dir** - $($info.description)`n"
        }
    }
    
    if ($fileResults.critical_missing.Count -gt 0) {
        $report += "`n### Brakujące pliki krytyczne:`n"
        foreach ($file in $fileResults.critical_missing) {
            $info = $requiredFiles[$file]
            $report += "- **$file** - $($info.description)`n"
        }
    }
    
    $report += @"

## ⚠️ Problemy Wysokiej Ważności

"@

    if ($directoryResults.high_missing.Count -gt 0) {
        $report += "`n### Brakujące katalogi wysokiej ważności:`n"
        foreach ($dir in $directoryResults.high_missing) {
            $info = $requiredDirectories[$dir]
            $report += "- **$dir** - $($info.description)`n"
        }
    }
    
    if ($namingViolations.Count -gt 0) {
        $report += "`n### Naruszenia standardów nazewnictwa:`n"
        foreach ($violation in $namingViolations) {
            $report += "- **$($violation.path)** - $($violation.issue)`n"
            $report += "  - Standard: $($violation.standard)`n"
        }
    }
    
    $report += @"

## ✅ Elementy Poprawne

### Istniejące katalogi:
"@

    foreach ($existing in $directoryResults.existing) {
        $report += "- **$($existing.path)** - $($existing.info.description)`n"
    }
    
    $report += "`n### Istniejące pliki:`n"
    foreach ($existing in $fileResults.existing) {
        $report += "- **$($existing.path)** - $($existing.info.description)`n"
    }
    
    $report += @"

## 🔧 Rekomendacje Naprawy

### Automatyczne naprawy:
```powershell
# Napraw strukturę automatycznie
./structure_validator.ps1 -Fix

# Sprawdź ponownie po naprawie
./structure_validator.ps1 -Detailed
```

### Manualne akcje:
1. **Uzupełnij brakujące katalogi** - Szczególnie krytyczne i wysokiej ważności
2. **Utwórz brakujące pliki** - Rozpocznij od plików krytycznych
3. **Popraw nazewnictwo** - Dostosuj do standardów platformy
4. **Dodaj dokumentację** - README.md w każdym katalogu

## 📋 Standardy Nazewnictwa

### Katalogi:
- **Wzorzec:** $($namingStandards.directories.pattern)
- **Opis:** $($namingStandards.directories.description)
- **Przykłady:** $($namingStandards.directories.examples -join ", ")

### Pliki konfiguracyjne:
- **Wzorzec:** $($namingStandards.files_config.pattern)
- **Opis:** $($namingStandards.files_config.description)
- **Przykłady:** $($namingStandards.files_config.examples -join ", ")

### Skrypty:
- **Wzorzec:** $($namingStandards.files_scripts.pattern)
- **Opis:** $($namingStandards.files_scripts.description)
- **Przykłady:** $($namingStandards.files_scripts.examples -join ", ")

---
*Wygenerowano automatycznie przez structure_validator.ps1*
"@

    Set-Content -Path $reportPath -Value $report -Encoding UTF8
    Write-Host "📄 Raport zapisany: $reportPath" -ForegroundColor Green
}

# GŁÓWNA LOGIKA WALIDACJI

if (!(Test-Path $TargetPath)) {
    Write-Host "❌ Ścieżka nie istnieje: $TargetPath" -ForegroundColor Red
    Write-Host "💡 Uruchom najpierw skrypt organizacji: ./organize_infinicorecipher_structure.ps1" -ForegroundColor Yellow
    return
}

# Walidacja katalogów
$directoryResults = Test-DirectoryStructure

# Walidacja plików
$fileResults = Test-RequiredFiles

# Walidacja nazewnictwa
$namingViolations = @()
if ($Detailed) {
    $namingViolations = Test-NamingConventions
}

# Podsumowanie wyników
Write-Host "`n📊 PODSUMOWANIE WALIDACJI" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

$totalDirectories = $requiredDirectories.Count
$existingDirectories = $directoryResults.existing.Count
$directoryCompleteness = [math]::Round(($existingDirectories / $totalDirectories) * 100, 1)

$totalFiles = $requiredFiles.Count
$existingFiles = $fileResults.existing.Count
$fileCompleteness = [math]::Round(($existingFiles / $totalFiles) * 100, 1)

Write-Host "📁 Katalogi: $existingDirectories/$totalDirectories ($directoryCompleteness%)" -ForegroundColor $(if($directoryCompleteness -ge 80){"Green"}elseif($directoryCompleteness -ge 60){"Yellow"}else{"Red"})
Write-Host "📄 Pliki: $existingFiles/$totalFiles ($fileCompleteness%)" -ForegroundColor $(if($fileCompleteness -ge 80){"Green"}elseif($fileCompleteness -ge 60){"Yellow"}else{"Red"})

if ($directoryResults.critical_missing.Count -gt 0) {
    Write-Host "🔴 Krytyczne katalogi brakujące: $($directoryResults.critical_missing.Count)" -ForegroundColor Red
}

if ($fileResults.critical_missing.Count -gt 0) {
    Write-Host "🔴 Krytyczne pliki brakujące: $($fileResults.critical_missing.Count)" -ForegroundColor Red
}

if ($namingViolations.Count -gt 0) {
    Write-Host "⚠️ Naruszenia nazewnictwa: $($namingViolations.Count)" -ForegroundColor Yellow
}

# Ocena ogólna
$overallScore = ($directoryCompleteness + $fileCompleteness) / 2
$criticalIssues = $directoryResults.critical_missing.Count + $fileResults.critical_missing.Count

Write-Host "`n🎯 OCENA OGÓLNA: " -NoNewline
if ($criticalIssues -eq 0 -and $overallScore -ge 90) {
    Write-Host "DOSKONAŁA ✅" -ForegroundColor Green
} elseif ($criticalIssues -eq 0 -and $overallScore -ge 75) {
    Write-Host "DOBRA 👍" -ForegroundColor Yellow
} elseif ($criticalIssues -le 2 -and $overallScore -ge 60) {
    Write-Host "WYMAGA POPRAWY ⚠️" -ForegroundColor Yellow
} else {
    Write-Host "KRYTYCZNE PROBLEMY ❌" -ForegroundColor Red
}

# Wykonaj naprawy jeśli żądane
if ($Fix) {
    Repair-Structure $directoryResults $fileResults
}

# Generuj raport jeśli żądany
if ($Report) {
    Generate-ValidationReport $directoryResults $fileResults $namingViolations
}

# Rekomendacje
Write-Host "`n💡 REKOMENDACJE:" -ForegroundColor Cyan

if ($criticalIssues -gt 0) {
    Write-Host "🔴 PILNE: Napraw problemy krytyczne" -ForegroundColor Red
    Write-Host "   ./structure_validator.ps1 -Fix" -ForegroundColor White
}

if ($directoryResults.high_missing.Count -gt 0) {
    Write-Host "🟡 Uzupełnij katalogi wysokiej ważności" -ForegroundColor Yellow
}

if ($namingViolations.Count -gt 0) {
    Write-Host "📝 Popraw nazewnictwo według standardów" -ForegroundColor Yellow
}

if ($overallScore -ge 90 -and $criticalIssues -eq 0) {
    Write-Host "🎉 Struktura jest gotowa do implementacji!" -ForegroundColor Green
    Write-Host "   Następny krok: ./roadmap_manager.ps1 status" -ForegroundColor White
}

Write-Host "`n💡 Wskazówka: Użyj -Help aby zobaczyć wszystkie opcje" -ForegroundColor Gray
