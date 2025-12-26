# 🔄 REPOSITORY SYNCHRONIZATION TESTER
# Test synchronizacji repozytoriów po usunięciu GalacticCode_Repozitorium

Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           🔄 REPOSITORY SYNCHRONIZATION TESTER                  ║" -ForegroundColor Cyan
Write-Host "║        Post GalacticCode Deletion Sync Verification             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Definicje repozytoriów do testowania synchronizacji
$SyncTestRepositories = @{
    "Development-Workspace" = @{
        "Path" = "/workspace"
        "RemoteURL" = "https://github.com/Infinicorecipher-FutureTechEdu/InfiniCoreCipher-Cleanup-Tools.git"
        "Type" = "Development"
        "Priority" = "High"
        "ExpectedBranch" = "main"
    }
    "Production-Primary" = @{
        "Path" = "C:\InfiniCoreCipher-Startup\Infinicorecipher_Repositorium"
        "RemoteURL" = "https://github.com/Infinicorecipher-FutureTechEdu/Infinicorecipher.git"
        "Type" = "Production"
        "Priority" = "High"
        "ExpectedBranch" = "main"
    }
    "Production-Secondary" = @{
        "Path" = "C:\InfiniCoreCipher-Startup\Infinicorecipher"
        "RemoteURL" = "https://github.com/Infinicorecipher-FutureTechEdu/Infinicorecipher.git"
        "Type" = "Production-Alt"
        "Priority" = "Medium"
        "ExpectedBranch" = "main"
    }
    "GalacticCode-Universe" = @{
        "Path" = "C:\InfiniCoreCipher-Startup\GalacticCode_Repository"
        "RemoteURL" = "https://github.com/InfiniCoreCipher/GalacticCode_Repository.git"
        "Type" = "Universe"
        "Priority" = "Low"
        "ExpectedBranch" = "main"
    }
}

# Funkcja testowania synchronizacji repozytorium
function Test-RepositorySync {
    param(
        [string]$Name,
        [hashtable]$RepoInfo
    )
    
    Write-Host "`n🔄 Test synchronizacji: $Name" -ForegroundColor Cyan
    Write-Host "📁 Ścieżka: $($RepoInfo.Path)" -ForegroundColor White
    Write-Host "🎯 Typ: $($RepoInfo.Type)" -ForegroundColor White
    Write-Host "⭐ Priorytet: $($RepoInfo.Priority)" -ForegroundColor White
    
    $result = @{
        Name = $Name
        Path = $RepoInfo.Path
        Type = $RepoInfo.Type
        Priority = $RepoInfo.Priority
        ExpectedRemote = $RepoInfo.RemoteURL
        ExpectedBranch = $RepoInfo.ExpectedBranch
        Exists = $false
        IsGitRepo = $false
        CurrentBranch = ""
        RemoteURL = ""
        LocalCommits = 0
        RemoteCommits = 0
        BehindBy = 0
        AheadBy = 0
        SyncStatus = "UNKNOWN"
        LastSync = ""
        UncommittedChanges = 0
        UntrackedFiles = 0
        ConflictFiles = 0
        RemoteAccessible = $false
        FetchSuccess = $false
        PushPossible = $false
        Issues = @()
        SyncActions = @()
        TestResults = @{}
    }
    
    # Sprawdź czy ścieżka istnieje
    if (Test-Path $RepoInfo.Path) {
        $result.Exists = $true
        Write-Host "  ✅ Repozytorium istnieje" -ForegroundColor Green
        
        # Sprawdź czy to repozytorium Git
        $gitPath = Join-Path $RepoInfo.Path ".git"
        if (Test-Path $gitPath) {
            $result.IsGitRepo = $true
            Write-Host "  ✅ To repozytorium Git" -ForegroundColor Green
            
            Push-Location $RepoInfo.Path
            try {
                # Test 1: Sprawdź podstawowe informacje
                Write-Host "  🔍 Test 1: Podstawowe informacje..." -ForegroundColor White
                
                $currentBranch = git branch --show-current 2>$null
                $result.CurrentBranch = $currentBranch
                Write-Host "    🌿 Aktualny branch: $currentBranch" -ForegroundColor Gray
                
                $remoteURL = git remote get-url origin 2>$null
                $result.RemoteURL = $remoteURL
                Write-Host "    🌐 Remote URL: $remoteURL" -ForegroundColor Gray
                
                # Test 2: Sprawdź dostępność remote
                Write-Host "  🔍 Test 2: Dostępność remote..." -ForegroundColor White
                
                $lsRemoteTest = git ls-remote --heads origin 2>$null
                if ($lsRemoteTest) {
                    $result.RemoteAccessible = $true
                    Write-Host "    ✅ Remote dostępny" -ForegroundColor Green
                } else {
                    $result.RemoteAccessible = $false
                    Write-Host "    ❌ Remote niedostępny" -ForegroundColor Red
                    $result.Issues += "Remote repository not accessible"
                }
                
                # Test 3: Fetch z remote
                Write-Host "  🔍 Test 3: Fetch z remote..." -ForegroundColor White
                
                $fetchResult = git fetch origin 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $result.FetchSuccess = $true
                    Write-Host "    ✅ Fetch zakończony sukcesem" -ForegroundColor Green
                } else {
                    $result.FetchSuccess = $false
                    Write-Host "    ❌ Błąd fetch: $fetchResult" -ForegroundColor Red
                    $result.Issues += "Fetch failed: $fetchResult"
                }
                
                # Test 4: Sprawdź status synchronizacji
                Write-Host "  🔍 Test 4: Status synchronizacji..." -ForegroundColor White
                
                if ($result.FetchSuccess -and $currentBranch) {
                    $revList = git rev-list --left-right --count "origin/$currentBranch...$currentBranch" 2>$null
                    if ($revList) {
                        $counts = $revList.Split("`t")
                        $result.BehindBy = [int]$counts[0]
                        $result.AheadBy = [int]$counts[1]
                        
                        Write-Host "    📊 Za remote: $($result.BehindBy) commitów" -ForegroundColor $(if($result.BehindBy -gt 0){'Yellow'}else{'Green'})
                        Write-Host "    📊 Przed remote: $($result.AheadBy) commitów" -ForegroundColor $(if($result.AheadBy -gt 0){'Yellow'}else{'Green'})
                        
                        # Określ status synchronizacji
                        if ($result.BehindBy -eq 0 -and $result.AheadBy -eq 0) {
                            $result.SyncStatus = "IN_SYNC"
                            Write-Host "    ✅ Repozytorium zsynchronizowane" -ForegroundColor Green
                        } elseif ($result.BehindBy -gt 0 -and $result.AheadBy -eq 0) {
                            $result.SyncStatus = "BEHIND"
                            Write-Host "    ⚠️ Repozytorium za remote" -ForegroundColor Yellow
                            $result.SyncActions += "git pull origin $currentBranch"
                        } elseif ($result.BehindBy -eq 0 -and $result.AheadBy -gt 0) {
                            $result.SyncStatus = "AHEAD"
                            Write-Host "    ⚠️ Repozytorium przed remote" -ForegroundColor Yellow
                            $result.SyncActions += "git push origin $currentBranch"
                        } else {
                            $result.SyncStatus = "DIVERGED"
                            Write-Host "    ❌ Repozytorium rozeszło się z remote" -ForegroundColor Red
                            $result.Issues += "Repository has diverged from remote"
                            $result.SyncActions += "git pull --rebase origin $currentBranch"
                        }
                    }
                }
                
                # Test 5: Sprawdź lokalne zmiany
                Write-Host "  🔍 Test 5: Lokalne zmiany..." -ForegroundColor White
                
                $statusPorcelain = git status --porcelain 2>$null
                if ($statusPorcelain) {
                    $statusLines = $statusPorcelain.Split("`n") | Where-Object { $_ -ne "" }
                    $result.UncommittedChanges = ($statusLines | Where-Object { $_ -match "^[MADRC]" }).Count
                    $result.UntrackedFiles = ($statusLines | Where-Object { $_ -match "^\?\?" }).Count
                    
                    Write-Host "    📝 Niezcommitowane zmiany: $($result.UncommittedChanges)" -ForegroundColor $(if($result.UncommittedChanges -gt 0){'Yellow'}else{'Green'})
                    Write-Host "    📄 Nieśledzone pliki: $($result.UntrackedFiles)" -ForegroundColor $(if($result.UntrackedFiles -gt 0){'Yellow'}else{'Green'})
                    
                    if ($result.UncommittedChanges -gt 0) {
                        $result.Issues += "Uncommitted changes present"
                        $result.SyncActions += "git add . && git commit -m 'Sync commit'"
                    }
                } else {
                    Write-Host "    ✅ Brak lokalnych zmian" -ForegroundColor Green
                }
                
                # Test 6: Sprawdź konflikty
                Write-Host "  🔍 Test 6: Sprawdzanie konfliktów..." -ForegroundColor White
                
                $conflictFiles = git diff --name-only --diff-filter=U 2>$null
                if ($conflictFiles) {
                    $result.ConflictFiles = $conflictFiles.Count
                    Write-Host "    ❌ Pliki z konfliktami: $($result.ConflictFiles)" -ForegroundColor Red
                    $result.Issues += "Merge conflicts present"
                    $result.SyncActions += "Resolve conflicts manually"
                } else {
                    Write-Host "    ✅ Brak konfliktów" -ForegroundColor Green
                }
                
                # Test 7: Test możliwości push
                Write-Host "  🔍 Test 7: Test możliwości push..." -ForegroundColor White
                
                if ($result.RemoteAccessible -and $result.AheadBy -gt 0) {
                    # Symuluj push (dry-run)
                    $pushTest = git push --dry-run origin $currentBranch 2>&1
                    if ($LASTEXITCODE -eq 0) {
                        $result.PushPossible = $true
                        Write-Host "    ✅ Push możliwy" -ForegroundColor Green
                    } else {
                        $result.PushPossible = $false
                        Write-Host "    ❌ Push niemożliwy: $pushTest" -ForegroundColor Red
                        $result.Issues += "Push not possible: $pushTest"
                    }
                } else {
                    Write-Host "    ℹ️ Push nie wymagany" -ForegroundColor Blue
                }
                
                # Test 8: Sprawdź ostatnią synchronizację
                Write-Host "  🔍 Test 8: Ostatnia synchronizacja..." -ForegroundColor White
                
                $lastCommit = git log -1 --pretty=format:"%h - %s (%cr)" 2>$null
                $result.LastSync = $lastCommit
                Write-Host "    📝 Ostatni commit: $lastCommit" -ForegroundColor Gray
                
                # Sprawdź czy branch jest poprawny
                if ($currentBranch -ne $RepoInfo.ExpectedBranch) {
                    Write-Host "    ⚠️ Branch '$currentBranch' różni się od oczekiwanego '$($RepoInfo.ExpectedBranch)'" -ForegroundColor Yellow
                    $result.Issues += "Branch mismatch: expected $($RepoInfo.ExpectedBranch), got $currentBranch"
                    $result.SyncActions += "git checkout $($RepoInfo.ExpectedBranch)"
                }
                
                # Sprawdź czy remote URL jest poprawny
                if ($remoteURL -ne $RepoInfo.RemoteURL) {
                    Write-Host "    ⚠️ Remote URL różni się od oczekiwanego" -ForegroundColor Yellow
                    $result.Issues += "Remote URL mismatch"
                    $result.SyncActions += "git remote set-url origin $($RepoInfo.RemoteURL)"
                }
                
            } catch {
                Write-Host "  ❌ Błąd testowania synchronizacji: $_" -ForegroundColor Red
                $result.Issues += "Sync test error: $_"
            } finally {
                Pop-Location
            }
        } else {
            Write-Host "  ❌ Nie jest repozytorium Git" -ForegroundColor Red
            $result.Issues += "Not a Git repository"
            $result.SyncActions += "git clone $($RepoInfo.RemoteURL) `"$($RepoInfo.Path)`""
        }
    } else {
        Write-Host "  ❌ Repozytorium nie istnieje" -ForegroundColor Red
        $result.Issues += "Repository does not exist"
        $result.SyncActions += "git clone $($RepoInfo.RemoteURL) `"$($RepoInfo.Path)`""
    }
    
    return $result
}

# Przeprowadź testy synchronizacji
Write-Host "`n📊 TESTOWANIE SYNCHRONIZACJI WSZYSTKICH REPOZYTORIÓW..." -ForegroundColor Green

$syncResults = @{}

foreach ($repo in $SyncTestRepositories.GetEnumerator()) {
    $syncResults[$repo.Key] = Test-RepositorySync -Name $repo.Key -RepoInfo $repo.Value
}

# Analiza wyników synchronizacji
Write-Host "`n" + "="*80 -ForegroundColor Cyan
Write-Host "📊 PODSUMOWANIE TESTÓW SYNCHRONIZACJI" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan

$inSyncRepos = 0
$outOfSyncRepos = 0
$inaccessibleRepos = 0
$totalIssues = 0

foreach ($result in $syncResults.Values) {
    Write-Host "`n🏢 $($result.Name) [$($result.Type)] - Priorytet: $($result.Priority)" -ForegroundColor Yellow
    
    if ($result.Exists -and $result.IsGitRepo) {
        Write-Host "  📁 Status: DOSTĘPNY" -ForegroundColor Green
        Write-Host "  🌿 Branch: $($result.CurrentBranch)" -ForegroundColor White
        Write-Host "  🔄 Synchronizacja: $($result.SyncStatus)" -ForegroundColor $(
            switch ($result.SyncStatus) {
                "IN_SYNC" { "Green" }
                "BEHIND" { "Yellow" }
                "AHEAD" { "Yellow" }
                "DIVERGED" { "Red" }
                default { "Gray" }
            }
        )
        Write-Host "  🌐 Remote dostępny: $(if($result.RemoteAccessible){'TAK'}else{'NIE'})" -ForegroundColor $(if($result.RemoteAccessible){'Green'}else{'Red'})
        
        if ($result.BehindBy -gt 0 -or $result.AheadBy -gt 0) {
            Write-Host "  📊 Za/Przed remote: $($result.BehindBy)/$($result.AheadBy)" -ForegroundColor Yellow
        }
        
        if ($result.UncommittedChanges -gt 0 -or $result.UntrackedFiles -gt 0) {
            Write-Host "  📝 Lokalne zmiany: $($result.UncommittedChanges) + $($result.UntrackedFiles) nieśledzonych" -ForegroundColor Yellow
        }
        
        # Klasyfikuj status
        if ($result.SyncStatus -eq "IN_SYNC" -and $result.RemoteAccessible -and $result.UncommittedChanges -eq 0) {
            $inSyncRepos++
        } else {
            $outOfSyncRepos++
        }
        
    } elseif ($result.Exists) {
        Write-Host "  ❌ Status: NIE JEST REPOZYTORIUM GIT" -ForegroundColor Red
        $inaccessibleRepos++
    } else {
        Write-Host "  ❌ Status: NIEDOSTĘPNY" -ForegroundColor Red
        $inaccessibleRepos++
    }
    
    $totalIssues += $result.Issues.Count
    
    if ($result.Issues.Count -gt 0) {
        Write-Host "  ⚠️ Problemy ($($result.Issues.Count)):" -ForegroundColor Red
        foreach ($issue in $result.Issues | Select-Object -First 3) {
            Write-Host "    - $issue" -ForegroundColor Gray
        }
        if ($result.Issues.Count -gt 3) {
            Write-Host "    ... i $($result.Issues.Count - 3) więcej" -ForegroundColor Gray
        }
    }
}

# Analiza wpływu usunięcia GalacticCode na synchronizację
Write-Host "`n🌌 WPŁYW USUNIĘCIA GALACTICCODE NA SYNCHRONIZACJĘ:" -ForegroundColor Magenta

$galacticResult = $syncResults["GalacticCode-Universe"]
$mainReposOK = $true

# Sprawdź główne repozytoria
$workspaceResult = $syncResults["Development-Workspace"]
$productionResult = $syncResults["Production-Primary"]

if ($workspaceResult.SyncStatus -eq "IN_SYNC" -and $workspaceResult.RemoteAccessible) {
    Write-Host "✅ Development Repository - synchronizacja OK" -ForegroundColor Green
} else {
    Write-Host "⚠️ Development Repository - problemy z synchronizacją" -ForegroundColor Yellow
    $mainReposOK = $false
}

if ($productionResult.Exists -and $productionResult.RemoteAccessible) {
    Write-Host "✅ Production Repository - dostępny" -ForegroundColor Green
} else {
    Write-Host "⚠️ Production Repository - problemy z dostępem" -ForegroundColor Yellow
    $mainReposOK = $false
}

if ($galacticResult.Exists) {
    Write-Host "ℹ️ GalacticCode Repository - nadal dostępny" -ForegroundColor Blue
} else {
    Write-Host "ℹ️ GalacticCode Repository - usunięty (zgodnie z oczekiwaniami)" -ForegroundColor Blue
}

if ($mainReposOK) {
    Write-Host "`n✅ GŁÓWNE REPOZYTORIA NIENARUSZONE" -ForegroundColor Green
    Write-Host "   Usunięcie GalacticCode nie wpłynęło na synchronizację głównych repozytoriów" -ForegroundColor White
} else {
    Write-Host "`n⚠️ GŁÓWNE REPOZYTORIA WYMAGAJĄ UWAGI" -ForegroundColor Yellow
    Write-Host "   Sprawdź czy problemy są związane z usunięciem GalacticCode" -ForegroundColor White
}

# Generuj plan synchronizacji
Write-Host "`n🎯 PLAN DZIAŁAŃ SYNCHRONIZACYJNYCH:" -ForegroundColor Yellow

$highPriorityActions = @()
$mediumPriorityActions = @()
$lowPriorityActions = @()

foreach ($result in $syncResults.Values) {
    if ($result.SyncActions.Count -gt 0) {
        $actions = @{
            Name = $result.Name
            Priority = $result.Priority
            Actions = $result.SyncActions
        }
        
        switch ($result.Priority) {
            "High" { $highPriorityActions += $actions }
            "Medium" { $mediumPriorityActions += $actions }
            "Low" { $lowPriorityActions += $actions }
        }
    }
}

if ($highPriorityActions.Count -gt 0) {
    Write-Host "`n🔴 WYSOKI PRIORYTET:" -ForegroundColor Red
    foreach ($action in $highPriorityActions) {
        Write-Host "  📋 $($action.Name):" -ForegroundColor Cyan
        foreach ($cmd in $action.Actions) {
            Write-Host "    $cmd" -ForegroundColor White
        }
    }
}

if ($mediumPriorityActions.Count -gt 0) {
    Write-Host "`n🟡 ŚREDNI PRIORYTET:" -ForegroundColor Yellow
    foreach ($action in $mediumPriorityActions) {
        Write-Host "  📋 $($action.Name):" -ForegroundColor Cyan
        foreach ($cmd in $action.Actions) {
            Write-Host "    $cmd" -ForegroundColor White
        }
    }
}

if ($lowPriorityActions.Count -gt 0) {
    Write-Host "`n🟢 NISKI PRIORYTET:" -ForegroundColor Green
    foreach ($action in $lowPriorityActions) {
        Write-Host "  📋 $($action.Name):" -ForegroundColor Cyan
        foreach ($cmd in $action.Actions) {
            Write-Host "    $cmd" -ForegroundColor White
        }
    }
}

if ($highPriorityActions.Count -eq 0 -and $mediumPriorityActions.Count -eq 0 -and $lowPriorityActions.Count -eq 0) {
    Write-Host "✅ Brak wymaganych działań synchronizacyjnych" -ForegroundColor Green
}

# Statystyki końcowe
Write-Host "`n📊 STATYSTYKI SYNCHRONIZACJI:" -ForegroundColor Green
Write-Host "✅ Zsynchronizowane: $inSyncRepos" -ForegroundColor Green
Write-Host "⚠️ Wymagające synchronizacji: $outOfSyncRepos" -ForegroundColor Yellow
Write-Host "❌ Niedostępne: $inaccessibleRepos" -ForegroundColor Red
Write-Host "🔧 Łączne problemy: $totalIssues" -ForegroundColor White
Write-Host "📁 Sprawdzonych repozytoriów: $($syncResults.Count)" -ForegroundColor White

# Zapisz raport
$reportPath = "Repository-Sync-Test-Report.json"
try {
    $syncResults | ConvertTo-Json -Depth 5 | Out-File $reportPath -Encoding UTF8
    Write-Host "`n📄 Raport testów synchronizacji zapisany: $reportPath" -ForegroundColor Green
} catch {
    Write-Host "`n⚠️ Nie można zapisać raportu: $_" -ForegroundColor Yellow
}

Write-Host "`n🎉 TESTY SYNCHRONIZACJI ZAKOŃCZONE!" -ForegroundColor Green

pause