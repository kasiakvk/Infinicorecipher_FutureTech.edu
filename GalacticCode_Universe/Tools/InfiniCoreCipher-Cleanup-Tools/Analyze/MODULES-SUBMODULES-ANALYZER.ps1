# 📦 MODULES & SUBMODULES ANALYZER
# Analiza modułów i submodułów po usunięciu GalacticCode_Repozitorium

Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║            📦 MODULES & SUBMODULES ANALYZER                      ║" -ForegroundColor Cyan
Write-Host "║         Post GalacticCode Deletion Module Analysis               ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Definicje repozytoriów do sprawdzenia
$RepositoriesToAnalyze = @{
    "Current-Workspace" = @{
        "Path" = "/workspace"
        "Type" = "Development"
        "Description" = "Active development repository"
    }
    "Production-Main" = @{
        "Path" = "C:\InfiniCoreCipher-Startup\Infinicorecipher_Repositorium"
        "Type" = "Production"
        "Description" = "Main production repository"
    }
    "Production-Alt" = @{
        "Path" = "C:\InfiniCoreCipher-Startup\Infinicorecipher"
        "Type" = "Production-Alternative"
        "Description" = "Alternative production location"
    }
    "GalacticCode-Standalone" = @{
        "Path" = "C:\InfiniCoreCipher-Startup\GalacticCode_Repository"
        "Type" = "Universe"
        "Description" = "Standalone GalacticCode repository"
    }
}

# Funkcja analizy modułów i submodułów
function Analyze-RepositoryModules {
    param(
        [string]$Name,
        [hashtable]$RepoInfo
    )
    
    Write-Host "`n🔍 Analiza modułów: $Name" -ForegroundColor Cyan
    Write-Host "📁 Ścieżka: $($RepoInfo.Path)" -ForegroundColor White
    Write-Host "🎯 Typ: $($RepoInfo.Type)" -ForegroundColor White
    
    $result = @{
        Name = $Name
        Path = $RepoInfo.Path
        Type = $RepoInfo.Type
        Exists = $false
        IsGitRepo = $false
        HasSubmodules = $false
        SubmoduleCount = 0
        SubmodulesList = @()
        GitmodulesExists = $false
        GitmodulesContent = ""
        ModuleStructure = @{}
        PowerShellModules = @()
        PythonModules = @()
        NodeModules = @()
        Issues = @()
        Recommendations = @()
    }
    
    # Sprawdź czy ścieżka istnieje
    if (Test-Path $RepoInfo.Path) {
        $result.Exists = $true
        Write-Host "  ✅ Ścieżka istnieje" -ForegroundColor Green
        
        # Sprawdź czy to repozytorium Git
        $gitPath = Join-Path $RepoInfo.Path ".git"
        if (Test-Path $gitPath) {
            $result.IsGitRepo = $true
            Write-Host "  ✅ To repozytorium Git" -ForegroundColor Green
            
            Push-Location $RepoInfo.Path
            try {
                # Sprawdź submoduły Git
                Write-Host "  🔍 Sprawdzanie submodułów Git..." -ForegroundColor White
                
                $submoduleStatus = git submodule status 2>$null
                if ($submoduleStatus) {
                    $result.HasSubmodules = $true
                    $result.SubmodulesList = $submoduleStatus
                    $result.SubmoduleCount = $submoduleStatus.Count
                    Write-Host "  📦 Znaleziono $($result.SubmoduleCount) submodułów" -ForegroundColor Green
                    
                    foreach ($submodule in $submoduleStatus) {
                        Write-Host "    - $submodule" -ForegroundColor Gray
                    }
                } else {
                    Write-Host "  ✅ Brak submodułów Git" -ForegroundColor Green
                }
                
                # Sprawdź plik .gitmodules
                $gitmodulesPath = Join-Path $RepoInfo.Path ".gitmodules"
                if (Test-Path $gitmodulesPath) {
                    $result.GitmodulesExists = $true
                    $result.GitmodulesContent = Get-Content $gitmodulesPath -Raw
                    Write-Host "  📄 Plik .gitmodules istnieje" -ForegroundColor Yellow
                    
                    # Sprawdź czy submoduły w .gitmodules są aktualne
                    $gitmodulesLines = Get-Content $gitmodulesPath
                    $definedSubmodules = @()
                    
                    foreach ($line in $gitmodulesLines) {
                        if ($line -match '^\[submodule "(.+)"\]') {
                            $definedSubmodules += $matches[1]
                        }
                    }
                    
                    if ($definedSubmodules.Count -gt 0) {
                        Write-Host "  📋 Submoduły zdefiniowane w .gitmodules:" -ForegroundColor White
                        foreach ($submod in $definedSubmodules) {
                            Write-Host "    - $submod" -ForegroundColor Gray
                            
                            # Sprawdź czy submoduł faktycznie istnieje
                            $submodPath = Join-Path $RepoInfo.Path $submod
                            if (-not (Test-Path $submodPath)) {
                                Write-Host "      ❌ Brak folderu submodułu" -ForegroundColor Red
                                $result.Issues += "Missing submodule folder: $submod"
                                $result.Recommendations += "Initialize submodule: git submodule update --init $submod"
                            }
                        }
                    }
                    
                    # Sprawdź czy są odwołania do GalacticCode
                    if ($result.GitmodulesContent -like "*GalacticCode*") {
                        Write-Host "  ⚠️ Znaleziono odwołania do GalacticCode w .gitmodules" -ForegroundColor Yellow
                        $result.Issues += "GalacticCode references in .gitmodules"
                        $result.Recommendations += "Review and update GalacticCode references in .gitmodules"
                    }
                }
                
            } catch {
                Write-Host "  ❌ Błąd analizy Git: $_" -ForegroundColor Red
                $result.Issues += "Git analysis error: $_"
            } finally {
                Pop-Location
            }
            
            # Sprawdź strukturę modułów w folderach
            Write-Host "  🔍 Sprawdzanie struktury modułów..." -ForegroundColor White
            
            try {
                # PowerShell moduły (.psm1, .psd1)
                $psModules = Get-ChildItem $RepoInfo.Path -Recurse -Include "*.psm1", "*.psd1" -ErrorAction SilentlyContinue
                if ($psModules) {
                    $result.PowerShellModules = $psModules.FullName
                    Write-Host "  🔷 PowerShell moduły: $($psModules.Count)" -ForegroundColor Blue
                    foreach ($module in $psModules) {
                        $relativePath = $module.FullName.Replace($RepoInfo.Path, "").TrimStart('\', '/')
                        Write-Host "    - $relativePath" -ForegroundColor Gray
                    }
                }
                
                # Python moduły (__init__.py, setup.py, requirements.txt)
                $pyFiles = Get-ChildItem $RepoInfo.Path -Recurse -Include "__init__.py", "setup.py", "requirements.txt", "pyproject.toml" -ErrorAction SilentlyContinue
                if ($pyFiles) {
                    $result.PythonModules = $pyFiles.FullName
                    Write-Host "  🐍 Python moduły/pliki: $($pyFiles.Count)" -ForegroundColor Green
                    foreach ($file in $pyFiles) {
                        $relativePath = $file.FullName.Replace($RepoInfo.Path, "").TrimStart('\', '/')
                        Write-Host "    - $relativePath" -ForegroundColor Gray
                    }
                }
                
                # Node.js moduły (package.json, node_modules)
                $nodeFiles = Get-ChildItem $RepoInfo.Path -Recurse -Include "package.json", "package-lock.json" -ErrorAction SilentlyContinue
                $nodeModulesDir = Get-ChildItem $RepoInfo.Path -Recurse -Directory -Name "node_modules" -ErrorAction SilentlyContinue
                
                if ($nodeFiles -or $nodeModulesDir) {
                    $result.NodeModules = $nodeFiles.FullName
                    Write-Host "  📦 Node.js moduły/pliki: $($nodeFiles.Count)" -ForegroundColor Yellow
                    foreach ($file in $nodeFiles) {
                        $relativePath = $file.FullName.Replace($RepoInfo.Path, "").TrimStart('\', '/')
                        Write-Host "    - $relativePath" -ForegroundColor Gray
                    }
                    
                    if ($nodeModulesDir) {
                        Write-Host "  📁 Foldery node_modules: $($nodeModulesDir.Count)" -ForegroundColor Yellow
                    }
                }
                
                # Sprawdź czy są odwołania do GalacticCode w plikach
                Write-Host "  🔍 Sprawdzanie odwołań do GalacticCode..." -ForegroundColor White
                
                $galacticReferences = @()
                $searchPatterns = @("*GalacticCode*", "*galacticcode*", "*GALACTICCODE*")
                
                foreach ($pattern in $searchPatterns) {
                    $files = Get-ChildItem $RepoInfo.Path -Recurse -File -Include "*.ps1", "*.md", "*.txt", "*.json", "*.yml", "*.yaml" -ErrorAction SilentlyContinue
                    foreach ($file in $files) {
                        try {
                            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
                            if ($content -and $content -like $pattern) {
                                $relativePath = $file.FullName.Replace($RepoInfo.Path, "").TrimStart('\', '/')
                                $galacticReferences += $relativePath
                            }
                        } catch {
                            # Ignoruj błędy odczytu plików
                        }
                    }
                }
                
                if ($galacticReferences.Count -gt 0) {
                    Write-Host "  ⚠️ Znaleziono $($galacticReferences.Count) plików z odwołaniami do GalacticCode" -ForegroundColor Yellow
                    $result.Issues += "Files with GalacticCode references found"
                    $result.Recommendations += "Review and update GalacticCode references in files"
                    
                    foreach ($ref in $galacticReferences | Select-Object -First 5) {
                        Write-Host "    - $ref" -ForegroundColor Gray
                    }
                    
                    if ($galacticReferences.Count -gt 5) {
                        Write-Host "    ... i $($galacticReferences.Count - 5) więcej" -ForegroundColor Gray
                    }
                }
                
            } catch {
                Write-Host "  ⚠️ Błąd sprawdzania struktury: $_" -ForegroundColor Yellow
                $result.Issues += "Structure analysis error: $_"
            }
            
        } else {
            Write-Host "  ❌ Nie jest repozytorium Git" -ForegroundColor Red
            $result.Issues += "Not a Git repository"
        }
    } else {
        Write-Host "  ❌ Ścieżka nie istnieje" -ForegroundColor Red
        $result.Issues += "Path does not exist"
    }
    
    return $result
}

# Sprawdź wszystkie repozytoria
Write-Host "`n📊 ANALIZA MODUŁÓW WE WSZYSTKICH REPOZYTORIACH..." -ForegroundColor Green

$moduleResults = @{}

foreach ($repo in $RepositoriesToAnalyze.GetEnumerator()) {
    $moduleResults[$repo.Key] = Analyze-RepositoryModules -Name $repo.Key -RepoInfo $repo.Value
}

# Analiza wyników
Write-Host "`n" + "="*80 -ForegroundColor Cyan
Write-Host "📊 PODSUMOWANIE ANALIZY MODUŁÓW" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan

$totalSubmodules = 0
$totalGalacticReferences = 0
$repositoriesWithIssues = 0

foreach ($result in $moduleResults.Values) {
    Write-Host "`n🏢 $($result.Name) [$($result.Type)]" -ForegroundColor Yellow
    
    if ($result.Exists) {
        Write-Host "  📁 Status: DOSTĘPNY" -ForegroundColor Green
        
        if ($result.IsGitRepo) {
            Write-Host "  📦 Submoduły Git: $($result.SubmoduleCount)" -ForegroundColor White
            Write-Host "  🔷 PowerShell moduły: $($result.PowerShellModules.Count)" -ForegroundColor Blue
            Write-Host "  🐍 Python moduły: $($result.PythonModules.Count)" -ForegroundColor Green
            Write-Host "  📦 Node.js moduły: $($result.NodeModules.Count)" -ForegroundColor Yellow
            Write-Host "  📄 .gitmodules: $(if($result.GitmodulesExists){'TAK'}else{'NIE'})" -ForegroundColor White
            
            $totalSubmodules += $result.SubmoduleCount
        }
        
        if ($result.Issues.Count -gt 0) {
            $repositoriesWithIssues++
            Write-Host "  ⚠️ Problemy:" -ForegroundColor Red
            foreach ($issue in $result.Issues) {
                Write-Host "    - $issue" -ForegroundColor Gray
                if ($issue -like "*GalacticCode*") {
                    $totalGalacticReferences++
                }
            }
        } else {
            Write-Host "  ✅ Brak problemów z modułami" -ForegroundColor Green
        }
    } else {
        Write-Host "  ❌ Status: NIEDOSTĘPNY" -ForegroundColor Red
    }
}

# Analiza wpływu usunięcia GalacticCode
Write-Host "`n🌌 ANALIZA WPŁYWU USUNIĘCIA GALACTICCODE NA MODUŁY:" -ForegroundColor Magenta

if ($totalGalacticReferences -gt 0) {
    Write-Host "⚠️ ZNALEZIONO ODWOŁANIA DO GALACTICCODE" -ForegroundColor Yellow
    Write-Host "  📊 Repozytoria z problemami: $repositoriesWithIssues" -ForegroundColor White
    Write-Host "  🔗 Łączne odwołania: $totalGalacticReferences" -ForegroundColor White
    
    Write-Host "`n🎯 WYMAGANE DZIAŁANIA:" -ForegroundColor Cyan
    Write-Host "  1. Przejrzyj pliki .gitmodules" -ForegroundColor White
    Write-Host "  2. Zaktualizuj odwołania w kodzie" -ForegroundColor White
    Write-Host "  3. Usuń nieaktywne submoduły" -ForegroundColor White
    Write-Host "  4. Przetestuj funkcjonalność" -ForegroundColor White
} else {
    Write-Host "✅ BRAK PROBLEMÓW Z ODWOŁANIAMI DO GALACTICCODE" -ForegroundColor Green
    Write-Host "  📊 Wszystkie moduły wydają się nienaruszone" -ForegroundColor White
}

# Sprawdź integralność głównych repozytoriów
Write-Host "`n🔍 SPRAWDZENIE INTEGRALNOŚCI MODUŁÓW:" -ForegroundColor Cyan

$workspaceResult = $moduleResults["Current-Workspace"]
if ($workspaceResult.Exists -and $workspaceResult.IsGitRepo) {
    Write-Host "✅ Development Repository - moduły dostępne" -ForegroundColor Green
    Write-Host "  🔷 PowerShell: $($workspaceResult.PowerShellModules.Count)" -ForegroundColor Blue
} else {
    Write-Host "⚠️ Development Repository - problemy z dostępem" -ForegroundColor Yellow
}

# Generuj rekomendacje naprawcze
Write-Host "`n🔧 REKOMENDACJE NAPRAWCZE:" -ForegroundColor Yellow

$allRecommendations = @()
foreach ($result in $moduleResults.Values) {
    if ($result.Recommendations.Count -gt 0) {
        Write-Host "`n📋 Dla $($result.Name):" -ForegroundColor Cyan
        foreach ($rec in $result.Recommendations) {
            Write-Host "  - $rec" -ForegroundColor White
            $allRecommendations += "$($result.Name): $rec"
        }
    }
}

if ($allRecommendations.Count -eq 0) {
    Write-Host "✅ Brak wymaganych działań naprawczych" -ForegroundColor Green
}

# Statystyki końcowe
Write-Host "`n📊 STATYSTYKI MODUŁÓW:" -ForegroundColor Green
Write-Host "📦 Łączne submoduły Git: $totalSubmodules" -ForegroundColor White
Write-Host "⚠️ Repozytoria z problemami: $repositoriesWithIssues" -ForegroundColor Yellow
Write-Host "🔗 Odwołania do GalacticCode: $totalGalacticReferences" -ForegroundColor $(if($totalGalacticReferences -gt 0){'Yellow'}else{'Green'})
Write-Host "📁 Sprawdzonych repozytoriów: $($moduleResults.Count)" -ForegroundColor White

# Zapisz raport
$reportPath = "Modules-Submodules-Analysis-Report.json"
try {
    $moduleResults | ConvertTo-Json -Depth 5 | Out-File $reportPath -Encoding UTF8
    Write-Host "`n📄 Raport analizy modułów zapisany: $reportPath" -ForegroundColor Green
} catch {
    Write-Host "`n⚠️ Nie można zapisać raportu: $_" -ForegroundColor Yellow
}

Write-Host "`n🎉 ANALIZA MODUŁÓW I SUBMODUŁÓW ZAKOŃCZONA!" -ForegroundColor Green

pause