<#
.SYNOPSIS
    Automatyczny skrypt konfiguracji GitHub dla projektu InfiniCoreCipher

.DESCRIPTION
    Automatyzuje proces konfiguracji Git, GitHub i struktury repozytorium

.PARAMETER RepoName
    Nazwa repozytorium GitHub

.PARAMETER GitHubUsername
    Nazwa użytkownika GitHub

.PARAMETER ProjectPath
    Ścieżka do projektu lokalnego (domyślnie bieżący katalog)

.EXAMPLE
    .\GitHub-Auto-Setup.ps1 -RepoName "InfiniCoreCipher" -GitHubUsername "kasiakvk"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoName,
    
    [Parameter(Mandatory=$true)]
    [string]$GitHubUsername,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = (Get-Location).Path,
    
    [Parameter(Mandatory=$false)]
    [string]$UserEmail = "",
    
    [Parameter(Mandatory=$false)]
    [string]$UserName = ""
)

# Kolory
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Blue = "Blue"

function Write-SetupStatus {
    param(
        [string]$Message,
        [string]$Status = "INFO",
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Status] $Message" -ForegroundColor $Color
}

function Test-GitInstallation {
    try {
        $gitVersion = git --version 2>$null
        if ($gitVersion) {
            Write-SetupStatus "✅ Git jest zainstalowany: $gitVersion" "OK" $Green
            return $true
        }
    } catch {
        Write-SetupStatus "❌ Git nie jest zainstalowany" "ERROR" $Red
        Write-SetupStatus "Zainstaluj Git z: https://git-scm.com/download/win" "INFO" $Yellow
        return $false
    }
}

function Initialize-GitConfig {
    param($UserName, $UserEmail)
    
    Write-SetupStatus "⚙️ Konfiguracja Git..." "INFO" $Yellow
    
    if (-not $UserName) {
        $UserName = Read-Host "Podaj swoje imię i nazwisko dla Git"
    }
    
    if (-not $UserEmail) {
        $UserEmail = Read-Host "Podaj swój email dla Git"
    }
    
    try {
        git config --global user.name "$UserName"
        git config --global user.email "$UserEmail"
        git config --global init.defaultBranch main
        git config --global core.autocrlf true
        
        Write-SetupStatus "✅ Konfiguracja Git zakończona" "OK" $Green
        Write-SetupStatus "   Użytkownik: $UserName" "INFO" $Blue
        Write-SetupStatus "   Email: $UserEmail" "INFO" $Blue
        
        return $true
    } catch {
        Write-SetupStatus "❌ Błąd konfiguracji Git: $($_.Exception.Message)" "ERROR" $Red
        return $false
    }
}

function Test-GitHubConnection {
    param($GitHubUsername)
    
    Write-SetupStatus "🔗 Testowanie połączenia z GitHub..." "INFO" $Yellow
    
    try {
        # Test połączenia przez HTTPS
        $response = Invoke-WebRequest -Uri "https://api.github.com/users/$GitHubUsername" -TimeoutSec 10 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $userData = $response.Content | ConvertFrom-Json
            Write-SetupStatus "✅ Użytkownik GitHub znaleziony: $($userData.name)" "OK" $Green
            return $true
        }
    } catch {
        Write-SetupStatus "❌ Nie można połączyć się z GitHub dla użytkownika: $GitHubUsername" "ERROR" $Red
        Write-SetupStatus "Sprawdź nazwę użytkownika i połączenie internetowe" "INFO" $Yellow
        return $false
    }
}

function Create-ProjectStructure {
    param($ProjectPath)
    
    Write-SetupStatus "📁 Tworzenie struktury projektu..." "INFO" $Yellow
    
    $directories = @(
        "frontend/src",
        "frontend/public",
        "backend/routes",
        "backend/middleware",
        "docs",
        "scripts",
        "tests/unit",
        "tests/integration",
        ".github/workflows",
        "assets/images",
        "assets/icons"
    )
    
    foreach ($dir in $directories) {
        $fullPath = Join-Path $ProjectPath $dir
        if (-not (Test-Path $fullPath)) {
            try {
                New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
                Write-SetupStatus "✅ Utworzono: $dir" "OK" $Green
            } catch {
                Write-SetupStatus "❌ Błąd tworzenia: $dir" "ERROR" $Red
            }
        } else {
            Write-SetupStatus "⏭️ Istnieje: $dir" "INFO" $Blue
        }
    }
}

function Create-GitIgnore {
    param($ProjectPath)
    
    $gitignoreContent = @"
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Production builds
/frontend/dist/
/backend/dist/
build/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# Temporary folders
tmp/
temp/

# OneDrive specific
OneDrive-*.csv
OneDrive-*.txt
OneDrive-Backup-*/

# PowerShell scripts output
*.ps1.log

# Backup files
*.bak
*.backup
"@

    $gitignorePath = Join-Path $ProjectPath ".gitignore"
    try {
        $gitignoreContent | Out-File -FilePath $gitignorePath -Encoding UTF8
        Write-SetupStatus "✅ Utworzono .gitignore" "OK" $Green
    } catch {
        Write-SetupStatus "❌ Błąd tworzenia .gitignore: $($_.Exception.Message)" "ERROR" $Red
    }
}

function Create-README {
    param($ProjectPath, $RepoName, $GitHubUsername)
    
    $readmeContent = @"
# 🔐 $RepoName

Advanced Encryption & Security Platform

## 📋 Opis projektu

$RepoName to zaawansowana platforma szyfrowania i bezpieczeństwa, oferująca:

- 🔒 Zaawansowane algorytmy szyfrowania
- 🛡️ Bezpieczne zarządzanie kluczami
- 📊 Analityka bezpieczeństwa w czasie rzeczywistym
- 🌐 Kompatybilność międzyplatformowa

## 🚀 Szybki start

### Wymagania
- Node.js 18+
- npm lub yarn
- Git

### Instalacja
\`\`\`bash
# Sklonuj repozytorium
git clone https://github.com/$GitHubUsername/$RepoName.git

# Przejdź do katalogu
cd $RepoName

# Zainstaluj zależności
npm run install:all

# Uruchom w trybie deweloperskim
npm run dev
\`\`\`

## 📁 Struktura projektu

\`\`\`
$RepoName/
├── frontend/          # React aplikacja
├── backend/           # Express.js API
├── docs/             # Dokumentacja
├── scripts/          # Skrypty automatyzacji
├── tests/            # Testy
└── assets/           # Zasoby statyczne
\`\`\`

## 🛠️ Dostępne skrypty

- \`npm run dev\` - Uruchom frontend i backend
- \`npm run build\` - Zbuduj projekt
- \`npm test\` - Uruchom testy
- \`npm run install:all\` - Zainstaluj wszystkie zależności

## 🌐 Dostęp

- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:5000
- **API**: http://localhost:5000/api
- **Health Check**: http://localhost:5000/health

## 📚 Dokumentacja

Szczegółowa dokumentacja dostępna w folderze [docs/](./docs/)

## 🤝 Współpraca

1. Fork repozytorium
2. Utwórz branch dla funkcji (\`git checkout -b feature/AmazingFeature\`)
3. Commit zmian (\`git commit -m 'Add some AmazingFeature'\`)
4. Push do branch (\`git push origin feature/AmazingFeature\`)
5. Otwórz Pull Request

## 📄 Licencja

Ten projekt jest licencjonowany na licencji MIT - zobacz plik [LICENSE](LICENSE) dla szczegółów.

## 👨‍💻 Autor

**$GitHubUsername** - [GitHub](https://github.com/$GitHubUsername)

## 🙏 Podziękowania

- Społeczność open source
- Wszystkich kontrybutorów

---

*Wygenerowano automatycznie przez GitHub-Auto-Setup.ps1*
"@

    $readmePath = Join-Path $ProjectPath "README.md"
    try {
        $readmeContent | Out-File -FilePath $readmePath -Encoding UTF8
        Write-SetupStatus "✅ Utworzono README.md" "OK" $Green
    } catch {
        Write-SetupStatus "❌ Błąd tworzenia README.md: $($_.Exception.Message)" "ERROR" $Red
    }
}

function Create-GitHubWorkflow {
    param($ProjectPath)
    
    $workflowContent = @"
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [18.x, 20.x]
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js `${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: `${{ matrix.node-version }}
        cache: 'npm'
        
    - name: Install dependencies
      run: npm run install:all
      
    - name: Run linting
      run: npm run lint --if-present
      
    - name: Run tests
      run: npm test --if-present
      
    - name: Build project
      run: npm run build --if-present
      
    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
      if: matrix.node-version == '18.x'
      
  security:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Run security audit
      run: npm audit --audit-level moderate
      
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: `${{ secrets.SNYK_TOKEN }}
"@

    $workflowPath = Join-Path $ProjectPath ".github/workflows/ci.yml"
    try {
        $workflowContent | Out-File -FilePath $workflowPath -Encoding UTF8
        Write-SetupStatus "✅ Utworzono GitHub Actions workflow" "OK" $Green
    } catch {
        Write-SetupStatus "❌ Błąd tworzenia workflow: $($_.Exception.Message)" "ERROR" $Red
    }
}

function Initialize-GitRepository {
    param($ProjectPath, $RepoName, $GitHubUsername)
    
    Write-SetupStatus "🔧 Inicjalizacja repozytorium Git..." "INFO" $Yellow
    
    try {
        Push-Location $ProjectPath
        
        # Sprawdź czy to już repozytorium Git
        if (Test-Path ".git") {
            Write-SetupStatus "⏭️ Repozytorium Git już istnieje" "INFO" $Blue
        } else {
            git init
            Write-SetupStatus "✅ Zainicjalizowano repozytorium Git" "OK" $Green
        }
        
        # Dodaj remote origin jeśli nie istnieje
        $remotes = git remote 2>$null
        if ($remotes -notcontains "origin") {
            $repoUrl = "https://github.com/$GitHubUsername/$RepoName.git"
            git remote add origin $repoUrl
            Write-SetupStatus "✅ Dodano remote origin: $repoUrl" "OK" $Green
        } else {
            Write-SetupStatus "⏭️ Remote origin już istnieje" "INFO" $Blue
        }
        
        # Sprawdź połączenie
        try {
            git ls-remote origin 2>$null | Out-Null
            Write-SetupStatus "✅ Połączenie z GitHub działa" "OK" $Green
        } catch {
            Write-SetupStatus "⚠️ Nie można połączyć się z GitHub - sprawdź czy repozytorium istnieje" "WARNING" $Yellow
        }
        
    } catch {
        Write-SetupStatus "❌ Błąd inicjalizacji Git: $($_.Exception.Message)" "ERROR" $Red
    } finally {
        Pop-Location
    }
}

function Create-InitialCommit {
    param($ProjectPath)
    
    Write-SetupStatus "📝 Tworzenie pierwszego commit..." "INFO" $Yellow
    
    try {
        Push-Location $ProjectPath
        
        # Dodaj wszystkie pliki
        git add .
        
        # Sprawdź czy są zmiany do commit
        $status = git status --porcelain 2>$null
        if ($status) {
            git commit -m "feat: initial project setup with automated structure

- Add project structure (frontend, backend, docs, tests)
- Add .gitignore with comprehensive rules
- Add README.md with project documentation
- Add GitHub Actions CI/CD workflow
- Configure Git repository with remote origin

Generated by GitHub-Auto-Setup.ps1"
            
            Write-SetupStatus "✅ Utworzono pierwszy commit" "OK" $Green
            
            # Spróbuj wypchnąć na GitHub
            $pushChoice = Read-Host "Czy chcesz wypchnąć zmiany na GitHub? (t/n)"
            if ($pushChoice.ToLower() -eq 't' -or $pushChoice.ToLower() -eq 'tak') {
                try {
                    git push -u origin main
                    Write-SetupStatus "✅ Zmiany wypchnięte na GitHub" "OK" $Green
                } catch {
                    Write-SetupStatus "⚠️ Nie można wypchnąć na GitHub - sprawdź uprawnienia" "WARNING" $Yellow
                    Write-SetupStatus "Możesz wypchnąć później: git push -u origin main" "INFO" $Blue
                }
            }
        } else {
            Write-SetupStatus "⏭️ Brak zmian do commit" "INFO" $Blue
        }
        
    } catch {
        Write-SetupStatus "❌ Błąd tworzenia commit: $($_.Exception.Message)" "ERROR" $Red
    } finally {
        Pop-Location
    }
}

function Show-NextSteps {
    param($RepoName, $GitHubUsername, $ProjectPath)
    
    Write-Host ""
    Write-SetupStatus "🎉 KONFIGURACJA ZAKOŃCZONA!" "OK" $Green
    Write-Host ""
    Write-SetupStatus "📋 NASTĘPNE KROKI:" "INFO" $Cyan
    Write-Host ""
    
    Write-SetupStatus "1. 🌐 Utwórz repozytorium na GitHub:" "INFO" $Yellow
    Write-SetupStatus "   https://github.com/new" "INFO" $Blue
    Write-SetupStatus "   Nazwa: $RepoName" "INFO" $Blue
    Write-SetupStatus "   Typ: Public/Private" "INFO" $Blue
    Write-Host ""
    
    Write-SetupStatus "2. 🔧 Zainstaluj zależności projektu:" "INFO" $Yellow
    Write-SetupStatus "   cd `"$ProjectPath`"" "INFO" $Blue
    Write-SetupStatus "   npm run install:all" "INFO" $Blue
    Write-Host ""
    
    Write-SetupStatus "3. 🚀 Uruchom projekt:" "INFO" $Yellow
    Write-SetupStatus "   npm run dev" "INFO" $Blue
    Write-Host ""
    
    Write-SetupStatus "4. 📤 Wypchnij na GitHub (jeśli nie zrobiono automatycznie):" "INFO" $Yellow
    Write-SetupStatus "   git push -u origin main" "INFO" $Blue
    Write-Host ""
    
    Write-SetupStatus "5. 🔗 Linki:" "INFO" $Yellow
    Write-SetupStatus "   GitHub: https://github.com/$GitHubUsername/$RepoName" "INFO" $Blue
    Write-SetupStatus "   Local: $ProjectPath" "INFO" $Blue
    Write-Host ""
    
    Write-SetupStatus "📚 Przydatne komendy:" "INFO" $Cyan
    Write-SetupStatus "   git status          - sprawdź status" "INFO" $Blue
    Write-SetupStatus "   git add .           - dodaj wszystkie zmiany" "INFO" $Blue
    Write-SetupStatus "   git commit -m `"msg`" - commit z wiadomością" "INFO" $Blue
    Write-SetupStatus "   git push            - wypchnij na GitHub" "INFO" $Blue
    Write-SetupStatus "   git pull            - pobierz zmiany z GitHub" "INFO" $Blue
}

# Główna funkcja
function Start-GitHubSetup {
    Write-Host "=== AUTOMATYCZNA KONFIGURACJA GITHUB ===" -ForegroundColor $Cyan
    Write-Host "Projekt: $RepoName" -ForegroundColor $Blue
    Write-Host "Użytkownik: $GitHubUsername" -ForegroundColor $Blue
    Write-Host "Ścieżka: $ProjectPath" -ForegroundColor $Blue
    Write-Host ""
    
    # Sprawdzenie wymagań
    if (-not (Test-GitInstallation)) {
        return
    }
    
    if (-not (Test-GitHubConnection -GitHubUsername $GitHubUsername)) {
        return
    }
    
    # Konfiguracja Git
    if (-not (Initialize-GitConfig -UserName $UserName -UserEmail $UserEmail)) {
        return
    }
    
    # Tworzenie struktury projektu
    Create-ProjectStructure -ProjectPath $ProjectPath
    Create-GitIgnore -ProjectPath $ProjectPath
    Create-README -ProjectPath $ProjectPath -RepoName $RepoName -GitHubUsername $GitHubUsername
    Create-GitHubWorkflow -ProjectPath $ProjectPath
    
    # Inicjalizacja Git
    Initialize-GitRepository -ProjectPath $ProjectPath -RepoName $RepoName -GitHubUsername $GitHubUsername
    Create-InitialCommit -ProjectPath $ProjectPath
    
    # Podsumowanie
    Show-NextSteps -RepoName $RepoName -GitHubUsername $GitHubUsername -ProjectPath $ProjectPath
}

# Uruchom główną funkcję
Start-GitHubSetup