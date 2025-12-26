# Analyze-InfiniCoreCipher-Architecture.ps1
# Kompleksowa analiza architektury projektu InfiniCoreCipher

param(
    [string]$ProjectPath = (Get-Location).Path,
    [switch]$DetailedAnalysis = $false,
    [switch]$GenerateReport = $true
)

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Magenta = "Magenta"

Write-Host "🏗️  ANALIZA ARCHITEKTURY INFINICORECIPHER" -ForegroundColor $Cyan
Write-Host "=========================================" -ForegroundColor $Cyan
Write-Host "Projekt: $ProjectPath" -ForegroundColor $Yellow
Write-Host ""

if (-not (Test-Path $ProjectPath)) {
    Write-Host "❌ Folder projektu nie istnieje: $ProjectPath" -ForegroundColor $Red
    exit 1
}

Push-Location $ProjectPath

try {
    # ANALIZA 1: OBECNA STRUKTURA PROJEKTU
    Write-Host "📊 ANALIZA 1: OBECNA STRUKTURA PROJEKTU" -ForegroundColor $Cyan
    Write-Host ""
    
    # Definicja oczekiwanej architektury
    $ExpectedArchitecture = @{
        "Core Files" = @{
            "package.json" = "Root package configuration"
            "README.md" = "Project documentation"
            ".gitignore" = "Git ignore rules"
            "docker-compose.yml" = "Docker orchestration"
            "docker-compose.dev.yml" = "Development Docker setup"
        }
        "Frontend Architecture" = @{
            "frontend/package.json" = "Frontend dependencies"
            "frontend/index.html" = "Main HTML entry point"
            "frontend/vite.config.ts" = "Vite build configuration"
            "frontend/tsconfig.json" = "TypeScript configuration"
            "frontend/tailwind.config.js" = "Tailwind CSS configuration"
            "frontend/src/main.tsx" = "React application entry point"
            "frontend/src/App.tsx" = "Main React component"
            "frontend/src/styles/index.css" = "Global styles"
        }
        "Frontend Components" = @{
            "frontend/src/components/accessibility/AccessibilityToolbar.tsx" = "Accessibility controls"
            "frontend/src/components/games/GalacticCode.tsx" = "Programming game component"
            "frontend/src/components/games/StarlightMath.tsx" = "Math game component"
            "frontend/src/components/games/FocusQuest.tsx" = "Focus training game"
            "frontend/src/components/games/SocialSkillsGalaxy.tsx" = "Social skills game"
            "frontend/src/components/ui/Button.tsx" = "Reusable button component"
            "frontend/src/components/ui/Modal.tsx" = "Modal dialog component"
            "frontend/src/components/ui/LoadingSpinner.tsx" = "Loading indicator"
            "frontend/src/components/layout/Header.tsx" = "Application header"
            "frontend/src/components/layout/Navigation.tsx" = "Navigation menu"
            "frontend/src/components/layout/Footer.tsx" = "Application footer"
        }
        "Frontend Pages" = @{
            "frontend/src/pages/Home.tsx" = "Landing page"
            "frontend/src/pages/Dashboard.tsx" = "User dashboard"
            "frontend/src/pages/Games.tsx" = "Games selection page"
            "frontend/src/pages/Profile.tsx" = "User profile page"
            "frontend/src/pages/Settings.tsx" = "Settings page"
            "frontend/src/pages/ParentDashboard.tsx" = "Parent monitoring dashboard"
            "frontend/src/pages/Login.tsx" = "Authentication page"
            "frontend/src/pages/Register.tsx" = "User registration"
        }
        "Frontend Hooks & Utils" = @{
            "frontend/src/hooks/useAuth.tsx" = "Authentication hook"
            "frontend/src/hooks/useAccessibility.tsx" = "Accessibility preferences hook"
            "frontend/src/hooks/useGameProgress.tsx" = "Game progress tracking"
            "frontend/src/contexts/AccessibilityContext.tsx" = "Accessibility context"
            "frontend/src/contexts/AuthContext.tsx" = "Authentication context"
            "frontend/src/utils/api.ts" = "API client utilities"
            "frontend/src/utils/accessibility.ts" = "Accessibility helpers"
            "frontend/src/utils/gameLogic.ts" = "Game logic utilities"
            "frontend/src/types/index.ts" = "TypeScript type definitions"
        }
        "Backend Architecture" = @{
            "backend/package.json" = "Backend dependencies"
            "backend/tsconfig.json" = "Backend TypeScript config"
            "backend/src/server.ts" = "Express server entry point"
            "backend/src/app.ts" = "Express application setup"
            "backend/src/config/database.ts" = "Database configuration"
            "backend/src/config/auth.ts" = "Authentication configuration"
        }
        "Backend Routes" = @{
            "backend/src/routes/auth.ts" = "Authentication routes"
            "backend/src/routes/users.ts" = "User management routes"
            "backend/src/routes/games.ts" = "Game-related routes"
            "backend/src/routes/progress.ts" = "Progress tracking routes"
            "backend/src/routes/accessibility.ts" = "Accessibility settings routes"
        }
        "Backend Controllers" = @{
            "backend/src/controllers/AuthController.ts" = "Authentication logic"
            "backend/src/controllers/UserController.ts" = "User management logic"
            "backend/src/controllers/GameController.ts" = "Game management logic"
            "backend/src/controllers/ProgressController.ts" = "Progress tracking logic"
            "backend/src/controllers/AccessibilityController.ts" = "Accessibility settings logic"
        }
        "Backend Services" = @{
            "backend/src/services/AuthService.ts" = "Authentication business logic"
            "backend/src/services/UserService.ts" = "User business logic"
            "backend/src/services/GameService.ts" = "Game business logic"
            "backend/src/services/ProgressService.ts" = "Progress tracking logic"
            "backend/src/services/EmailService.ts" = "Email notifications"
            "backend/src/services/AccessibilityService.ts" = "Accessibility services"
        }
        "Backend Models" = @{
            "backend/src/models/User.ts" = "User data model"
            "backend/src/models/Game.ts" = "Game data model"
            "backend/src/models/Progress.ts" = "Progress tracking model"
            "backend/src/models/AccessibilitySettings.ts" = "Accessibility preferences model"
            "backend/src/models/Session.ts" = "User session model"
        }
        "Backend Middleware" = @{
            "backend/src/middleware/auth.ts" = "Authentication middleware"
            "backend/src/middleware/accessibility.ts" = "Accessibility middleware"
            "backend/src/middleware/validation.ts" = "Input validation middleware"
            "backend/src/middleware/errorHandler.ts" = "Error handling middleware"
            "backend/src/middleware/rateLimit.ts" = "Rate limiting middleware"
        }
        "Backend Utils" = @{
            "backend/src/utils/validation.ts" = "Validation utilities"
            "backend/src/utils/accessibility.ts" = "Accessibility utilities"
            "backend/src/utils/encryption.ts" = "Encryption utilities"
            "backend/src/utils/logger.ts" = "Logging utilities"
            "backend/src/types/index.ts" = "Backend type definitions"
        }
        "Database Schema" = @{
            "database/schemas/users.sql" = "User table schema"
            "database/schemas/games.sql" = "Games table schema"
            "database/schemas/progress.sql" = "Progress tracking schema"
            "database/schemas/accessibility_settings.sql" = "Accessibility preferences schema"
            "database/schemas/sessions.sql" = "User sessions schema"
        }
        "Database Migrations" = @{
            "database/migrations/001_initial_setup.sql" = "Initial database setup"
            "database/migrations/002_add_accessibility.sql" = "Accessibility features"
            "database/migrations/003_add_games.sql" = "Game system setup"
            "database/migrations/004_add_progress_tracking.sql" = "Progress tracking"
        }
        "Database Seeds" = @{
            "database/seeds/sample-users.sql" = "Sample user data"
            "database/seeds/sample-games.sql" = "Sample game data"
            "database/seeds/accessibility-presets.sql" = "Accessibility presets"
        }
        "Configuration" = @{
            "config/development.env" = "Development environment variables"
            "config/production.env" = "Production environment variables"
            "config/test.env" = "Test environment variables"
            "config/docker.env" = "Docker environment variables"
        }
        "Documentation" = @{
            "docs/README.md" = "Main documentation"
            "docs/SETUP.md" = "Setup instructions"
            "docs/ACCESSIBILITY.md" = "Accessibility guidelines"
            "docs/GAMES.md" = "Game development guide"
            "docs/api/README.md" = "API documentation"
            "docs/api/auth.md" = "Authentication API"
            "docs/api/games.md" = "Games API"
            "docs/api/users.md" = "Users API"
            "docs/deployment/README.md" = "Deployment guide"
            "docs/deployment/docker.md" = "Docker deployment"
            "docs/deployment/production.md" = "Production deployment"
        }
        "Testing" = @{
            "frontend/src/__tests__/components/Button.test.tsx" = "Button component tests"
            "frontend/src/__tests__/hooks/useAuth.test.tsx" = "Auth hook tests"
            "frontend/src/__tests__/utils/accessibility.test.ts" = "Accessibility utils tests"
            "backend/src/__tests__/controllers/AuthController.test.ts" = "Auth controller tests"
            "backend/src/__tests__/services/UserService.test.ts" = "User service tests"
            "backend/src/__tests__/middleware/auth.test.ts" = "Auth middleware tests"
        }
    }
    
    # Analiza obecnych plików
    $CurrentFiles = @{}
    $MissingFiles = @{}
    $TotalFiles = 0
    $ExistingFiles = 0
    
    foreach ($Category in $ExpectedArchitecture.Keys) {
        Write-Host "📁 $Category" -ForegroundColor $Magenta
        
        $CategoryFiles = $ExpectedArchitecture[$Category]
        $CategoryExisting = 0
        $CategoryMissing = @{}
        
        foreach ($File in $CategoryFiles.Keys) {
            $TotalFiles++
            $Description = $CategoryFiles[$File]
            
            if (Test-Path $File) {
                $ExistingFiles++
                $CategoryExisting++
                $CurrentFiles[$File] = $Description
                
                if ($DetailedAnalysis) {
                    Write-Host "   ✅ $File" -ForegroundColor $Green
                }
            } else {
                $CategoryMissing[$File] = $Description
                Write-Host "   ❌ $File - $Description" -ForegroundColor $Red
            }
        }
        
        if ($CategoryMissing.Count -gt 0) {
            $MissingFiles[$Category] = $CategoryMissing
        }
        
        $CategoryTotal = $CategoryFiles.Count
        $CategoryPercent = [math]::Round(($CategoryExisting / $CategoryTotal) * 100, 1)
        
        Write-Host "   📊 $CategoryExisting/$CategoryTotal plików ($CategoryPercent%)" -ForegroundColor $(
            if ($CategoryPercent -eq 100) { $Green }
            elseif ($CategoryPercent -ge 70) { $Yellow }
            else { $Red }
        )
        Write-Host ""
    }
    
    # ANALIZA 2: ZALEŻNOŚCI MIĘDZY MODUŁAMI
    Write-Host "🔗 ANALIZA 2: ZALEŻNOŚCI MIĘDZY MODUŁAMI" -ForegroundColor $Cyan
    Write-Host ""
    
    $ModuleDependencies = @{
        "Authentication System" = @{
            "Frontend" = @("AuthContext", "useAuth hook", "Login/Register pages", "API client")
            "Backend" = @("AuthController", "AuthService", "JWT middleware", "User model")
            "Database" = @("users table", "sessions table")
            "Priority" = "CRITICAL"
        }
        "Accessibility Framework" = @{
            "Frontend" = @("AccessibilityContext", "AccessibilityToolbar", "useAccessibility hook")
            "Backend" = @("AccessibilityController", "AccessibilityService", "Settings model")
            "Database" = @("accessibility_settings table")
            "Priority" = "HIGH"
        }
        "Game Engine" = @{
            "Frontend" = @("Game components", "Game logic utils", "Progress tracking")
            "Backend" = @("GameController", "GameService", "Progress tracking")
            "Database" = @("games table", "progress table")
            "Priority" = "HIGH"
        }
        "User Management" = @{
            "Frontend" = @("Profile page", "Dashboard", "Settings")
            "Backend" = @("UserController", "UserService", "User model")
            "Database" = @("users table", "user preferences")
            "Priority" = "MEDIUM"
        }
        "Parent Dashboard" = @{
            "Frontend" = @("ParentDashboard page", "Progress visualization")
            "Backend" = @("Progress API", "Analytics service")
            "Database" = @("progress table", "analytics views")
            "Priority" = "MEDIUM"
        }
        "API Infrastructure" = @{
            "Frontend" = @("API client", "Error handling", "Loading states")
            "Backend" = @("Express setup", "Middleware", "Error handling")
            "Database" = @("Connection pooling", "Migrations")
            "Priority" = "CRITICAL"
        }
    }
    
    foreach ($System in $ModuleDependencies.Keys) {
        $Dependencies = $ModuleDependencies[$System]
        $Priority = $Dependencies["Priority"]
        
        $PriorityColor = switch ($Priority) {
            "CRITICAL" { $Red }
            "HIGH" { $Yellow }
            "MEDIUM" { $Cyan }
            default { $Green }
        }
        
        Write-Host "🔧 $System [$Priority]" -ForegroundColor $PriorityColor
        
        foreach ($Layer in @("Frontend", "Backend", "Database")) {
            if ($Dependencies.ContainsKey($Layer)) {
                Write-Host "   📱 $Layer" -ForegroundColor $Cyan
                foreach ($Component in $Dependencies[$Layer]) {
                    Write-Host "      • $Component" -ForegroundColor $Yellow
                }
            }
        }
        Write-Host ""
    }
    
    # ANALIZA 3: PRIORYTETYZACJA MISSING FEATURES
    Write-Host "🎯 ANALIZA 3: PRIORYTETYZACJA MISSING FEATURES" -ForegroundColor $Cyan
    Write-Host ""
    
    $FeaturePriorities = @{
        "P0 - CRITICAL (Blokuje uruchomienie)" = @(
            "backend/src/app.ts - Express application setup",
            "backend/src/config/database.ts - Database configuration",
            "frontend/src/App.tsx - Main React component",
            "frontend/src/main.tsx - React entry point",
            "database/schemas/users.sql - User table schema"
        )
        "P1 - HIGH (Podstawowa funkcjonalność)" = @(
            "Authentication system (login/register)",
            "Basic user management",
            "Database migrations setup",
            "API routing infrastructure",
            "Accessibility framework foundation"
        )
        "P2 - MEDIUM (Główne features)" = @(
            "Game components (GalacticCode, StarlightMath, etc.)",
            "Progress tracking system",
            "Parent dashboard",
            "User settings and preferences",
            "Email notifications"
        )
        "P3 - LOW (Enhancements)" = @(
            "Advanced accessibility features",
            "Game analytics and insights",
            "Social features",
            "Advanced UI components",
            "Performance optimizations"
        )
    }
    
    foreach ($Priority in $FeaturePriorities.Keys) {
        $Color = switch ($Priority.Split(' ')[0]) {
            "P0" { $Red }
            "P1" { $Yellow }
            "P2" { $Cyan }
            "P3" { $Green }
        }
        
        Write-Host "$Priority" -ForegroundColor $Color
        foreach ($Feature in $FeaturePriorities[$Priority]) {
            Write-Host "   • $Feature" -ForegroundColor $Yellow
        }
        Write-Host ""
    }
    
    # ANALIZA 4: PLAN IMPLEMENTACJI
    Write-Host "📋 ANALIZA 4: PLAN IMPLEMENTACJI W KOLEJNOŚCI" -ForegroundColor $Cyan
    Write-Host ""
    
    $ImplementationPlan = @{
        "FAZA 1: Podstawowa Infrastruktura (1-2 dni)" = @(
            "1. Naprawa backend/src/app.ts i server.ts",
            "2. Konfiguracja bazy danych (database.ts)",
            "3. Podstawowe modele (User.ts)",
            "4. Podstawowe middleware (auth.ts, errorHandler.ts)",
            "5. Frontend App.tsx i main.tsx"
        )
        "FAZA 2: System Autentykacji (2-3 dni)" = @(
            "1. AuthController i AuthService",
            "2. JWT middleware i session management",
            "3. Frontend AuthContext i useAuth hook",
            "4. Login/Register komponenty",
            "5. Schemat users table i migracje"
        )
        "FAZA 3: Podstawowe UI i Routing (2-3 dni)" = @(
            "1. Layout komponenty (Header, Navigation, Footer)",
            "2. Podstawowe strony (Home, Dashboard, Profile)",
            "3. UI komponenty (Button, Modal, LoadingSpinner)",
            "4. React Router setup",
            "5. Podstawowe style i Tailwind config"
        )
        "FAZA 4: Framework Accessibility (3-4 dni)" = @(
            "1. AccessibilityContext i useAccessibility hook",
            "2. AccessibilityToolbar komponent",
            "3. Backend AccessibilityController i Service",
            "4. Accessibility settings model i schemat",
            "5. Podstawowe accessibility features"
        )
        "FAZA 5: System Gier (5-7 dni)" = @(
            "1. Game modele i schematy bazy danych",
            "2. GameController i GameService",
            "3. Podstawowe komponenty gier",
            "4. Game logic utilities",
            "5. Progress tracking system"
        )
        "FAZA 6: Parent Dashboard (3-4 dni)" = @(
            "1. Progress tracking backend",
            "2. Analytics i reporting",
            "3. ParentDashboard frontend",
            "4. Progress visualization",
            "5. Email notifications"
        )
        "FAZA 7: Zaawansowane Features (5-10 dni)" = @(
            "1. Zaawansowane accessibility features",
            "2. Game analytics i insights",
            "3. Social features",
            "4. Performance optimizations",
            "5. Testing i dokumentacja"
        )
    }
    
    foreach ($Phase in $ImplementationPlan.Keys) {
        Write-Host "$Phase" -ForegroundColor $Magenta
        foreach ($Task in $ImplementationPlan[$Phase]) {
            Write-Host "   $Task" -ForegroundColor $Yellow
        }
        Write-Host ""
    }
    
    # PODSUMOWANIE
    Write-Host "📊 PODSUMOWANIE ANALIZY" -ForegroundColor $Cyan
    Write-Host "======================" -ForegroundColor $Cyan
    
    $CompletionPercent = [math]::Round(($ExistingFiles / $TotalFiles) * 100, 1)
    $MissingCount = $TotalFiles - $ExistingFiles
    
    Write-Host "📈 Kompletność projektu: $ExistingFiles/$TotalFiles ($CompletionPercent%)" -ForegroundColor $(
        if ($CompletionPercent -ge 80) { $Green }
        elseif ($CompletionPercent -ge 50) { $Yellow }
        else { $Red }
    )
    
    Write-Host "❌ Brakujące komponenty: $MissingCount" -ForegroundColor $Red
    Write-Host "🎯 Szacowany czas implementacji: 20-35 dni roboczych" -ForegroundColor $Yellow
    Write-Host "👥 Zalecany zespół: 2-3 developerów" -ForegroundColor $Yellow
    
    Write-Host ""
    Write-Host "🚀 NASTĘPNE KROKI:" -ForegroundColor $Cyan
    Write-Host "1. Rozpocznij od FAZY 1 (Podstawowa Infrastruktura)" -ForegroundColor $Yellow
    Write-Host "2. Użyj Create-Full-Project-Setup.ps1 do wygenerowania brakujących plików" -ForegroundColor $Yellow
    Write-Host "3. Skup się na komponentach P0 i P1" -ForegroundColor $Yellow
    Write-Host "4. Testuj każdą fazę przed przejściem do następnej" -ForegroundColor $Yellow
    
    # Generowanie raportu
    if ($GenerateReport) {
        Write-Host ""
        Write-Host "📄 GENEROWANIE RAPORTU..." -ForegroundColor $Cyan
        
        $ReportContent = @"
# RAPORT ANALIZY ARCHITEKTURY INFINICORECIPHER
Wygenerowano: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Projekt: $ProjectPath

## PODSUMOWANIE WYKONAWCZE
- **Kompletność**: $CompletionPercent% ($ExistingFiles/$TotalFiles plików)
- **Brakujące komponenty**: $MissingCount
- **Szacowany czas implementacji**: 20-35 dni roboczych
- **Zalecany zespół**: 2-3 developerów

## STAN OBECNY PROJEKTU
### Istniejące komponenty:
$($CurrentFiles.Keys | ForEach-Object { "- $_" } | Out-String)

### Brakujące komponenty według kategorii:
$($MissingFiles.Keys | ForEach-Object { 
    $Category = $_
    "#### $Category`n" + ($MissingFiles[$Category].Keys | ForEach-Object { "- $_ - $($MissingFiles[$Category][$_])" } | Out-String)
} | Out-String)

## PLAN IMPLEMENTACJI
$($ImplementationPlan.Keys | ForEach-Object {
    $Phase = $_
    "### $Phase`n" + ($ImplementationPlan[$Phase] | ForEach-Object { "$_" } | Out-String) + "`n"
} | Out-String)

## ZALEŻNOŚCI MIĘDZY MODUŁAMI
$($ModuleDependencies.Keys | ForEach-Object {
    $System = $_
    $Deps = $ModuleDependencies[$System]
    "### $System [Priorytet: $($Deps['Priority'])]`n" +
    (@("Frontend", "Backend", "Database") | Where-Object { $Deps.ContainsKey($_) } | ForEach-Object {
        $Layer = $_
        "**${Layer}:**`n" + ($Deps[$Layer] | ForEach-Object { "- $_" } | Out-String)
    } | Out-String) + "`n"
} | Out-String)

## REKOMENDACJE
1. **Rozpocznij od FAZY 1** - Podstawowa infrastruktura jest kluczowa
2. **Użyj automatyzacji** - Create-Full-Project-Setup.ps1 wygeneruje szkielety plików
3. **Priorytetyzuj P0 i P1** - Skupienie na krytycznych komponentach
4. **Testuj iteracyjnie** - Każda faza powinna być przetestowana przed kolejną
5. **Dokumentuj postęp** - Aktualizuj dokumentację wraz z implementacją

## NASTĘPNE KROKI
1. Uruchom Create-Full-Project-Setup.ps1 dla wygenerowania szkieletów
2. Rozpocznij implementację od backend/src/app.ts
3. Skonfiguruj bazę danych i podstawowe modele
4. Zaimplementuj system autentykacji
5. Dodaj podstawowe UI komponenty

---
*Raport wygenerowany automatycznie przez Analyze-InfiniCoreCipher-Architecture.ps1*
"@
        
        $ReportFile = "ARCHITECTURE-ANALYSIS-REPORT.md"
        $ReportContent | Out-File -FilePath $ReportFile -Encoding UTF8
        Write-Host "✅ Raport zapisany: $ReportFile" -ForegroundColor $Green
    }
    
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "=== KONIEC ANALIZY ARCHITEKTURY ===" -ForegroundColor $Cyan