# 🔍 COMPREHENSIVE REPOSITORY ANALYZER
# Analiza struktury repozytoriów po usunięciu GalacticCode_Repozitorium

Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           🔍 COMPREHENSIVE REPOSITORY ANALYZER                   ║" -ForegroundColor Cyan
Write-Host "║              Post GalacticCode Deletion Analysis                 ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Definicje repozytoriów GitHub
$GitHubRepositories = @{
    "InfiniCoreCipher-Cleanup-Tools" = @{
        "URL" = "https://github.com/Infinicorecipher-FutureTechEdu/InfiniCoreCipher-Cleanup-Tools.git"
        "Type" = "Development"
        "Purpose" = "Active development and testing"
        "ExpectedPaths" = @(
            "C:\InfiniCoreCipher-Startup\InfiniCoreCipher-Cleanup-Tools",
            "/workspace"
        )
    }
    "Infinicorecipher" = @{
        "URL" = "https://github.com/Infinicorecipher-FutureTechEdu/Infinicorecipher.git"
        "Type" = "Production"
        "Purpose" = "Stable Windows deployment"
        "ExpectedPaths" = @(
            "C:\InfiniCoreCipher-Startup\Infinicorecipher_Repositorium",
            "C:\InfiniCoreCipher-Startup\Infinicorecipher"
        )
    }
    "GalacticCode_Repository" = @{
        "URL" = "https://github.com/InfiniCoreCipher/GalacticCode_Repository.git"
        "Type" = "Universe"
        "Purpose" = "GalacticCode Universe project"
        "ExpectedPaths" = @(
            "C:\InfiniCoreCipher-Startup\GalacticCode_Repository",
            "C:\InfiniCoreCipher-Startup\Infinicorecipher_Repositorium\GalacticCode_Repository"
        )
    }
}

# Funkcja sprawdzania repozytorium
function Test-GitRepository {
    param(
        [string]$Name,
        [string]$Path,
        [hashtable]$RepoInfo
    )
    
    Write-Host "`n🔍 Sprawdzanie repozytorium: $Name" -ForegroundColor Cyan
    Write-Host "📁 Ścieżka: $Path" -ForegroundColor White
    Write-Host "🎯 Typ: $($RepoInfo.Type)" -ForegroundColor White
    Write-Host "📋 Cel: $($RepoInfo.Purpose)" -ForegroundColor White
    
    $result = @{
        Name = $Name
        Path = $Path
        Type = $RepoInfo.Type
        Purpose = $RepoInfo.Purpose
        ExpectedURL = $RepoInfo.URL
        Exists = $false
        IsGitRepo = $false
        ActualURL = ""
        Branch = ""
        HEAD = ""
        FileCount = 0
        LastCommit = ""
        Status = "UNKNOWN"
        Issues = @()
        Recommendations = @()
    }
    
    # Sprawdź czy ścieżka istnieje
    if (Test-Path $Path) {
        $result.Exists = $true
        Write-Host "  ✅ Ścieżka istnieje" -ForegroundColor Green
        
        # Sprawdź liczbę plików
        try {
            $files = Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue
            $result.FileCount = $files.Count
            Write-Host "  📄 Plików: $($result.FileCount)" -ForegroundColor White
        } catch {
            Write-Host "  ⚠️ Błąd liczenia plików: $_" -ForegroundColor Yellow
            $result.Issues += "File counting error: $_"
        }
        
        # Sprawdź czy to repozytorium Git
        $gitPath = Join-Path $Path ".git"
        if (Test-Path $gitPath) {
            $result.IsGitRepo = $true
            Write-Host "  ✅ To repozytorium Git" -ForegroundColor Green
            
            Push-Location $Path
            try {
                # Sprawdź remote URL
                $remoteURL = git remote get-url origin 2>$null
                $result.ActualURL = $remoteURL
                Write-Host "  🌐 Remote URL: $remoteURL" -ForegroundColor White
                
                # Sprawdź branch
                $branch = git branch --show-current 2>$null
                $result.Branch = $branch
                Write-Host "  🌿 Branch: $branch" -ForegroundColor White
                
                # Sprawdź HEAD
                $head = git rev-parse HEAD 2>$null
                $result.HEAD = $head.Substring(0, 8)
                Write-Host "  🎯 HEAD: $($result.HEAD)" -ForegroundColor White
                
                # Sprawdź ostatni commit
                $lastCommit = git log -1 --pretty=format:"%h - %s (%cr)" 2>$null
                $result.LastCommit = $lastCommit
                Write-Host "  📝 Ostatni commit: $lastCommit" -ForegroundColor White
                
                # Sprawdź status
                $gitStatus = git status --porcelain 2>$null
                if ($gitStatus) {
                    Write-Host "  ⚠️ Są niezcommitowane zmiany" -ForegroundColor Yellow
                    $result.Status = "DIRTY"
                    $result.Issues += "Uncommitted changes present"
                } else {
                    Write-Host "  ✅ Repozytorium czyste" -ForegroundColor Green
                    $result.Status = "CLEAN"
                }
                
                # Sprawdź czy URL się zgadza
                if ($result.ActualURL -ne $result.ExpectedURL) {
                    Write-Host "  ⚠️ URL nie pasuje do oczekiwanego" -ForegroundColor Yellow
                    $result.Issues += "Remote URL mismatch"
                    $result.Recommendations += "Update remote URL to: $($result.ExpectedURL)"
                }
                
                # Sprawdź czy branch to main
                if ($result.Branch -ne "main") {
                    Write-Host "  ⚠️ Branch nie jest 'main'" -ForegroundColor Yellow
                    $result.Issues += "Branch is not 'main'"
                    $result.Recommendations += "Switch to main branch"
                }
                
            } catch {
                Write-Host "  ❌ Błąd Git: $_" -ForegroundColor Red
                $result.Status = "ERROR"
                $result.Issues += "Git error: $_"
            } finally {
                Pop-Location
            }
        } else {
            Write-Host "  ❌ Nie jest repozytorium Git" -ForegroundColor Red
            $result.Issues += "Not a Git repository"
            $result.Recommendations += "Initialize as Git repository or clone from GitHub"
        }
    } else {
        Write-Host "  ❌ Ścieżka nie istnieje" -ForegroundColor Red
        $result.Issues += "Path does not exist"
        $result.Recommendations += "Create directory or clone repository"
    }
    
    return $result
}

# Sprawdź wszystkie możliwe lokalizacje
Write-Host "`n📊 SPRAWDZANIE WSZYSTKICH REPOZYTORIÓW..." -ForegroundColor Green

$allResults = @{}

foreach ($repo in $GitHubRepositories.GetEnumerator()) {
    $repoName = $repo.Key
    $repoInfo = $repo.Value
    
    Write-Host "`n" + "="*80 -ForegroundColor Gray
    Write-Host "🔍 REPOZYTORIUM: $repoName" -ForegroundColor Yellow
    Write-Host "="*80 -ForegroundColor Gray
    
    $repoResults = @()
    
    foreach ($path in $repoInfo.ExpectedPaths) {
        $result = Test-GitRepository -Name $repoName -Path $path -RepoInfo $repoInfo
        $repoResults += $result
    }
    
    $allResults[$repoName] = $repoResults
}

# Analiza wyników
Write-Host "`n" + "="*80 -ForegroundColor Cyan
Write-Host "📊 ANALIZA WYNIKÓW PO USUNIĘCIU GALACTICCODE" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan

# Sprawdź status każdego repozytorium
foreach ($repo in $allResults.GetEnumerator()) {
    $repoName = $repo.Key
    $results = $repo.Value
    
    Write-Host "`n🏢 $repoName" -ForegroundColor Yellow
    
    $activeRepo = $results | Where-Object { $_.Exists -and $_.IsGitRepo } | Select-Object -First 1
    
    if ($activeRepo) {
        Write-Host "  ✅ AKTYWNE REPOZYTORIUM ZNALEZIONE" -ForegroundColor Green
        Write-Host "  📁 Lokalizacja: $($activeRepo.Path)" -ForegroundColor White
        Write-Host "  🌿 Branch: $($activeRepo.Branch)" -ForegroundColor White
        Write-Host "  🎯 HEAD: $($activeRepo.HEAD)" -ForegroundColor White
        Write-Host "  📄 Plików: $($activeRepo.FileCount)" -ForegroundColor White
        Write-Host "  🔄 Status: $($activeRepo.Status)" -ForegroundColor White
        
        if ($activeRepo.Issues.Count -gt 0) {
            Write-Host "  ⚠️ PROBLEMY:" -ForegroundColor Yellow
            foreach ($issue in $activeRepo.Issues) {
                Write-Host "    - $issue" -ForegroundColor Red
            }
        }
        
        if ($activeRepo.Recommendations.Count -gt 0) {
            Write-Host "  🎯 REKOMENDACJE:" -ForegroundColor Cyan
            foreach ($rec in $activeRepo.Recommendations) {
                Write-Host "    - $rec" -ForegroundColor White
            }
        }
    } else {
        Write-Host "  ❌ BRAK AKTYWNEGO REPOZYTORIUM" -ForegroundColor Red
        Write-Host "  🎯 Sprawdzone lokalizacje:" -ForegroundColor White
        foreach ($result in $results) {
            $status = if ($result.Exists) { "EXISTS" } else { "MISSING" }
            Write-Host "    - $($result.Path) [$status]" -ForegroundColor Gray
        }
    }
}

# Sprawdź wpływ usunięcia GalacticCode
Write-Host "`n🌌 ANALIZA WPŁYWU USUNIĘCIA GALACTICCODE:" -ForegroundColor Magenta

$galacticResults = $allResults["GalacticCode_Repository"]
$galacticActive = $galacticResults | Where-Object { $_.Exists -and $_.IsGitRepo }

if ($galacticActive) {
    Write-Host "✅ GalacticCode Repository nadal istnieje w innej lokalizacji" -ForegroundColor Green
    Write-Host "📁 Aktywna lokalizacja: $($galacticActive.Path)" -ForegroundColor White
} else {
    Write-Host "⚠️ GalacticCode Repository nie zostało znalezione" -ForegroundColor Yellow
    Write-Host "🎯 Możliwe przyczyny:" -ForegroundColor White
    Write-Host "  - Folder został całkowicie usunięty" -ForegroundColor Gray
    Write-Host "  - Repozytorium zostało przeniesione do innej lokalizacji" -ForegroundColor Gray
    Write-Host "  - Wymaga ponownego sklonowania" -ForegroundColor Gray
}

# Sprawdź czy usunięcie wpłynęło na inne repozytoria
Write-Host "`n🔗 SPRAWDZANIE ZALEŻNOŚCI I SUBMODUŁÓW:" -ForegroundColor Cyan

foreach ($repo in $allResults.GetEnumerator()) {
    $repoName = $repo.Key
    $activeRepo = $repo.Value | Where-Object { $_.Exists -and $_.IsGitRepo } | Select-Object -First 1
    
    if ($activeRepo) {
        Write-Host "`n🔍 Sprawdzanie submodułów w $repoName..." -ForegroundColor White
        
        Push-Location $activeRepo.Path
        try {
            $submodules = git submodule status 2>$null
            if ($submodules) {
                Write-Host "  📦 Znalezione submoduły:" -ForegroundColor Green
                $submodules | ForEach-Object { Write-Host "    $($_)" -ForegroundColor Gray }
            } else {
                Write-Host "  ✅ Brak submodułów" -ForegroundColor Green
            }
            
            # Sprawdź .gitmodules
            $gitmodulesPath = Join-Path $activeRepo.Path ".gitmodules"
            if (Test-Path $gitmodulesPath) {
                Write-Host "  📄 Plik .gitmodules istnieje" -ForegroundColor Yellow
                $gitmodulesContent = Get-Content $gitmodulesPath
                Write-Host "  📋 Zawartość .gitmodules:" -ForegroundColor White
                $gitmodulesContent | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
            }
            
        } catch {
            Write-Host "  ⚠️ Błąd sprawdzania submodułów: $_" -ForegroundColor Yellow
        } finally {
            Pop-Location
        }
    }
}

# Generuj rekomendacje naprawcze
Write-Host "`n🎯 REKOMENDACJE NAPRAWCZE:" -ForegroundColor Yellow

Write-Host "`n📋 PRIORYTETOWE DZIAŁANIA:" -ForegroundColor Cyan

# 1. InfiniCoreCipher-Cleanup-Tools (Development)
$cleanupToolsRepo = $allResults["InfiniCoreCipher-Cleanup-Tools"] | Where-Object { $_.Exists -and $_.IsGitRepo } | Select-Object -First 1
if ($cleanupToolsRepo) {
    Write-Host "✅ 1. InfiniCoreCipher-Cleanup-Tools - OK" -ForegroundColor Green
    if ($cleanupToolsRepo.Issues.Count -gt 0) {
        Write-Host "   🔧 Wymagane poprawki:" -ForegroundColor Yellow
        foreach ($rec in $cleanupToolsRepo.Recommendations) {
            Write-Host "     - $rec" -ForegroundColor White
        }
    }
} else {
    Write-Host "❌ 1. InfiniCoreCipher-Cleanup-Tools - WYMAGA NAPRAWY" -ForegroundColor Red
}

# 2. Infinicorecipher (Production)
$infiniRepo = $allResults["Infinicorecipher"] | Where-Object { $_.Exists -and $_.IsGitRepo } | Select-Object -First 1
if ($infiniRepo) {
    Write-Host "✅ 2. Infinicorecipher (Production) - OK" -ForegroundColor Green
} else {
    Write-Host "❌ 2. Infinicorecipher (Production) - WYMAGA SKLONOWANIA" -ForegroundColor Red
    Write-Host "   🎯 Komenda: git clone https://github.com/Infinicorecipher-FutureTechEdu/Infinicorecipher.git" -ForegroundColor White
}

# 3. GalacticCode_Repository
if ($galacticActive) {
    Write-Host "✅ 3. GalacticCode_Repository - OK" -ForegroundColor Green
} else {
    Write-Host "⚠️ 3. GalacticCode_Repository - WYMAGA DECYZJI" -ForegroundColor Yellow
    Write-Host "   🎯 Opcje:" -ForegroundColor White
    Write-Host "     A) Sklonuj ponownie: git clone https://github.com/InfiniCoreCipher/GalacticCode_Repository.git" -ForegroundColor Gray
    Write-Host "     B) Pozostaw usunięte jeśli nie jest potrzebne" -ForegroundColor Gray
}

# Zapisz raport
$reportPath = "Repository-Structure-Analysis-Post-Deletion.json"
try {
    $allResults | ConvertTo-Json -Depth 5 | Out-File $reportPath -Encoding UTF8
    Write-Host "`n📄 Szczegółowy raport zapisany: $reportPath" -ForegroundColor Green
} catch {
    Write-Host "`n⚠️ Nie można zapisać raportu: $_" -ForegroundColor Yellow
}

Write-Host "`n🎉 ANALIZA ZAKOŃCZONA!" -ForegroundColor Green
Write-Host "📊 Sprawdzono wszystkie repozytoria po usunięciu GalacticCode_Repozitorium" -ForegroundColor White

pause