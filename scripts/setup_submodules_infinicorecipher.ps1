#!/usr/bin/env pwsh
# Infinicorecipher Platform Submodule Setup Script
# Automated setup and management for all platform submodules

param(
    [string]$Action = "status",
    [string]$SubmoduleName = "",
    [switch]$InitializeAll = $false,
    [switch]$UpdateAll = $false,
    [switch]$CloneWithSubmodules = $false,
    [switch]$Help = $false
)

if ($Help) {
    Write-Host "🔗 INFINICORECIPHER SUBMODULE MANAGER" -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "ACTIONS:" -ForegroundColor Yellow
    Write-Host "  status      # Show submodule status"
    Write-Host "  init        # Initialize specific submodule"
    Write-Host "  update      # Update specific submodule"
    Write-Host "  health      # Health check all submodules"
    Write-Host "  sync        # Sync all submodules with remote"
    Write-Host ""
    Write-Host "FLAGS:" -ForegroundColor Yellow
    Write-Host "  -InitializeAll        # Initialize all submodules"
    Write-Host "  -UpdateAll           # Update all submodules"
    Write-Host "  -CloneWithSubmodules # Clone main repo with submodules"
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  ./setup_submodules_infinicorecipher.ps1 status"
    Write-Host "  ./setup_submodules_infinicorecipher.ps1 init -SubmoduleName 'future-tech-education'"
    Write-Host "  ./setup_submodules_infinicorecipher.ps1 -InitializeAll"
    Write-Host "  ./setup_submodules_infinicorecipher.ps1 -UpdateAll"
    Write-Host ""
    return
}

Write-Host "🔗 INFINICORECIPHER PLATFORM SUBMODULE MANAGER" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "📅 Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow

# Submodule definitions for Infinicorecipher Platform
$submodules = @{
    "future-tech-education" = @{
        path = "education-content/future-tech-education"
        url = "https://github.com/YourOrg/Infinicorecipher_FutureTechEducation.git"
        sshUrl = "git@github-infinicorecipher:YourOrg/Infinicorecipher_FutureTechEducation.git"
        branch = "main"
        description = "Future Technology Education Content and Curricula"
        priority = "high"
        category = "education"
    }
    "galactic-code" = @{
        path = "applications/galactic-code"
        url = "https://github.com/YourOrg/GalacticCode.git"
        sshUrl = "git@github-infinicorecipher:YourOrg/GalacticCode.git"
        branch = "main"
        description = "GalacticCode Educational Programming Game"
        priority = "critical"
        category = "application"
    }
    "curriculum-standards" = @{
        path = "education-content/curriculum-standards"
        url = "https://github.com/YourOrg/CurriculumStandards.git"
        sshUrl = "git@github-infinicorecipher:YourOrg/CurriculumStandards.git"
        branch = "main"
        description = "Educational Curriculum Standards and Frameworks"
        priority = "high"
        category = "education"
    }
    "assessment-frameworks" = @{
        path = "education-content/assessment-frameworks"
        url = "https://github.com/YourOrg/AssessmentFrameworks.git"
        sshUrl = "git@github-infinicorecipher:YourOrg/AssessmentFrameworks.git"
        branch = "main"
        description = "Assessment Tools and Evaluation Frameworks"
        priority = "medium"
        category = "education"
    }
    "lms-connectors" = @{
        path = "external-integrations/lms-connectors"
        url = "https://github.com/YourOrg/LMSConnectors.git"
        sshUrl = "git@github-infinicorecipher:YourOrg/LMSConnectors.git"
        branch = "main"
        description = "Learning Management System Integration Connectors"
        priority = "medium"
        category = "integration"
    }
    "security-modules" = @{
        path = "platform/security/modules"
        url = "https://github.com/YourOrg/InfinicorecipherSecurityModules.git"
        sshUrl = "git@github-infinicorecipher:YourOrg/InfinicorecipherSecurityModules.git"
        branch = "main"
        description = "Advanced Infinicorecipher Security Modules"
        priority = "critical"
        category = "security"
    }
    "ui-components" = @{
        path = "packages/ui-components-extended"
        url = "https://github.com/YourOrg/InfinicorecipherUIComponents.git"
        sshUrl = "git@github-infinicorecipher:YourOrg/InfinicorecipherUIComponents.git"
        branch = "main"
        description = "Extended UI Components Library"
        priority = "medium"
        category = "frontend"
    }
    "analytics-engines" = @{
        path = "platform/analytics/engines"
        url = "https://github.com/YourOrg/AnalyticsEngines.git"
        sshUrl = "git@github-infinicorecipher:YourOrg/AnalyticsEngines.git"
        branch = "main"
        description = "Advanced Analytics and ML Engines"
        priority = "high"
        category = "analytics"
    }
}

# Function to check if we're in a git repository
function Test-GitRepository {
    try {
        git rev-parse --git-dir | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Function to initialize a specific submodule
function Initialize-Submodule {
    param($name, $config)
    
    Write-Host "🔄 Initializing submodule: $name" -ForegroundColor Yellow
    Write-Host "   Path: $($config.path)" -ForegroundColor Gray
    Write-Host "   Description: $($config.description)" -ForegroundColor Gray
    
    try {
        # Create parent directory if it doesn't exist
        $parentDir = Split-Path $config.path -Parent
        if ($parentDir -and !(Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            Write-Host "   📁 Created parent directory: $parentDir" -ForegroundColor Gray
        }
        
        # Add submodule
        git submodule add $config.url $config.path
        
        # Navigate to submodule and configure
        if (Test-Path $config.path) {
            Push-Location $config.path
            
            # Checkout correct branch
            git checkout $config.branch
            
            # Configure branch tracking
            git config branch.$($config.branch).remote origin
            git config branch.$($config.branch).merge refs/heads/$($config.branch)
            
            # Set up submodule-specific configuration
            git config core.autocrlf false
            git config pull.rebase false
            
            Pop-Location
            
            Write-Host "   ✅ Submodule $name initialized successfully" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Failed to initialize submodule $name" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Error initializing submodule $name : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to update a specific submodule
function Update-Submodule {
    param($name, $config)
    
    Write-Host "🔄 Updating submodule: $name" -ForegroundColor Yellow
    
    try {
        if (Test-Path $config.path) {
            # Update submodule to latest commit
            git submodule update --remote --merge $config.path
            
            # Show latest commit info
            Push-Location $config.path
            $latestCommit = git log -1 --oneline
            $currentBranch = git branch --show-current
            Pop-Location
            
            Write-Host "   ✅ Updated to: $latestCommit" -ForegroundColor Green
            Write-Host "   🌿 Branch: $currentBranch" -ForegroundColor Gray
        } else {
            Write-Host "   ⚠️ Submodule not initialized, initializing now..." -ForegroundColor Yellow
            Initialize-Submodule $name $config
        }
    } catch {
        Write-Host "   ❌ Error updating submodule $name : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to show submodule status
function Show-SubmoduleStatus {
    Write-Host "`n📊 SUBMODULE STATUS" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor Cyan
    
    foreach ($submodule in $submodules.GetEnumerator() | Sort-Object { $_.Value.priority -eq "critical" ? 0 : $_.Value.priority -eq "high" ? 1 : 2 }) {
        $name = $submodule.Key
        $config = $submodule.Value
        
        $priorityIcon = switch ($config.priority) {
            "critical" { "🔴" }
            "high" { "🟡" }
            "medium" { "🟢" }
            default { "⚪" }
        }
        
        $categoryIcon = switch ($config.category) {
            "education" { "🎓" }
            "application" { "🎮" }
            "security" { "🔐" }
            "integration" { "🔗" }
            "frontend" { "⚛️" }
            "analytics" { "📊" }
            default { "📦" }
        }
        
        if (Test-Path $config.path) {
            try {
                Push-Location $config.path
                $currentBranch = git branch --show-current 2>$null
                $latestCommit = git log -1 --oneline 2>$null
                $status = git status --porcelain 2>$null
                Pop-Location
                
                $statusIcon = if ($status) { "⚠️" } else { "✅" }
                $statusText = if ($status) { "Modified" } else { "Clean" }
                
                Write-Host "`n$priorityIcon $categoryIcon $name" -ForegroundColor Green
                Write-Host "   Status: $statusIcon $statusText" -ForegroundColor $(if($status){"Yellow"}else{"Green"})
                Write-Host "   Path: $($config.path)" -ForegroundColor Gray
                Write-Host "   Branch: $currentBranch" -ForegroundColor Gray
                Write-Host "   Latest: $latestCommit" -ForegroundColor Gray
                Write-Host "   Priority: $($config.priority)" -ForegroundColor Gray
            } catch {
                Write-Host "`n$priorityIcon $categoryIcon $name" -ForegroundColor Yellow
                Write-Host "   Status: ⚠️ Error reading status" -ForegroundColor Yellow
                Write-Host "   Path: $($config.path)" -ForegroundColor Gray
            }
        } else {
            Write-Host "`n$priorityIcon $categoryIcon $name" -ForegroundColor Red
            Write-Host "   Status: ❌ Not initialized" -ForegroundColor Red
            Write-Host "   Path: $($config.path)" -ForegroundColor Gray
            Write-Host "   Description: $($config.description)" -ForegroundColor Gray
        }
    }
}

# Function to perform health check
function Invoke-HealthCheck {
    Write-Host "`n🔍 SUBMODULE HEALTH CHECK" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    
    $healthReport = @{
        total = $submodules.Count
        initialized = 0
        upToDate = 0
        modified = 0
        errors = 0
        critical_issues = 0
    }
    
    foreach ($submodule in $submodules.GetEnumerator()) {
        $name = $submodule.Key
        $config = $submodule.Value
        
        if (Test-Path $config.path) {
            $healthReport.initialized++
            
            try {
                Push-Location $config.path
                
                # Check for uncommitted changes
                $status = git status --porcelain 2>$null
                if ($status) {
                    $healthReport.modified++
                    Write-Host "⚠️ $name has uncommitted changes" -ForegroundColor Yellow
                }
                
                # Check if up to date with remote
                git fetch origin 2>$null
                $behind = git rev-list HEAD..origin/$($config.branch) --count 2>$null
                if ($behind -and $behind -gt 0) {
                    Write-Host "📥 $name is $behind commits behind remote" -ForegroundColor Yellow
                } else {
                    $healthReport.upToDate++
                }
                
                # Check for critical submodules
                if ($config.priority -eq "critical" -and ($status -or ($behind -and $behind -gt 0))) {
                    $healthReport.critical_issues++
                    Write-Host "🔴 CRITICAL: $name has issues and is marked as critical priority" -ForegroundColor Red
                }
                
                Pop-Location
            } catch {
                $healthReport.errors++
                Write-Host "❌ Error checking $name : $($_.Exception.Message)" -ForegroundColor Red
                Pop-Location
            }
        } else {
            Write-Host "❌ $name is not initialized" -ForegroundColor Red
            if ($config.priority -eq "critical") {
                $healthReport.critical_issues++
                Write-Host "🔴 CRITICAL: $name is not initialized and is marked as critical priority" -ForegroundColor Red
            }
        }
    }
    
    # Health summary
    Write-Host "`n📊 HEALTH SUMMARY" -ForegroundColor Cyan
    Write-Host "=================" -ForegroundColor Cyan
    Write-Host "Total submodules: $($healthReport.total)" -ForegroundColor White
    Write-Host "Initialized: $($healthReport.initialized)" -ForegroundColor $(if($healthReport.initialized -eq $healthReport.total){"Green"}else{"Yellow"})
    Write-Host "Up to date: $($healthReport.upToDate)" -ForegroundColor $(if($healthReport.upToDate -eq $healthReport.initialized){"Green"}else{"Yellow"})
    Write-Host "Modified: $($healthReport.modified)" -ForegroundColor $(if($healthReport.modified -eq 0){"Green"}else{"Yellow"})
    Write-Host "Errors: $($healthReport.errors)" -ForegroundColor $(if($healthReport.errors -eq 0){"Green"}else{"Red"})
    Write-Host "Critical issues: $($healthReport.critical_issues)" -ForegroundColor $(if($healthReport.critical_issues -eq 0){"Green"}else{"Red"})
    
    # Overall health score
    $healthScore = [math]::Round((($healthReport.upToDate / [math]::Max($healthReport.initialized, 1)) * 100), 1)
    Write-Host "`n🎯 OVERALL HEALTH: $healthScore%" -ForegroundColor $(if($healthScore -ge 90){"Green"}elseif($healthScore -ge 70){"Yellow"}else{"Red"})
    
    if ($healthReport.critical_issues -gt 0) {
        Write-Host "🚨 IMMEDIATE ACTION REQUIRED: Critical submodules have issues!" -ForegroundColor Red
    }
}

# Function to sync all submodules
function Sync-AllSubmodules {
    Write-Host "`n🔄 SYNCING ALL SUBMODULES" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    
    # Update all submodules
    Write-Host "📥 Fetching latest changes..." -ForegroundColor Blue
    git submodule update --remote --merge
    
    # Show summary
    Write-Host "`n📋 SYNC SUMMARY" -ForegroundColor Cyan
    git submodule foreach 'echo "📦 $name - Branch: $(git branch --show-current) - Latest: $(git log -1 --oneline)"'
    
    Write-Host "`n✅ Sync completed!" -ForegroundColor Green
}

# Function to generate .gitmodules file
function Generate-GitmodulesFile {
    Write-Host "📝 Generating .gitmodules file..." -ForegroundColor Blue
    
    $gitmodulesContent = @"
# Infinicorecipher Platform Submodules Configuration
# Generated automatically by setup_submodules_infinicorecipher.ps1
# Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

"@

    foreach ($submodule in $submodules.GetEnumerator() | Sort-Object { $_.Value.category }) {
        $name = $submodule.Key
        $config = $submodule.Value
        
        $gitmodulesContent += @"
[submodule "$($config.path)"]
    path = $($config.path)
    url = $($config.url)
    branch = $($config.branch)
    update = merge
    fetchRecurseSubmodules = true
    ignore = dirty

"@
    }
    
    Set-Content -Path ".gitmodules" -Value $gitmodulesContent -Encoding UTF8
    Write-Host "✅ .gitmodules file generated" -ForegroundColor Green
}

# MAIN EXECUTION LOGIC

# Check if we're in a git repository
if (!(Test-GitRepository)) {
    Write-Host "❌ Not in a Git repository. Please run this script from the root of Infinicorecipher_Platform repository." -ForegroundColor Red
    return
}

# Handle clone with submodules
if ($CloneWithSubmodules) {
    Write-Host "🔄 Setting up repository with submodules..." -ForegroundColor Blue
    git submodule update --init --recursive
    Write-Host "✅ Repository setup with submodules complete!" -ForegroundColor Green
    return
}

# Handle initialize all
if ($InitializeAll) {
    Write-Host "🚀 Initializing all submodules..." -ForegroundColor Blue
    
    # Generate .gitmodules first
    Generate-GitmodulesFile
    
    # Initialize each submodule
    foreach ($submodule in $submodules.GetEnumerator() | Sort-Object { $_.Value.priority -eq "critical" ? 0 : 1 }) {
        Initialize-Submodule $submodule.Key $submodule.Value
    }
    
    # Final submodule initialization
    git submodule init
    git submodule update
    
    Write-Host "`n🎉 All submodules initialized!" -ForegroundColor Green
    return
}

# Handle update all
if ($UpdateAll) {
    Write-Host "🔄 Updating all submodules..." -ForegroundColor Blue
    
    foreach ($submodule in $submodules.GetEnumerator()) {
        Update-Submodule $submodule.Key $submodule.Value
    }
    
    Write-Host "`n🎉 All submodules updated!" -ForegroundColor Green
    return
}

# Handle specific actions
switch ($Action.ToLower()) {
    "status" {
        Show-SubmoduleStatus
    }
    "init" {
        if ($SubmoduleName -and $submodules.ContainsKey($SubmoduleName)) {
            Initialize-Submodule $SubmoduleName $submodules[$SubmoduleName]
        } elseif ($SubmoduleName) {
            Write-Host "❌ Unknown submodule: $SubmoduleName" -ForegroundColor Red
            Write-Host "Available submodules: $($submodules.Keys -join ', ')" -ForegroundColor Yellow
        } else {
            Write-Host "❌ Please specify submodule name with -SubmoduleName" -ForegroundColor Red
        }
    }
    "update" {
        if ($SubmoduleName -and $submodules.ContainsKey($SubmoduleName)) {
            Update-Submodule $SubmoduleName $submodules[$SubmoduleName]
        } elseif ($SubmoduleName) {
            Write-Host "❌ Unknown submodule: $SubmoduleName" -ForegroundColor Red
            Write-Host "Available submodules: $($submodules.Keys -join ', ')" -ForegroundColor Yellow
        } else {
            Write-Host "❌ Please specify submodule name with -SubmoduleName" -ForegroundColor Red
        }
    }
    "health" {
        Invoke-HealthCheck
    }
    "sync" {
        Sync-AllSubmodules
    }
    "generate-gitmodules" {
        Generate-GitmodulesFile
    }
    default {
        Write-Host "❌ Unknown action: $Action" -ForegroundColor Red
        Write-Host "Available actions: status, init, update, health, sync, generate-gitmodules" -ForegroundColor Yellow
        Write-Host "Use -Help for detailed usage information" -ForegroundColor Gray
    }
}

Write-Host "`n💡 Tip: Use './setup_submodules_infinicorecipher.ps1 -Help' for detailed usage information" -ForegroundColor Gray