# 🔧 CORRECTIVE ACTIONS TOOLKIT
# Narzędzie działań naprawczych po usunięciu GalacticCode_Repozitorium

Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              🔧 CORRECTIVE ACTIONS TOOLKIT                      ║" -ForegroundColor Cyan
Write-Host "║         Post GalacticCode Deletion Repair Solutions             ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Definicje działań naprawczych
$CorrectiveActions = @{
    "1" = @{
        "Name" = "Fix Development Repository (Workspace)"
        "Description" = "Napraw repozytorium development w workspace"
        "Priority" = "Critical"
        "Actions" = @(
            "cd /workspace",
            "git status",
            "git remote -v",
            "git fetch origin",
            "git checkout main",
            "git pull origin main"
        )
    }
    "2" = @{
        "Name" = "Setup Production Repository"
        "Description" = "Skonfiguruj główne repozytorium produkcyjne"
        "Priority" = "High"
        "Actions" = @(
            "mkdir -p C:\InfiniCoreCipher-Startup",
            "cd C:\InfiniCoreCipher-Startup",
            "git clone https://github.com/Infinicorecipher-FutureTechEdu/Infinicorecipher.git Infinicorecipher_Repositorium",
            "cd Infinicorecipher_Repositorium",
            "git checkout main"
        )
    }
    "3" = @{
        "Name" = "Clean GalacticCode References"
        "Description" = "Usuń odwołania do GalacticCode z plików"
        "Priority" = "Medium"
        "Actions" = @(
            "# Sprawdź pliki z odwołaniami do GalacticCode",
            "grep -r 'GalacticCode' . --include='*.ps1' --include='*.md' --include='*.txt'",
            "# Usuń lub zaktualizuj odwołania ręcznie",
            "# Sprawdź plik .gitmodules",
            "cat .gitmodules 2>/dev/null || echo 'Brak pliku .gitmodules'"
        )
    }
    "4" = @{
        "Name" = "Fix Remote URLs"
        "Description" = "Popraw URL'e remote dla wszystkich repozytoriów"
        "Priority" = "High"
        "Actions" = @(
            "# Development Repository",
            "cd /workspace",
            "git remote set-url origin https://github.com/Infinicorecipher-FutureTechEdu/InfiniCoreCipher-Cleanup-Tools.git",
            "# Production Repository (jeśli istnieje)",
            "cd C:\InfiniCoreCipher-Startup\Infinicorecipher_Repositorium",
            "git remote set-url origin https://github.com/Infinicorecipher-FutureTechEdu/Infinicorecipher.git"
        )
    }
    "5" = @{
        "Name" = "Synchronize All Repositories"
        "Description" = "Zsynchronizuj wszystkie repozytoria z GitHub"
        "Priority" = "High"
        "Actions" = @(
            "# Workspace sync",
            "cd /workspace",
            "git add .",
            "git commit -m 'Post GalacticCode cleanup sync'",
            "git push origin main",
            "# Production sync (jeśli istnieje)",
            "cd C:\InfiniCoreCipher-Startup\Infinicorecipher_Repositorium",
            "git pull origin main"
        )
    }
    "6" = @{
        "Name" = "Verify Repository Integrity"
        "Description" = "Sprawdź integralność wszystkich repozytoriów"
        "Priority" = "Medium"
        "Actions" = @(
            "# Sprawdź workspace",
            "cd /workspace",
            "git fsck",
            "git status",
            "# Sprawdź produkcję",
            "cd C:\InfiniCoreCipher-Startup\Infinicorecipher_Repositorium",
            "git fsck",
            "git status"
        )
    }
    "7" = @{
        "Name" = "Recreate GalacticCode Repository (Optional)"
        "Description" = "Odtwórz repozytorium GalacticCode jeśli potrzebne"
        "Priority" = "Low"
        "Actions" = @(
            "cd C:\InfiniCoreCipher-Startup",
            "git clone https://github.com/InfiniCoreCipher/GalacticCode_Repository.git",
            "cd GalacticCode_Repository",
            "git checkout main"
        )
    }
    "8" = @{
        "Name" = "Update Documentation"
        "Description" = "Zaktualizuj dokumentację po zmianach"
        "Priority" = "Low"
        "Actions" = @(
            "# Zaktualizuj README.md",
            "# Zaktualizuj instrukcje instalacji",
            "# Usuń odwołania do usuniętych folderów",
            "# Dodaj informacje o nowej strukturze"
        )
    }
}

# Funkcja wykonywania działań naprawczych
function Invoke-CorrectiveAction {
    param(
        [string]$ActionId,
        [hashtable]$ActionInfo,
        [switch]$DryRun = $false
    )
    
    Write-Host "`n🔧 Wykonywanie: $($ActionInfo.Name)" -ForegroundColor Cyan
    Write-Host "📋 Opis: $($ActionInfo.Description)" -ForegroundColor White
    Write-Host "⭐ Priorytet: $($ActionInfo.Priority)" -ForegroundColor White
    
    if ($DryRun) {
        Write-Host "🔍 TRYB PODGLĄDU - Komendy do wykonania:" -ForegroundColor Yellow
        foreach ($action in $ActionInfo.Actions) {
            if ($action.StartsWith("#")) {
                Write-Host "  $action" -ForegroundColor Green
            } else {
                Write-Host "  > $action" -ForegroundColor White
            }
        }
        return @{ Success = $true; Message = "Dry run completed" }
    }
    
    $results = @()
    $success = $true
    
    foreach ($action in $ActionInfo.Actions) {
        if ($action.StartsWith("#")) {
            Write-Host "  💬 $action" -ForegroundColor Green
            continue
        }
        
        Write-Host "  ▶️ Wykonywanie: $action" -ForegroundColor White
        
        try {
            # Sprawdź czy to komenda cd
            if ($action.StartsWith("cd ")) {
                $path = $action.Substring(3).Trim()
                if (Test-Path $path) {
                    Push-Location $path
                    Write-Host "    ✅ Zmieniono katalog na: $path" -ForegroundColor Green
                } else {
                    Write-Host "    ⚠️ Katalog nie istnieje: $path" -ForegroundColor Yellow
                }
                continue
            }
            
            # Sprawdź czy to komenda mkdir
            if ($action.StartsWith("mkdir ")) {
                $path = $action.Substring(6).Trim()
                if (-not (Test-Path $path)) {
                    New-Item -ItemType Directory -Path $path -Force | Out-Null
                    Write-Host "    ✅ Utworzono katalog: $path" -ForegroundColor Green
                } else {
                    Write-Host "    ℹ️ Katalog już istnieje: $path" -ForegroundColor Blue
                }
                continue
            }
            
            # Wykonaj komendę
            $output = Invoke-Expression $action 2>&1
            if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq $null) {
                Write-Host "    ✅ Sukces" -ForegroundColor Green
                if ($output) {
                    Write-Host "    📄 Wynik: $($output | Select-Object -First 2 | Out-String)".Trim() -ForegroundColor Gray
                }
            } else {
                Write-Host "    ⚠️ Ostrzeżenie (kod: $LASTEXITCODE)" -ForegroundColor Yellow
                if ($output) {
                    Write-Host "    📄 Komunikat: $output" -ForegroundColor Gray
                }
            }
            
            $results += @{
                Command = $action
                Success = ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq $null)
                Output = $output
            }
            
        } catch {
            Write-Host "    ❌ Błąd: $_" -ForegroundColor Red
            $success = $false
            $results += @{
                Command = $action
                Success = $false
                Error = $_.Exception.Message
            }
        }
    }
    
    return @{
        Success = $success
        Results = $results
        Message = if ($success) { "Działanie zakończone sukcesem" } else { "Działanie zakończone z błędami" }
    }
}

# Menu główne
function Show-MainMenu {
    Write-Host "`n📋 MENU DZIAŁAŃ NAPRAWCZYCH:" -ForegroundColor Yellow
    Write-Host "="*60 -ForegroundColor Gray
    
    foreach ($action in $CorrectiveActions.GetEnumerator() | Sort-Object { [int]$_.Key }) {
        $priority = switch ($action.Value.Priority) {
            "Critical" { "🔴" }
            "High" { "🟡" }
            "Medium" { "🟠" }
            "Low" { "🟢" }
            default { "⚪" }
        }
        
        Write-Host "$($action.Key). $priority $($action.Value.Name)" -ForegroundColor White
        Write-Host "   $($action.Value.Description)" -ForegroundColor Gray
    }
    
    Write-Host "`n📋 OPCJE SPECJALNE:" -ForegroundColor Cyan
    Write-Host "A. Wykonaj wszystkie działania krytyczne i wysokiego priorytetu" -ForegroundColor White
    Write-Host "B. Wykonaj wszystkie działania (pełna naprawa)" -ForegroundColor White
    Write-Host "C. Podgląd wszystkich działań (dry run)" -ForegroundColor White
    Write-Host "D. Analiza stanu przed naprawą" -ForegroundColor White
    Write-Host "Q. Wyjście" -ForegroundColor White
    
    Write-Host "`n" + "="*60 -ForegroundColor Gray
}

# Funkcja analizy stanu
function Invoke-StateAnalysis {
    Write-Host "`n🔍 ANALIZA STANU REPOZYTORIÓW..." -ForegroundColor Cyan
    
    # Sprawdź workspace
    Write-Host "`n📁 Workspace (/workspace):" -ForegroundColor Yellow
    if (Test-Path "/workspace/.git") {
        Push-Location "/workspace"
        try {
            $branch = git branch --show-current 2>$null
            $remote = git remote get-url origin 2>$null
            $status = git status --porcelain 2>$null
            
            Write-Host "  ✅ Git repository" -ForegroundColor Green
            Write-Host "  🌿 Branch: $branch" -ForegroundColor White
            Write-Host "  🌐 Remote: $remote" -ForegroundColor White
            Write-Host "  📝 Zmiany: $(if($status){'TAK'}else{'NIE'})" -ForegroundColor $(if($status){'Yellow'}else{'Green'})
        } catch {
            Write-Host "  ❌ Błąd Git: $_" -ForegroundColor Red
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "  ❌ Nie jest repozytorium Git" -ForegroundColor Red
    }
    
    # Sprawdź produkcję
    $prodPaths = @(
        "C:\InfiniCoreCipher-Startup\Infinicorecipher_Repositorium",
        "C:\InfiniCoreCipher-Startup\Infinicorecipher"
    )
    
    foreach ($path in $prodPaths) {
        Write-Host "`n📁 Production ($path):" -ForegroundColor Yellow
        if (Test-Path $path) {
            if (Test-Path "$path\.git") {
                Write-Host "  ✅ Git repository istnieje" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️ Folder istnieje ale nie jest repozytorium Git" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ❌ Folder nie istnieje" -ForegroundColor Red
        }
    }
    
    # Sprawdź GalacticCode
    Write-Host "`n📁 GalacticCode (C:\InfiniCoreCipher-Startup\GalacticCode_Repository):" -ForegroundColor Yellow
    if (Test-Path "C:\InfiniCoreCipher-Startup\GalacticCode_Repository") {
        Write-Host "  ℹ️ Folder istnieje" -ForegroundColor Blue
    } else {
        Write-Host "  ✅ Folder usunięty (zgodnie z oczekiwaniami)" -ForegroundColor Green
    }
}

# Główna pętla programu
do {
    Show-MainMenu
    $choice = Read-Host "`nWybierz opcję"
    
    switch ($choice.ToUpper()) {
        "A" {
            Write-Host "`n🚀 WYKONYWANIE DZIAŁAŃ KRYTYCZNYCH I WYSOKIEGO PRIORYTETU..." -ForegroundColor Green
            $criticalActions = $CorrectiveActions.GetEnumerator() | Where-Object { $_.Value.Priority -in @("Critical", "High") }
            foreach ($action in $criticalActions) {
                $result = Invoke-CorrectiveAction -ActionId $action.Key -ActionInfo $action.Value
                Write-Host "📊 Wynik: $($result.Message)" -ForegroundColor $(if($result.Success){'Green'}else{'Red'})
            }
        }
        
        "B" {
            Write-Host "`n🚀 WYKONYWANIE WSZYSTKICH DZIAŁAŃ NAPRAWCZYCH..." -ForegroundColor Green
            foreach ($action in $CorrectiveActions.GetEnumerator() | Sort-Object { [int]$_.Key }) {
                $result = Invoke-CorrectiveAction -ActionId $action.Key -ActionInfo $action.Value
                Write-Host "📊 Wynik: $($result.Message)" -ForegroundColor $(if($result.Success){'Green'}else{'Red'})
            }
        }
        
        "C" {
            Write-Host "`n👁️ PODGLĄD WSZYSTKICH DZIAŁAŃ..." -ForegroundColor Blue
            foreach ($action in $CorrectiveActions.GetEnumerator() | Sort-Object { [int]$_.Key }) {
                Invoke-CorrectiveAction -ActionId $action.Key -ActionInfo $action.Value -DryRun
            }
        }
        
        "D" {
            Invoke-StateAnalysis
        }
        
        "Q" {
            Write-Host "`n👋 Zakończenie programu..." -ForegroundColor Green
            break
        }
        
        default {
            if ($CorrectiveActions.ContainsKey($choice)) {
                $action = $CorrectiveActions[$choice]
                Write-Host "`n🚀 WYKONYWANIE WYBRANEGO DZIAŁANIA..." -ForegroundColor Green
                $result = Invoke-CorrectiveAction -ActionId $choice -ActionInfo $action
                Write-Host "📊 Wynik: $($result.Message)" -ForegroundColor $(if($result.Success){'Green'}else{'Red'})
            } else {
                Write-Host "`n❌ Nieprawidłowy wybór. Spróbuj ponownie." -ForegroundColor Red
            }
        }
    }
    
    if ($choice.ToUpper() -ne "Q") {
        Write-Host "`nNaciśnij Enter aby kontynuować..." -ForegroundColor Gray
        Read-Host
    }
    
} while ($choice.ToUpper() -ne "Q")

Write-Host "`n🎉 CORRECTIVE ACTIONS TOOLKIT ZAKOŃCZONY!" -ForegroundColor Green
Write-Host "📊 Wszystkie narzędzia naprawcze są dostępne w workspace" -ForegroundColor White

pause