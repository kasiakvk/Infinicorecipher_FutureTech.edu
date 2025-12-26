# 🎯 GIT HEAD VERIFICATION TOOL
# Weryfikacja HEAD'ów, połączeń i modułów po usunięciu GalacticCode

Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              🎯 GIT HEAD VERIFICATION TOOL                       ║" -ForegroundColor Cyan
Write-Host "║           Post GalacticCode Deletion Verification                ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Definicje repozytoriów do sprawdzenia
$RepositoriesToCheck = @{
    "Current-Workspace" = @{
        "Path" = "/workspace"
        "ExpectedRemote" = "https://github.com/Infinicorecipher-FutureTechEdu/InfiniCoreCipher-Cleanup-Tools.git"
        "Type" = "Development"
        "CurrentHEAD" = "3af9fa8"
    }
    "Production-Infinicorecipher" = @{
        "Path" = "C:\InfiniCoreCipher-Startup\Infinicorecipher_Repositorium"
        "ExpectedRemote" = "https://github.com/Infinicorecipher-FutureTechEdu/Infinicorecipher.git"
        "Type" = "Production"
        "CurrentHEAD" = "Unknown"
    }
    "Alternative-Production" = @{
        "Path" = "C:\InfiniCoreCipher-Startup\Infinicorecipher"
        "ExpectedRemote" = "https://github.com/Infinicorecipher-FutureTechEdu/Infinicorecipher.git"
        "Type" = "Production-Alt"
        "CurrentHEAD" = "Unknown"
    }
    "GalacticCode-Main" = @{
        "Path" = "C:\InfiniCoreCipher-Startup\GalacticCode_Repository"
        "ExpectedRemote" = "https://github.com/InfiniCoreCipher/GalacticCode_Repository.git"
        "Type" = "Universe"
        "CurrentHEAD" = "Unknown"
    }
}

# Funkcja weryfikacji HEAD i połączeń
function Test-GitHeadAndConnections {
    param(
        [string]$Name,
        [hashtable]$RepoInfo
    )
    
    Write-Host "`n🔍 Weryfikacja: $Name" -ForegroundColor Cyan
    Write-Host "📁 Ścieżka: $($RepoInfo.Path)" -ForegroundColor White
    Write-Host "🎯 Typ: $($RepoInfo.Type)" -ForegroundColor White
    
    $result = @{
        Name = $Name
        Path = $RepoInfo.Path
        Type = $RepoInfo.Type
        ExpectedRemote = $RepoInfo.ExpectedRemote
        ExpectedHEAD = $RepoInfo.CurrentHEAD
        Exists = $false
        IsGitRepo = $false
        ActualRemote = ""
        ActualHEAD = ""
        Branch = ""
        RemoteStatus = "UNKNOWN"
        HEADStatus = "UNKNOWN"
        ConnectionTest = "UNKNOWN"
        Issues = @()
        FixCommands = @()
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
                # Sprawdź remote
                $actualRemote = git remote get-url origin 2>$null
                $result.ActualRemote = $actualRemote
                Write-Host "  🌐 Remote URL: $actualRemote" -ForegroundColor White
                
                # Sprawdź HEAD
                $actualHEAD = git rev-parse HEAD 2>$null
                if ($actualHEAD) {
                    $result.ActualHEAD = $actualHEAD.Substring(0, 8)
                    Write-Host "  🎯 Aktualny HEAD: $($result.ActualHEAD)" -ForegroundColor White
                }
                
                # Sprawdź branch
                $branch = git branch --show-current 2>$null
                $result.Branch = $branch
                Write-Host "  🌿 Branch: $branch" -ForegroundColor White
                
                # Weryfikuj remote URL
                if ($actualRemote -eq $RepoInfo.ExpectedRemote) {
                    $result.RemoteStatus = "CORRECT"
                    Write-Host "  ✅ Remote URL poprawny" -ForegroundColor Green
                } elseif ($actualRemote -like "*$($RepoInfo.ExpectedRemote.Split('/')[-1])*") {
                    $result.RemoteStatus = "SIMILAR"
                    Write-Host "  ⚠️ Remote URL podobny ale nie identyczny" -ForegroundColor Yellow
                    $result.Issues += "Remote URL mismatch"
                    $result.FixCommands += "git remote set-url origin $($RepoInfo.ExpectedRemote)"
                } else {
                    $result.RemoteStatus = "INCORRECT"
                    Write-Host "  ❌ Remote URL niepoprawny" -ForegroundColor Red
                    $result.Issues += "Incorrect remote URL"
                    $result.FixCommands += "git remote set-url origin $($RepoInfo.ExpectedRemote)"
                }
                
                # Weryfikuj HEAD (jeśli znany)
                if ($RepoInfo.CurrentHEAD -ne "Unknown") {
                    if ($result.ActualHEAD -eq $RepoInfo.CurrentHEAD) {
                        $result.HEADStatus = "CORRECT"
                        Write-Host "  ✅ HEAD poprawny" -ForegroundColor Green
                    } else {
                        $result.HEADStatus = "DIFFERENT"
                        Write-Host "  ⚠️ HEAD różni się od oczekiwanego" -ForegroundColor Yellow
                        Write-Host "    Oczekiwany: $($RepoInfo.CurrentHEAD)" -ForegroundColor Gray
                        Write-Host "    Aktualny: $($result.ActualHEAD)" -ForegroundColor Gray
                    }
                } else {
                    $result.HEADStatus = "UNKNOWN_EXPECTED"
                    Write-Host "  ℹ️ HEAD nieznany - to normalne" -ForegroundColor Blue
                }
                
                # Test połączenia z remote
                Write-Host "  🔗 Testowanie połączenia z remote..." -ForegroundColor White
                $fetchTest = git ls-remote --heads origin 2>$null
                if ($fetchTest) {
                    $result.ConnectionTest = "SUCCESS"
                    Write-Host "  ✅ Połączenie z remote działa" -ForegroundColor Green
                } else {
                    $result.ConnectionTest = "FAILED"
                    Write-Host "  ❌ Błąd połączenia z remote" -ForegroundColor Red
                    $result.Issues += "Remote connection failed"
                }
                
                # Sprawdź czy branch to main
                if ($branch -ne "main") {
                    Write-Host "  ⚠️ Branch nie jest 'main'" -ForegroundColor Yellow
                    $result.Issues += "Branch is not main"
                    $result.FixCommands += "git checkout main"
                }
                
                # Sprawdź status
                $gitStatus = git status --porcelain 2>$null
                if ($gitStatus) {
                    Write-Host "  ⚠️ Są niezcommitowane zmiany" -ForegroundColor Yellow
                    $result.Issues += "Uncommitted changes"
                }
                
                # Sprawdź czy jest za remote
                $behindAhead = git rev-list --left-right --count origin/main...HEAD 2>$null
                if ($behindAhead) {
                    $counts = $behindAhead.Split("`t")
                    $behind = [int]$counts[0]
                    $ahead = [int]$counts[1]
                    
                    if ($behind -gt 0) {
                        Write-Host "  ⚠️ $behind commitów za remote" -ForegroundColor Yellow
                        $result.Issues += "$behind commits behind remote"
                        $result.FixCommands += "git pull origin main"
                    }
                    
                    if ($ahead -gt 0) {
                        Write-Host "  ⚠️ $ahead commitów przed remote" -ForegroundColor Yellow
                        $result.Issues += "$ahead commits ahead of remote"
                        $result.FixCommands += "git push origin main"
                    }
                    
                    if ($behind -eq 0 -and $ahead -eq 0) {
                        Write-Host "  ✅ Synchronizacja z remote OK" -ForegroundColor Green
                    }
                }
                
            } catch {
                Write-Host "  ❌ Błąd Git: $_" -ForegroundColor Red
                $result.Issues += "Git error: $_"
            } finally {
                Pop-Location
            }
        } else {
            Write-Host "  ❌ Nie jest repozytorium Git" -ForegroundColor Red
            $result.Issues += "Not a Git repository"
            $result.FixCommands += "git clone $($RepoInfo.ExpectedRemote) `"$($RepoInfo.Path)`""
        }
    } else {
        Write-Host "  ❌ Ścieżka nie istnieje" -ForegroundColor Red
        $result.Issues += "Path does not exist"
        $result.FixCommands += "git clone $($RepoInfo.ExpectedRemote) `"$($RepoInfo.Path)`""
    }
    
    return $result
}

# Sprawdź wszystkie repozytoria
Write-Host "`n📊 WERYFIKACJA WSZYSTKICH REPOZYTORIÓW..." -ForegroundColor Green

$verificationResults = @{}

foreach ($repo in $RepositoriesToCheck.GetEnumerator()) {
    $verificationResults[$repo.Key] = Test-GitHeadAndConnections -Name $repo.Key -RepoInfo $repo.Value
}

# Analiza wyników
Write-Host "`n" + "="*80 -ForegroundColor Cyan
Write-Host "📊 PODSUMOWANIE WERYFIKACJI" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan

$healthyRepos = 0
$problematicRepos = 0

foreach ($result in $verificationResults.Values) {
    Write-Host "`n🏢 $($result.Name) [$($result.Type)]" -ForegroundColor Yellow
    
    if ($result.Exists -and $result.IsGitRepo -and $result.RemoteStatus -eq "CORRECT" -and $result.ConnectionTest -eq "SUCCESS") {
        Write-Host "  ✅ ZDROWE REPOZYTORIUM" -ForegroundColor Green
        $healthyRepos++
    } else {
        Write-Host "  ⚠️ WYMAGA UWAGI" -ForegroundColor Yellow
        $problematicRepos++
    }
    
    Write-Host "  📁 Ścieżka: $($result.Path)" -ForegroundColor White
    Write-Host "  🎯 HEAD: $($result.ActualHEAD)" -ForegroundColor White
    Write-Host "  🌿 Branch: $($result.Branch)" -ForegroundColor White
    Write-Host "  🌐 Remote: $($result.RemoteStatus)" -ForegroundColor $(if($result.RemoteStatus -eq "CORRECT"){"Green"}else{"Yellow"})
    Write-Host "  🔗 Połączenie: $($result.ConnectionTest)" -ForegroundColor $(if($result.ConnectionTest -eq "SUCCESS"){"Green"}else{"Red"})
    
    if ($result.Issues.Count -gt 0) {
        Write-Host "  ❌ Problemy:" -ForegroundColor Red
        foreach ($issue in $result.Issues) {
            Write-Host "    - $issue" -ForegroundColor Gray
        }
    }
}

# Sprawdź wpływ usunięcia GalacticCode
Write-Host "`n🌌 ANALIZA WPŁYWU USUNIĘCIA GALACTICCODE:" -ForegroundColor Magenta

$galacticResult = $verificationResults["GalacticCode-Main"]
if ($galacticResult.Exists) {
    Write-Host "✅ GalacticCode Repository nadal dostępne" -ForegroundColor Green
    Write-Host "  🎯 HEAD: $($galacticResult.ActualHEAD)" -ForegroundColor White
    Write-Host "  🔗 Połączenie: $($galacticResult.ConnectionTest)" -ForegroundColor White
} else {
    Write-Host "⚠️ GalacticCode Repository niedostępne" -ForegroundColor Yellow
    Write-Host "  📋 To może być zamierzone po usunięciu folderu" -ForegroundColor Gray
}

# Sprawdź czy inne repozytoria są nienaruszone
$workspaceResult = $verificationResults["Current-Workspace"]
$productionResult = $verificationResults["Production-Infinicorecipher"]

Write-Host "`n🔍 SPRAWDZENIE INTEGRALNOŚCI GŁÓWNYCH REPOZYTORIÓW:" -ForegroundColor Cyan

if ($workspaceResult.IsGitRepo -and $workspaceResult.ConnectionTest -eq "SUCCESS") {
    Write-Host "✅ Development Repository (Workspace) - NIENARUSZONY" -ForegroundColor Green
} else {
    Write-Host "⚠️ Development Repository (Workspace) - WYMAGA SPRAWDZENIA" -ForegroundColor Yellow
}

if ($productionResult.Exists -and $productionResult.IsGitRepo) {
    Write-Host "✅ Production Repository - DOSTĘPNY" -ForegroundColor Green
} else {
    Write-Host "⚠️ Production Repository - NIEDOSTĘPNY" -ForegroundColor Yellow
}

# Generuj komendy naprawcze
Write-Host "`n🔧 KOMENDY NAPRAWCZE:" -ForegroundColor Yellow

foreach ($result in $verificationResults.Values) {
    if ($result.FixCommands.Count -gt 0) {
        Write-Host "`n📋 Dla $($result.Name):" -ForegroundColor Cyan
        foreach ($command in $result.FixCommands) {
            Write-Host "  $command" -ForegroundColor White
        }
    }
}

# Statystyki końcowe
Write-Host "`n📊 STATYSTYKI:" -ForegroundColor Green
Write-Host "✅ Zdrowe repozytoria: $healthyRepos" -ForegroundColor Green
Write-Host "⚠️ Wymagające uwagi: $problematicRepos" -ForegroundColor Yellow
Write-Host "📁 Łącznie sprawdzonych: $($verificationResults.Count)" -ForegroundColor White

# Zapisz raport
$reportPath = "Git-HEAD-Verification-Report.json"
try {
    $verificationResults | ConvertTo-Json -Depth 4 | Out-File $reportPath -Encoding UTF8
    Write-Host "`n📄 Raport weryfikacji zapisany: $reportPath" -ForegroundColor Green
} catch {
    Write-Host "`n⚠️ Nie można zapisać raportu: $_" -ForegroundColor Yellow
}

Write-Host "`n🎉 WERYFIKACJA HEAD'ÓW I POŁĄCZEŃ ZAKOŃCZONA!" -ForegroundColor Green

pause