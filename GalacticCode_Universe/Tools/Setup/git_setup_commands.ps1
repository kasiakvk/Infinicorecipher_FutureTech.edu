# Git Setup Commands for InfiniCoreCipher Startup
# Skrypt do inicjalizacji repozytoriów Git

param(
    [string]$BasePath = "D:\InfiniCoreCipher-Startup-BACKUP-20251212"
)

Write-Host "=== GIT REPOSITORIES SETUP ===" -ForegroundColor Cyan
Write-Host "Lokalizacja: $BasePath" -ForegroundColor Yellow

# Przejdź do katalogu głównego
cd $BasePath

# Inicjalizuj główne repozytorium
Write-Host "`n=== GŁÓWNE REPOZYTORIUM ===" -ForegroundColor Green
git init
git add .
git commit -m "Initial commit: InfiniCoreCipher Startup structure"

Write-Host "✅ Główne repozytorium zainicjalizowane" -ForegroundColor Green

# Przejdź do katalogu repozytoriów
cd repositories

# Lista repozytoriów do inicjalizacji
$repositories = @{
    "infinicorecipher-core" = @{
        "description" = "Główne repozytorium platformy InfiniCoreCipher"
        "remote" = "https://github.com/yourusername/infinicorecipher-core.git"
    }
    "infinicorecipher-api" = @{
        "description" = "API platformy InfiniCoreCipher"
        "remote" = "https://github.com/yourusername/infinicorecipher-api.git"
    }
    "infinicorecipher-frontend" = @{
        "description" = "Frontend platformy InfiniCoreCipher"
        "remote" = "https://github.com/yourusername/infinicorecipher-frontend.git"
    }
    "infinicorecipher-backend" = @{
        "description" = "Backend platformy InfiniCoreCipher"
        "remote" = "https://github.com/yourusername/infinicorecipher-backend.git"
    }
    "infinicorecipher-docs" = @{
        "description" = "Dokumentacja platformy InfiniCoreCipher"
        "remote" = "https://github.com/yourusername/infinicorecipher-docs.git"
    }
    "galacticcode-universe" = @{
        "description" = "Repozytorium gry GalacticCode Universe"
        "remote" = "https://github.com/yourusername/galacticcode-universe.git"
    }
    "starlight-universe" = @{
        "description" = "Repozytorium gry Starlight Universe"
        "remote" = "https://github.com/yourusername/starlight-universe.git"
    }
    "shared-libraries" = @{
        "description" = "Współdzielone biblioteki"
        "remote" = "https://github.com/yourusername/infinicore-shared-libraries.git"
    }
    "tools-and-utilities" = @{
        "description" = "Narzędzia deweloperskie"
        "remote" = "https://github.com/yourusername/infinicore-tools.git"
    }
}

Write-Host "`n=== INICJALIZACJA REPOZYTORIÓW ===" -ForegroundColor Cyan

foreach ($repo in $repositories.Keys) {
    Write-Host "`n📦 Inicjalizacja: $repo" -ForegroundColor Yellow
    
    cd $repo
    
    # Inicjalizuj Git
    git init
    
    # Dodaj wszystkie pliki
    git add .
    
    # Pierwszy commit
    git commit -m "Initial commit: $($repositories[$repo].description)"
    
    # Dodaj remote (zakomentowane - odkomentuj gdy masz repozytoria na GitHub)
    # git remote add origin $($repositories[$repo].remote)
    
    Write-Host "✅ $repo zainicjalizowane" -ForegroundColor Green
    
    cd ..
}

# Wróć do katalogu głównego
cd ..

Write-Host "`n=== KONFIGURACJA .GITMODULES ===" -ForegroundColor Cyan

# Stwórz plik .gitmodules dla submodułów
$gitmodulesContent = @"
# Git Submodules for InfiniCoreCipher Startup

[submodule "repositories/infinicorecipher-core"]
    path = repositories/infinicorecipher-core
    url = https://github.com/yourusername/infinicorecipher-core.git

[submodule "repositories/infinicorecipher-api"]
    path = repositories/infinicorecipher-api
    url = https://github.com/yourusername/infinicorecipher-api.git

[submodule "repositories/infinicorecipher-frontend"]
    path = repositories/infinicorecipher-frontend
    url = https://github.com/yourusername/infinicorecipher-frontend.git

[submodule "repositories/infinicorecipher-backend"]
    path = repositories/infinicorecipher-backend
    url = https://github.com/yourusername/infinicorecipher-backend.git

[submodule "repositories/infinicorecipher-docs"]
    path = repositories/infinicorecipher-docs
    url = https://github.com/yourusername/infinicorecipher-docs.git

[submodule "repositories/galacticcode-universe"]
    path = repositories/galacticcode-universe
    url = https://github.com/yourusername/galacticcode-universe.git

[submodule "repositories/starlight-universe"]
    path = repositories/starlight-universe
    url = https://github.com/yourusername/starlight-universe.git

[submodule "repositories/shared-libraries"]
    path = repositories/shared-libraries
    url = https://github.com/yourusername/infinicore-shared-libraries.git

[submodule "repositories/tools-and-utilities"]
    path = repositories/tools-and-utilities
    url = https://github.com/yourusername/infinicore-tools.git
"@

$gitmodulesContent | Out-File ".gitmodules" -Encoding UTF8

Write-Host "✅ .gitmodules utworzony" -ForegroundColor Green

Write-Host "`n=== PODSUMOWANIE GIT SETUP ===" -ForegroundColor Cyan
Write-Host "✅ Główne repozytorium zainicjalizowane" -ForegroundColor Green
Write-Host "✅ $($repositories.Count) repozytoriów zainicjalizowanych" -ForegroundColor Green
Write-Host "✅ .gitmodules skonfigurowany" -ForegroundColor Green

Write-Host "`n📋 NASTĘPNE KROKI:" -ForegroundColor Yellow
Write-Host "1. Stwórz repozytoria na GitHub/GitLab" -ForegroundColor Gray
Write-Host "2. Zaktualizuj URL-e w .gitmodules" -ForegroundColor Gray
Write-Host "3. Dodaj remote origins:" -ForegroundColor Gray
Write-Host "   git remote add origin <URL>" -ForegroundColor Gray
Write-Host "4. Push do remote:" -ForegroundColor Gray
Write-Host "   git push -u origin main" -ForegroundColor Gray

Write-Host "`n🔧 KOMENDY DO SKOPIOWANIA:" -ForegroundColor Cyan
Write-Host "# Dla każdego repozytorium:" -ForegroundColor Gray
Write-Host "cd repositories/<repo-name>" -ForegroundColor Gray
Write-Host "git remote add origin <GitHub-URL>" -ForegroundColor Gray
Write-Host "git branch -M main" -ForegroundColor Gray
Write-Host "git push -u origin main" -ForegroundColor Gray