#!/usr/bin/env pwsh
# Menedżer Roadmapy Infinicorecipher Platform
# Automatyzacja zarządzania roadmapą i rekomendacjami

param(
    [string]$Action = "status",
    [string]$Phase = "",
    [string]$Task = "",
    [switch]$AutoUpdate = $false,
    [switch]$GenerateReport = $false,
    [switch]$Help = $false
)

if ($Help) {
    Write-Host "🗺️ MENEDŻER ROADMAPY INFINICORECIPHER PLATFORM" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "AKCJE:" -ForegroundColor Yellow
    Write-Host "  status      # Pokaż status roadmapy"
    Write-Host "  update      # Aktualizuj fazę/zadanie"
    Write-Host "  next        # Pokaż następne zadania"
    Write-Host "  report      # Generuj raport postępu"
    Write-Host "  recommend   # Pokaż rekomendacje"
    Write-Host ""
    Write-Host "UŻYCIE:" -ForegroundColor Yellow
    Write-Host "  ./roadmap_manager.ps1 status"
    Write-Host "  ./roadmap_manager.ps1 update -Phase 'Phase1' -Task 'File Organization'"
    Write-Host "  ./roadmap_manager.ps1 next"
    Write-Host "  ./roadmap_manager.ps1 report -GenerateReport"
    Write-Host "  ./roadmap_manager.ps1 recommend"
    Write-Host ""
    return
}

Write-Host "🗺️ MENEDŻER ROADMAPY INFINICORECIPHER PLATFORM" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "📅 Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow

# Definicja roadmapy Infinicorecipher Platform
$roadmap = @{
    "Phase1" = @{
        "name" = "Organizacja Plików i Struktura"
        "status" = "completed"
        "duration" = "Zakończone"
        "tasks" = @(
            @{ name = "Analiza aktualnego stanu"; status = "completed"; priority = "high" },
            @{ name = "Projekt struktury Infinicorecipher"; status = "completed"; priority = "high" },
            @{ name = "Skrypty organizacji uniwersalnej"; status = "completed"; priority = "medium" },
            @{ name = "Skrypty organizacji Infinicorecipher"; status = "completed"; priority = "high" },
            @{ name = "Weryfikacja i testy struktury"; status = "completed"; priority = "medium" }
        )
    }
    "Phase2" = @{
        "name" = "Fundament Infrastruktury"
        "status" = "in_progress"
        "duration" = "1-2 tygodnie"
        "tasks" = @(
            @{ name = "Uruchomienie skryptów organizacji"; status = "in_progress"; priority = "high" },
            @{ name = "Konfiguracja Docker/Kubernetes"; status = "pending"; priority = "high" },
            @{ name = "Setup bazy danych i migracji"; status = "pending"; priority = "high" },
            @{ name = "Konfiguracja monitorowania"; status = "pending"; priority = "medium" },
            @{ name = "Setup CI/CD pipeline"; status = "pending"; priority = "medium" }
        )
    }
    "Phase3" = @{
        "name" = "Rdzeń Backend"
        "status" = "pending"
        "duration" = "2-3 tygodnie"
        "tasks" = @(
            @{ name = "Platform Gateway (Port 8000)"; status = "pending"; priority = "high" },
            @{ name = "Auth Service (Port 8001)"; status = "pending"; priority = "high" },
            @{ name = "User Service (Port 8002)"; status = "pending"; priority = "high" },
            @{ name = "Analytics Service (Port 8003)"; status = "pending"; priority = "medium" },
            @{ name = "Education Service (Port 8004)"; status = "pending"; priority = "high" },
            @{ name = "Content Service (Port 8005)"; status = "pending"; priority = "medium" }
        )
    }
    "Phase4" = @{
        "name" = "Usługi Zaawansowane"
        "status" = "pending"
        "duration" = "2-3 tygodnie"
        "tasks" = @(
            @{ name = "Notification Service (Port 8006)"; status = "pending"; priority = "medium" },
            @{ name = "Assessment Service (Port 8007)"; status = "pending"; priority = "high" },
            @{ name = "Integracja Infinicorecipher Security"; status = "pending"; priority = "high" },
            @{ name = "Silniki analityczne"; status = "pending"; priority = "medium" },
            @{ name = "Framework edukacyjny"; status = "pending"; priority = "high" }
        )
    }
    "Phase5" = @{
        "name" = "Frontend i Aplikacje"
        "status" = "pending"
        "duration" = "3-4 tygodnie"
        "tasks" = @(
            @{ name = "React Web Client"; status = "pending"; priority = "high" },
            @{ name = "Komponenty UI współdzielone"; status = "pending"; priority = "medium" },
            @{ name = "Migracja GalacticCode"; status = "pending"; priority = "high" },
            @{ name = "Unity Client integracja"; status = "pending"; priority = "medium" },
            @{ name = "Mobile Client (React Native)"; status = "pending"; priority = "low" }
        )
    }
    "Phase6" = @{
        "name" = "Integracja i Testy"
        "status" = "pending"
        "duration" = "2-3 tygodnie"
        "tasks" = @(
            @{ name = "Testy jednostkowe"; status = "pending"; priority = "high" },
            @{ name = "Testy integracyjne"; status = "pending"; priority = "high" },
            @{ name = "Testy end-to-end"; status = "pending"; priority = "medium" },
            @{ name = "Testy bezpieczeństwa"; status = "pending"; priority = "high" },
            @{ name = "Testy wydajności"; status = "pending"; priority = "medium" }
        )
    }
    "Phase7" = @{
        "name" = "Wdrożenie i Produkcja"
        "status" = "pending"
        "duration" = "1-2 tygodnie"
        "tasks" = @(
            @{ name = "Konfiguracja środowisk"; status = "pending"; priority = "high" },
            @{ name = "Deployment pipeline"; status = "pending"; priority = "high" },
            @{ name = "Monitoring produkcyjny"; status = "pending"; priority = "medium" },
            @{ name = "Dokumentacja wdrożenia"; status = "pending"; priority = "medium" },
            @{ name = "Training i handover"; status = "pending"; priority = "low" }
        )
    }
}

# Rekomendacje dla każdej fazy
$recommendations = @{
    "Phase1" = @(
        "✅ Faza zakończona pomyślnie",
        "📁 Struktura Infinicorecipher Platform utworzona",
        "🔄 Można przejść do Phase2"
    )
    "Phase2" = @(
        "🚀 Uruchom skrypty organizacji: ./quick_organize_infinicorecipher.ps1",
        "🐳 Skonfiguruj Docker: infrastructure/docker/docker-compose.yml",
        "🗄️ Setup PostgreSQL z migracjami",
        "📊 Skonfiguruj Prometheus/Grafana monitoring",
        "⚙️ Przygotuj CI/CD pipeline (GitHub Actions)"
    )
    "Phase3" = @(
        "🌐 Rozpocznij od Platform Gateway jako centralnej bramy",
        "🔐 Auth Service jest krytyczny - priorytet wysoki",
        "👥 User Service potrzebny do testowania auth",
        "📈 Analytics Service można zrobić równolegle",
        "🎓 Education Service - rdzeń platformy edukacyjnej"
    )
    "Phase4" = @(
        "🔔 Notification Service dla komunikacji",
        "📝 Assessment Service dla oceniania",
        "🛡️ Integracja Infinicorecipher Security - krytyczna",
        "🤖 Silniki analityczne z ML",
        "📚 Framework edukacyjny z adaptacyjną trudnością"
    )
    "Phase5" = @(
        "⚛️ React Web Client z TypeScript",
        "🧩 UI Components w packages/ui-components",
        "🎮 Migracja GalacticCode do nowej struktury",
        "🎯 Unity Client integracja z backend API",
        "📱 Mobile Client opcjonalny na końcu"
    )
    "Phase6" = @(
        "🧪 Testy jednostkowe dla każdego serwisu",
        "🔗 Testy integracyjne API",
        "🌐 E2E testy dla głównych przepływów",
        "🔒 Testy bezpieczeństwa i penetracyjne",
        "⚡ Testy wydajności i obciążenia"
    )
    "Phase7" = @(
        "🌍 Konfiguracja środowisk (dev/staging/prod)",
        "🚀 Automated deployment pipeline",
        "📊 Production monitoring i alerting",
        "📖 Dokumentacja operacyjna",
        "👨‍🏫 Training zespołu i przekazanie wiedzy"
    )
}

# Funkcja do wyświetlania statusu
function Show-RoadmapStatus {
    Write-Host "`n📊 STATUS ROADMAPY INFINICORECIPHER PLATFORM" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    
    foreach ($phaseKey in $roadmap.Keys | Sort-Object) {
        $phase = $roadmap[$phaseKey]
        $statusIcon = switch ($phase.status) {
            "completed" { "✅" }
            "in_progress" { "🔄" }
            "pending" { "⏳" }
            default { "❓" }
        }
        
        $statusColor = switch ($phase.status) {
            "completed" { "Green" }
            "in_progress" { "Yellow" }
            "pending" { "Gray" }
            default { "Red" }
        }
        
        Write-Host "`n$statusIcon $phaseKey - $($phase.name)" -ForegroundColor $statusColor
        Write-Host "   Czas: $($phase.duration)" -ForegroundColor Gray
        
        # Pokaż zadania
        $completedTasks = ($phase.tasks | Where-Object { $_.status -eq "completed" }).Count
        $totalTasks = $phase.tasks.Count
        $progressPercent = if ($totalTasks -gt 0) { [math]::Round(($completedTasks / $totalTasks) * 100) } else { 0 }
        
        Write-Host "   Postęp: $completedTasks/$totalTasks zadań ($progressPercent%)" -ForegroundColor Gray
        
        # Pokaż zadania w trakcie lub następne
        if ($phase.status -eq "in_progress") {
            $currentTasks = $phase.tasks | Where-Object { $_.status -eq "in_progress" }
            if ($currentTasks) {
                Write-Host "   🔄 W trakcie:" -ForegroundColor Yellow
                foreach ($task in $currentTasks) {
                    Write-Host "     • $($task.name)" -ForegroundColor White
                }
            }
        }
    }
}

# Funkcja do pokazania następnych zadań
function Show-NextTasks {
    Write-Host "`n🎯 NASTĘPNE ZADANIA" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor Cyan
    
    # Znajdź aktualną fazę
    $currentPhase = $roadmap.GetEnumerator() | Where-Object { $_.Value.status -eq "in_progress" } | Select-Object -First 1
    
    if ($currentPhase) {
        Write-Host "`n🔄 Aktualna faza: $($currentPhase.Key) - $($currentPhase.Value.name)" -ForegroundColor Yellow
        
        $pendingTasks = $currentPhase.Value.tasks | Where-Object { $_.status -eq "pending" } | Sort-Object { 
            switch ($_.priority) {
                "high" { 1 }
                "medium" { 2 }
                "low" { 3 }
                default { 4 }
            }
        }
        
        if ($pendingTasks) {
            Write-Host "📋 Zadania do wykonania:" -ForegroundColor White
            foreach ($task in $pendingTasks) {
                $priorityIcon = switch ($task.priority) {
                    "high" { "🔴" }
                    "medium" { "🟡" }
                    "low" { "🟢" }
                    default { "⚪" }
                }
                Write-Host "  $priorityIcon $($task.name) ($($task.priority))" -ForegroundColor White
            }
        }
    }
    
    # Pokaż następną fazę
    $nextPhase = $roadmap.GetEnumerator() | Where-Object { $_.Value.status -eq "pending" } | Select-Object -First 1
    if ($nextPhase) {
        Write-Host "`n⏳ Następna faza: $($nextPhase.Key) - $($nextPhase.Value.name)" -ForegroundColor Gray
        Write-Host "   Czas: $($nextPhase.Value.duration)" -ForegroundColor Gray
    }
}

# Funkcja do pokazania rekomendacji
function Show-Recommendations {
    Write-Host "`n💡 REKOMENDACJE" -ForegroundColor Cyan
    Write-Host "===============" -ForegroundColor Cyan
    
    # Znajdź aktualną fazę
    $currentPhase = $roadmap.GetEnumerator() | Where-Object { $_.Value.status -eq "in_progress" } | Select-Object -First 1
    
    if ($currentPhase) {
        Write-Host "`n🔄 Dla aktualnej fazy ($($currentPhase.Key)):" -ForegroundColor Yellow
        foreach ($recommendation in $recommendations[$currentPhase.Key]) {
            Write-Host "  $recommendation" -ForegroundColor White
        }
    }
    
    # Pokaż ogólne rekomendacje
    Write-Host "`n🎯 Ogólne rekomendacje:" -ForegroundColor Cyan
    Write-Host "  📁 Nowe aplikacje/usługi → applications/ lub services/" -ForegroundColor White
    Write-Host "  🛠️ Narzędzia i skrypty → tools/ z podziałem na typ" -ForegroundColor White
    Write-Host "  🧪 Testy i automatyzacja → tests/ w dedykowanych podfolderach" -ForegroundColor White
    Write-Host "  📚 Dokumentacja → docs/ aktualizować na bieżąco" -ForegroundColor White
    Write-Host "  ⚙️ Konfiguracja → config/ wersjonować" -ForegroundColor White
    Write-Host "  🔄 Regularne odświeżanie → uruchamiać skrypty po zmianach" -ForegroundColor White
}

# Funkcja do aktualizacji zadania
function Update-Task {
    param($PhaseKey, $TaskName, $NewStatus)
    
    if ($roadmap.ContainsKey($PhaseKey)) {
        $task = $roadmap[$PhaseKey].tasks | Where-Object { $_.name -like "*$TaskName*" } | Select-Object -First 1
        if ($task) {
            $task.status = $NewStatus
            Write-Host "✅ Zaktualizowano zadanie '$($task.name)' na status '$NewStatus'" -ForegroundColor Green
            
            # Sprawdź czy faza jest zakończona
            $allCompleted = ($roadmap[$PhaseKey].tasks | Where-Object { $_.status -ne "completed" }).Count -eq 0
            if ($allCompleted -and $roadmap[$PhaseKey].status -ne "completed") {
                $roadmap[$PhaseKey].status = "completed"
                Write-Host "🎉 Faza $PhaseKey została zakończona!" -ForegroundColor Green
                
                # Rozpocznij następną fazę
                $nextPhaseKey = ($roadmap.Keys | Sort-Object | Where-Object { $roadmap[$_].status -eq "pending" } | Select-Object -First 1)
                if ($nextPhaseKey) {
                    $roadmap[$nextPhaseKey].status = "in_progress"
                    Write-Host "🚀 Rozpoczęto fazę $nextPhaseKey" -ForegroundColor Yellow
                }
            }
        } else {
            Write-Host "❌ Nie znaleziono zadania '$TaskName' w fazie '$PhaseKey'" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Nie znaleziono fazy '$PhaseKey'" -ForegroundColor Red
    }
}

# Funkcja do generowania raportu
function Generate-ProgressReport {
    $reportPath = "./ROADMAP_PROGRESS_REPORT.md"
    
    $report = @"
# 📊 Raport Postępu Infinicorecipher Platform

**Data:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Generator:** roadmap_manager.ps1

## 🎯 Przegląd Ogólny

"@

    # Oblicz ogólny postęp
    $totalTasks = 0
    $completedTasks = 0
    
    foreach ($phase in $roadmap.Values) {
        $totalTasks += $phase.tasks.Count
        $completedTasks += ($phase.tasks | Where-Object { $_.status -eq "completed" }).Count
    }
    
    $overallProgress = if ($totalTasks -gt 0) { [math]::Round(($completedTasks / $totalTasks) * 100, 1) } else { 0 }
    
    $report += @"

- **Ogólny postęp:** $completedTasks/$totalTasks zadań ($overallProgress%)
- **Fazy zakończone:** $(($roadmap.Values | Where-Object { $_.status -eq "completed" }).Count)
- **Fazy w trakcie:** $(($roadmap.Values | Where-Object { $_.status -eq "in_progress" }).Count)
- **Fazy oczekujące:** $(($roadmap.Values | Where-Object { $_.status -eq "pending" }).Count)

## 📋 Szczegóły Faz

"@

    foreach ($phaseKey in $roadmap.Keys | Sort-Object) {
        $phase = $roadmap[$phaseKey]
        $statusIcon = switch ($phase.status) {
            "completed" { "✅" }
            "in_progress" { "🔄" }
            "pending" { "⏳" }
            default { "❓" }
        }
        
        $phaseTasks = $phase.tasks.Count
        $phaseCompleted = ($phase.tasks | Where-Object { $_.status -eq "completed" }).Count
        $phaseProgress = if ($phaseTasks -gt 0) { [math]::Round(($phaseCompleted / $phaseTasks) * 100) } else { 0 }
        
        $report += @"

### $statusIcon $phaseKey - $($phase.name)

- **Status:** $($phase.status)
- **Czas:** $($phase.duration)
- **Postęp:** $phaseCompleted/$phaseTasks zadań ($phaseProgress%)

#### Zadania:

"@
        
        foreach ($task in $phase.tasks) {
            $taskIcon = switch ($task.status) {
                "completed" { "✅" }
                "in_progress" { "🔄" }
                "pending" { "⏳" }
                default { "❓" }
            }
            
            $priorityIcon = switch ($task.priority) {
                "high" { "🔴" }
                "medium" { "🟡" }
                "low" { "🟢" }
                default { "⚪" }
            }
            
            $report += "- $taskIcon $priorityIcon **$($task.name)** ($($task.priority))`n"
        }
    }
    
    $report += @"

## 💡 Rekomendacje Aktualne

"@

    # Dodaj rekomendacje dla aktualnej fazy
    $currentPhase = $roadmap.GetEnumerator() | Where-Object { $_.Value.status -eq "in_progress" } | Select-Object -First 1
    if ($currentPhase) {
        $report += "`n### Dla aktualnej fazy ($($currentPhase.Key)):`n`n"
        foreach ($recommendation in $recommendations[$currentPhase.Key]) {
            $report += "- $recommendation`n"
        }
    }
    
    $report += @"

## 🎯 Następne Kroki

"@

    if ($currentPhase) {
        $pendingTasks = $currentPhase.Value.tasks | Where-Object { $_.status -eq "pending" } | Sort-Object { 
            switch ($_.priority) {
                "high" { 1 }
                "medium" { 2 }
                "low" { 3 }
                default { 4 }
            }
        } | Select-Object -First 5
        
        if ($pendingTasks) {
            $report += "`n### Priorytetowe zadania:`n`n"
            foreach ($task in $pendingTasks) {
                $priorityIcon = switch ($task.priority) {
                    "high" { "🔴" }
                    "medium" { "🟡" }
                    "low" { "🟢" }
                    default { "⚪" }
                }
                $report += "1. $priorityIcon **$($task.name)** ($($task.priority))`n"
            }
        }
    }
    
    $report += @"

---
*Wygenerowano automatycznie przez roadmap_manager.ps1*
"@

    Set-Content -Path $reportPath -Value $report -Encoding UTF8
    Write-Host "📄 Raport zapisany: $reportPath" -ForegroundColor Green
}

# GŁÓWNA LOGIKA
switch ($Action.ToLower()) {
    "status" {
        Show-RoadmapStatus
    }
    "update" {
        if ($Phase -and $Task) {
            Update-Task $Phase $Task "completed"
            if ($AutoUpdate) {
                Generate-ProgressReport
            }
        } else {
            Write-Host "❌ Wymagane parametry: -Phase i -Task" -ForegroundColor Red
            Write-Host "Przykład: ./roadmap_manager.ps1 update -Phase 'Phase2' -Task 'Docker'" -ForegroundColor Yellow
        }
    }
    "next" {
        Show-NextTasks
    }
    "report" {
        Generate-ProgressReport
        if (!$GenerateReport) {
            Show-RoadmapStatus
        }
    }
    "recommend" {
        Show-Recommendations
    }
    default {
        Write-Host "❌ Nieznana akcja: $Action" -ForegroundColor Red
        Write-Host "Dostępne akcje: status, update, next, report, recommend" -ForegroundColor Yellow
        Write-Host "Użyj -Help aby zobaczyć pełną pomoc" -ForegroundColor Gray
    }
}

if ($GenerateReport) {
    Generate-ProgressReport
}

Write-Host "`n💡 Wskazówka: Użyj './roadmap_manager.ps1 -Help' aby zobaczyć wszystkie opcje" -ForegroundColor Gray