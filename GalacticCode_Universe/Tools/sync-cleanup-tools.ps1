# ===============================================
# sync-cleanup-tools.ps1
# Synchronizacja cleanup tools z workspace
# ===============================================

param(
    [string]$LocalRepoPath = "C:\InfiniCoreCipher-Startup\InfiniCoreCipher",
    [string]$WorkspacePath = "/workspace",
    [switch]$DryRun = $false
)

Write-Host "🔄 Synchronizacja Cleanup Tools..." -ForegroundColor Cyan

# Sprawdź ścieżki
if (-not (Test-Path $LocalRepoPath)) {
    Write-Host "❌ Lokalne repo nie znalezione: $LocalRepoPath" -ForegroundColor Red
    exit 1
}

$CleanupToolsPath = Join-Path $LocalRepoPath "cleanup-tools"

# Utwórz folder cleanup-tools jeśli nie istnieje
if (-not (Test-Path $CleanupToolsPath)) {
    Write-Host "📁 Tworzenie folderu cleanup-tools..." -ForegroundColor Yellow
    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $CleanupToolsPath -Force
    }
}

# Lista plików do skopiowania
$FilesToSync = @(
    # Skrypty PowerShell
    "All-In-One-Cleanup.ps1",
    "Master-Cleanup-Launcher.ps1", 
    "Deep-System-Cleanup.ps1",
    "InfiniCoreCipher-Specific-Cleanup.ps1",
    "System-Wide-Duplicate-Hunter.ps1",
    "OneDrive-Check-Script.ps1",
    "OneDrive-Safe-Cleanup.ps1",
    "OneDrive-Quick-Check.ps1",
    "OneDrive-GitHub-Sync.ps1",
    "Run-OneDrive-Cleanup.ps1",
    "GitHub-Auto-Setup.ps1",
    "Diagnose-InfiniCoreCipher.ps1",
    "Fix-InfiniCoreCipher-Scripts.ps1",
    "Test-Fixed-Project.ps1",
    "Copy-Scripts-To-Windows.ps1",
    
    # Dokumentacja
    "README.md",
    "Quick-Start-Guide.md",
    "Complete-Workflow-Guide.md",
    "GitHub-Setup-Guide.md",
    "OneDrive-Cleanup-Recommendations.md",
    "Script-Location-Guide.md",
    "Location-Comparison-Table.md",
    "Step-By-Step-Instructions.md",
    "Windows-Setup-Instructions.md",
    "Security-Best-Practices.md",
    "Quick-Examples.md",
    "File-Analysis-Report.md",
    "Repository-Organization-Recommendations.md",
    "Changes-Analysis.md",
    "Project-Impact-Assessment.md",
    "Strategic-Impact-Final.md",
    "Latest-Changes-Analysis.md",
    "Ultimate-Final-Assessment.md",
    "Final-Recommendations.md",
    
    # Utilities
    "todo.md"
)

Write-Host "📋 Pliki do synchronizacji: $($FilesToSync.Count)" -ForegroundColor Green

foreach ($file in $FilesToSync) {
    $sourcePath = Join-Path $WorkspacePath $file
    $destPath = Join-Path $CleanupToolsPath $file
    
    if (Test-Path $sourcePath) {
        Write-Host "📄 Kopiowanie: $file" -ForegroundColor White
        if (-not $DryRun) {
            Copy-Item $sourcePath $destPath -Force
        }
    } else {
        Write-Host "⚠️ Nie znaleziono: $file" -ForegroundColor Yellow
    }
}

if (-not $DryRun) {
    # Przejdź do repo i sprawdź status
    Set-Location $LocalRepoPath
    Write-Host "`n📊 Status Git:" -ForegroundColor Cyan
    git status --porcelain cleanup-tools/
    
    Write-Host "`n✅ Synchronizacja zakończona!" -ForegroundColor Green
    Write-Host "Następne kroki:" -ForegroundColor Yellow
    Write-Host "1. git add cleanup-tools/" -ForegroundColor White
    Write-Host "2. git commit -m 'Update cleanup tools'" -ForegroundColor White
    Write-Host "3. git push origin main" -ForegroundColor White
} else {
    Write-Host "`n👁️ TRYB PODGLĄDU - nic nie zostało skopiowane" -ForegroundColor Yellow
}