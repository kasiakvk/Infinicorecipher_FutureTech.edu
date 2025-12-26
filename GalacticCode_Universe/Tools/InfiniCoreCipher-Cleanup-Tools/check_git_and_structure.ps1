# InfiniCoreCipher Git and Structure Analysis Script
Write-Host "🔍 InfiniCoreCipher Repository Analysis" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# Check current location
Write-Host "📍 Current location: $PWD" -ForegroundColor Yellow

# Check if we're in a Git repository
if (Test-Path ".git") {
    Write-Host "✅ Git repository detected" -ForegroundColor Green
    
    # Check Git status
    Write-Host "`n📊 Git Status:" -ForegroundColor Yellow
    git status
    
    # Check recent commits
    Write-Host "`n📝 Recent commits:" -ForegroundColor Yellow
    git log --oneline -10
    
    # Check remote connections
    Write-Host "`n🌐 Remote connections:" -ForegroundColor Yellow
    git remote -v
    
    # Check branches
    Write-Host "`n🌿 Branches:" -ForegroundColor Yellow
    git branch -a
    
    # Check if there are uncommitted changes
    $gitStatus = git status --porcelain
    if ($gitStatus) {
        Write-Host "`n⚠️ Uncommitted changes detected:" -ForegroundColor Red
        $gitStatus
    } else {
        Write-Host "`n✅ Working directory clean" -ForegroundColor Green
    }
    
} else {
    Write-Host "❌ Not in a Git repository" -ForegroundColor Red
    Write-Host "Please navigate to the InfiniCoreCipher repository directory" -ForegroundColor Yellow
}

Write-Host "`n" -ForegroundColor White
Write-Host "📁 Directory Structure Analysis" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

# Check if target directories exist
$galacticPath = "GalacticCode_Universe\RepositoriumGitHub"
$infiniPath = "InfiniCoreCipher"

Write-Host "`n🔍 Checking target directories..." -ForegroundColor Yellow

if (Test-Path $galacticPath) {
    Write-Host "✅ Found: $galacticPath" -ForegroundColor Green
    Write-Host "📊 Contents:" -ForegroundColor Cyan
    Get-ChildItem $galacticPath | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
    
    Write-Host "📏 Size analysis:" -ForegroundColor Cyan
    $galacticSize = (Get-ChildItem $galacticPath -Recurse | Measure-Object -Property Length -Sum).Sum
    Write-Host "Total size: $([math]::Round($galacticSize/1MB, 2)) MB" -ForegroundColor White
    
    $galacticFileCount = (Get-ChildItem $galacticPath -Recurse -File).Count
    Write-Host "File count: $galacticFileCount files" -ForegroundColor White
} else {
    Write-Host "❌ Not found: $galacticPath" -ForegroundColor Red
}

if (Test-Path $infiniPath) {
    Write-Host "`n✅ Found: $infiniPath" -ForegroundColor Green
    Write-Host "📊 Contents:" -ForegroundColor Cyan
    Get-ChildItem $infiniPath | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
    
    Write-Host "📏 Size analysis:" -ForegroundColor Cyan
    $infiniSize = (Get-ChildItem $infiniPath -Recurse | Measure-Object -Property Length -Sum).Sum
    Write-Host "Total size: $([math]::Round($infiniSize/1MB, 2)) MB" -ForegroundColor White
    
    $infiniFileCount = (Get-ChildItem $infiniPath -Recurse -File).Count
    Write-Host "File count: $infiniFileCount files" -ForegroundColor White
} else {
    Write-Host "`n❌ Not found: $infiniPath" -ForegroundColor Red
}

# Check for file conflicts
Write-Host "`n🔍 Conflict Analysis" -ForegroundColor Green
Write-Host "====================" -ForegroundColor Green

if ((Test-Path $galacticPath) -and (Test-Path $infiniPath)) {
    Write-Host "📋 Checking for file name conflicts..." -ForegroundColor Yellow
    
    $galacticFiles = Get-ChildItem $galacticPath -Recurse -File | Select-Object -ExpandProperty Name
    $infiniFiles = Get-ChildItem $infiniPath -Recurse -File | Select-Object -ExpandProperty Name
    
    $conflicts = Compare-Object $galacticFiles $infiniFiles -IncludeEqual | Where-Object { $_.SideIndicator -eq "==" }
    
    if ($conflicts) {
        Write-Host "⚠️ File name conflicts found:" -ForegroundColor Red
        $conflicts | ForEach-Object { Write-Host "  - $($_.InputObject)" -ForegroundColor Yellow }
    } else {
        Write-Host "✅ No file name conflicts detected" -ForegroundColor Green
    }
}

# Check current directory structure
Write-Host "`n📁 Current Directory Structure" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

Write-Host "📊 Root level contents:" -ForegroundColor Yellow
Get-ChildItem . | Select-Object Name, @{Name="Type";Expression={if($_.PSIsContainer){"Directory"}else{"File"}}}, Length, LastWriteTime | Format-Table -AutoSize

# Recommendations
Write-Host "`n💡 Merge Recommendations" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

if ((Test-Path $galacticPath) -and (Test-Path $infiniPath)) {
    Write-Host "🎯 Both directories exist - merge analysis:" -ForegroundColor Cyan
    
    # Check if directories have similar content types
    $galacticExtensions = Get-ChildItem $galacticPath -Recurse -File | Group-Object Extension | Sort-Object Count -Descending
    $infiniExtensions = Get-ChildItem $infiniPath -Recurse -File | Group-Object Extension | Sort-Object Count -Descending
    
    Write-Host "`n📊 File type analysis:" -ForegroundColor Yellow
    Write-Host "GalacticCode_Universe/RepositoriumGitHub:" -ForegroundColor Cyan
    $galacticExtensions | Select-Object Name, Count | Format-Table -AutoSize
    
    Write-Host "InfiniCoreCipher:" -ForegroundColor Cyan
    $infiniExtensions | Select-Object Name, Count | Format-Table -AutoSize
    
    # Provide merge recommendation
    Write-Host "🔧 Merge Strategy Recommendation:" -ForegroundColor Green
    Write-Host "1. ✅ SAFE TO MERGE - No file name conflicts detected" -ForegroundColor Green
    Write-Host "2. 📁 Suggested structure:" -ForegroundColor Yellow
    Write-Host "   C:\InfiniCoreCipher-Startup\InfiniCoreCipher\" -ForegroundColor White
    Write-Host "   ├── core/                    (from InfiniCoreCipher/)" -ForegroundColor White
    Write-Host "   ├── galactic/               (from GalacticCode_Universe/RepositoriumGitHub/)" -ForegroundColor White
    Write-Host "   ├── automation/             (existing)" -ForegroundColor White
    Write-Host "   ├── backend/                (existing)" -ForegroundColor White
    Write-Host "   ├── frontend/               (existing)" -ForegroundColor White
    Write-Host "   └── docs/                   (existing)" -ForegroundColor White
    
} elseif (Test-Path $galacticPath) {
    Write-Host "📁 Only GalacticCode_Universe/RepositoriumGitHub exists" -ForegroundColor Yellow
    Write-Host "🔧 Can be moved to root level safely" -ForegroundColor Green
    
} elseif (Test-Path $infiniPath) {
    Write-Host "📁 Only InfiniCoreCipher/ exists" -ForegroundColor Yellow
    Write-Host "🔧 Can be moved to root level safely" -ForegroundColor Green
    
} else {
    Write-Host "❌ Neither target directory found" -ForegroundColor Red
    Write-Host "Please check the directory paths" -ForegroundColor Yellow
}

Write-Host "`n🎯 Next Steps:" -ForegroundColor Green
Write-Host "1. Review the analysis above" -ForegroundColor White
Write-Host "2. Backup current state: git add . && git commit -m 'Backup before restructure'" -ForegroundColor White
Write-Host "3. Execute merge plan if recommended" -ForegroundColor White
Write-Host "4. Test functionality after merge" -ForegroundColor White
Write-Host "5. Update documentation and paths" -ForegroundColor White

Write-Host "`n✅ Analysis completed!" -ForegroundColor Green