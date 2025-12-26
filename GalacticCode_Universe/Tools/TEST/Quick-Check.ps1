# Quick-Check.ps1
# Szybkie sprawdzenie stanu projektu Infinicorecipher

param(
    [string]$Path = "D:\Infinicorecipher-Startup"
)

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

Write-Host "🔍 SZYBKIE SPRAWDZENIE PROJEKTU INFINICORECIPHER" -ForegroundColor $Cyan
Write-Host "Lokalizacja: $Path" -ForegroundColor $Yellow
Write-Host ""

# Sprawdź czy folder istnieje
if (-not (Test-Path $Path)) {
    Write-Host "❌ Folder nie istnieje: $Path" -ForegroundColor $Red
    Write-Host ""
    Write-Host "💡 Aby utworzyć projekt, uruchom:" -ForegroundColor $Yellow
    Write-Host "   .\Setup-InfinicocipherProject.ps1" -ForegroundColor $Yellow
    exit 1
}

Push-Location $Path

try {
    # Sprawdź podstawowe pliki
    $BasicFiles = @("package.json", "README.md", "frontend", "backend")
    $BasicOK = $true
    
    Write-Host "📋 Podstawowe pliki:" -ForegroundColor $Cyan
    foreach ($File in $BasicFiles) {
        if (Test-Path $File) {
            Write-Host "  ✅ $File" -ForegroundColor $Green
        } else {
            Write-Host "  ❌ $File" -ForegroundColor $Red
            $BasicOK = $false
        }
    }
    
    # Sprawdź node_modules
    Write-Host ""
    Write-Host "📦 Zależności npm:" -ForegroundColor $Cyan
    
    $RootModules = Test-Path "node_modules"
    $FrontendModules = Test-Path "frontend/node_modules"
    $BackendModules = Test-Path "backend/node_modules"
    
    Write-Host "  $(if($RootModules){'✅'}else{'❌'}) Root node_modules" -ForegroundColor $(if($RootModules){$Green}else{$Red})
    Write-Host "  $(if($FrontendModules){'✅'}else{'❌'}) Frontend node_modules" -ForegroundColor $(if($FrontendModules){$Green}else{$Red})
    Write-Host "  $(if($BackendModules){'✅'}else{'❌'}) Backend node_modules" -ForegroundColor $(if($BackendModules){$Green}else{$Red})
    
    # Sprawdź rozmiar projektu
    $ProjectSize = (Get-ChildItem -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $ProjectSizeMB = [math]::Round($ProjectSize / 1MB, 2)
    $FileCount = (Get-ChildItem -Recurse -File).Count
    
    Write-Host ""
    Write-Host "📊 Statystyki:" -ForegroundColor $Cyan
    Write-Host "  📁 Rozmiar: $ProjectSizeMB MB" -ForegroundColor $Yellow
    Write-Host "  📄 Pliki: $FileCount" -ForegroundColor $Yellow
    
    # Sprawdź czy można uruchomić
    Write-Host ""
    Write-Host "🚀 Gotowość do uruchomienia:" -ForegroundColor $Cyan
    
    $CanRun = $BasicOK -and $RootModules -and $FrontendModules -and $BackendModules
    
    if ($CanRun) {
        Write-Host "  ✅ Projekt gotowy do uruchomienia!" -ForegroundColor $Green
        Write-Host ""
        Write-Host "💡 Aby uruchomić projekt:" -ForegroundColor $Yellow
        Write-Host "   cd `"$Path`"" -ForegroundColor $Yellow
        Write-Host "   npm run dev" -ForegroundColor $Yellow
    } else {
        Write-Host "  ❌ Projekt wymaga konfiguracji" -ForegroundColor $Red
        Write-Host ""
        Write-Host "💡 Aby skonfigurować projekt:" -ForegroundColor $Yellow
        
        if (-not $BasicOK) {
            Write-Host "   .\Copy-InfinicocipherProject.ps1" -ForegroundColor $Yellow
        }
        
        if (-not ($RootModules -and $FrontendModules -and $BackendModules)) {
            Write-Host "   cd `"$Path`"" -ForegroundColor $Yellow
            Write-Host "   npm run install:all" -ForegroundColor $Yellow
        }
    }
    
    # Sprawdź uruchomione procesy
    $NodeProcesses = Get-Process node -ErrorAction SilentlyContinue
    if ($NodeProcesses) {
        Write-Host ""
        Write-Host "🔄 Uruchomione procesy Node.js:" -ForegroundColor $Cyan
        foreach ($Process in $NodeProcesses) {
            Write-Host "  🟢 PID: $($Process.Id) - $($Process.ProcessName)" -ForegroundColor $Green
        }
    }
    
    # Sprawdź porty
    $Port3000 = netstat -ano | Select-String ":3000" -Quiet
    $Port5000 = netstat -ano | Select-String ":5000" -Quiet
    
    if ($Port3000 -or $Port5000) {
        Write-Host ""
        Write-Host "🌐 Zajęte porty:" -ForegroundColor $Cyan
        if ($Port3000) { Write-Host "  🟢 Port 3000 (Frontend)" -ForegroundColor $Green }
        if ($Port5000) { Write-Host "  🟢 Port 5000 (Backend)" -ForegroundColor $Green }
        
        if ($Port3000 -and $Port5000) {
            Write-Host ""
            Write-Host "🎉 Projekt prawdopodobnie już działa!" -ForegroundColor $Green
            Write-Host "   Frontend: http://localhost:3000" -ForegroundColor $Yellow
            Write-Host "   Backend:  http://localhost:5000" -ForegroundColor $Yellow
        }
    }
    
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "=== KONIEC SPRAWDZENIA ===" -ForegroundColor $Cyan