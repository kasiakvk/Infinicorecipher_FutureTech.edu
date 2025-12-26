# PowerShell script to clean up legacy structure after migration

Write-Host "🧹 Cleaning Up Legacy Repository Structure..." -ForegroundColor Green

# Function to safely remove files/folders after confirmation
function Safe-Remove {
    param(
        [string]$Path,
        [string]$Description,
        [bool]$Force = $false
    )
    
    if (Test-Path $Path) {
        if (!$Force) {
            $response = Read-Host "Remove $Description at '$Path'? (y/N)"
            if ($response -ne 'y' -and $response -ne 'Y') {
                Write-Host "  ⏭️ Skipped: $Description" -ForegroundColor Yellow
                return
            }
        }
        
        try {
            Remove-Item -Path $Path -Recurse -Force
            Write-Host "  ✓ Removed: $Description" -ForegroundColor Gray
        }
        catch {
            Write-Host "  ⚠ Failed to remove: $Description - $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "  ℹ️ Not found: $Description" -ForegroundColor Gray
    }
}

# Function to move remaining files to appropriate locations
function Move-Remaining {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Description
    )
    
    if (Test-Path $Source) {
        $destDir = Split-Path $Destination -Parent
        if (!(Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        try {
            Move-Item -Path $Source -Destination $Destination -Force
            Write-Host "  ✓ Moved: $Description" -ForegroundColor Gray
        }
        catch {
            Write-Host "  ⚠ Failed to move: $Description - $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

Write-Host "📋 Starting cleanup process..." -ForegroundColor Yellow
Write-Host "⚠️ This will clean up legacy files after migration to Infinicore platform structure." -ForegroundColor Red
Write-Host "📦 Make sure you've run the migration scripts first!" -ForegroundColor Cyan

$proceed = Read-Host "`nProceed with cleanup? (y/N)"
if ($proceed -ne 'y' -and $proceed -ne 'Y') {
    Write-Host "❌ Cleanup cancelled." -ForegroundColor Red
    exit
}

# Check if platform structure exists
if (!(Test-Path "platform") -or !(Test-Path "applications\galactic-code")) {
    Write-Host "❌ Platform structure not found!" -ForegroundColor Red
    Write-Host "📋 Please run these scripts first:" -ForegroundColor Yellow
    Write-Host "  1. .\setup_infinicore_platform.ps1" -ForegroundColor White
    Write-Host "  2. .\create_platform_configs.ps1" -ForegroundColor White
    Write-Host "  3. .\migrate_galacticcode_to_platform.ps1" -ForegroundColor White
    exit
}

Write-Host "`n🔄 Moving remaining files to proper locations..." -ForegroundColor Cyan

# Move root HTML files to GalacticCode web client
Move-Remaining "index.html" "applications\galactic-code\web-client\src\pages\index.html" "Main index page"
Move-Remaining "game.html" "applications\galactic-code\web-client\src\pages\game.html" "Game page"
Move-Remaining "privacy.html" "applications\galactic-code\web-client\src\pages\privacy.html" "Privacy page"
Move-Remaining "terms.html" "applications\galactic-code\web-client\src\pages\terms.html" "Terms page"

# Move legacy Unity project
Move-Remaining "GalacticCode-Unity" "applications\galactic-code\unity-client\legacy-project" "Legacy Unity project"

# Move legacy web assets
Move-Remaining "galactic_code_pack" "applications\galactic-code\web-client\legacy-pack" "Legacy web pack"

# Move website directory
Move-Remaining "GalacticCode_Universe-Website" "applications\galactic-code\web-client\legacy-website" "Legacy website"

Write-Host "`n🗑️ Removing duplicate and legacy directories..." -ForegroundColor Cyan

# Remove old core directory if it's been moved to platform
if (Test-Path "platform\security\infinicorecipher" -and Test-Path "core\infinicorecipher") {
    Safe-Remove "core" "Legacy core directory (moved to platform/security)"
}

# Remove old applications structure if properly migrated
if (Test-Path "applications\galactic-code\web-client" -and Test-Path "applications\web-client") {
    Safe-Remove "applications\web-client" "Legacy web-client (moved to galactic-code/web-client)"
}

if (Test-Path "applications\galactic-code\unity-client" -and Test-Path "applications\unity-client") {
    Safe-Remove "applications\unity-client" "Legacy unity-client (moved to galactic-code/unity-client)"
}

if (Test-Path "applications\galactic-code\mobile-client" -and Test-Path "applications\mobile-client") {
    Safe-Remove "applications\mobile-client" "Legacy mobile-client (moved to galactic-code/mobile-client)"
}

# Remove old service directories if migrated
$oldServices = @(
    @{ Path = "services\api-service"; New = "services\platform-gateway" },
    @{ Path = "services\web-gateway"; New = "services\platform-gateway" }
)

foreach ($service in $oldServices) {
    if (Test-Path $service.New -and Test-Path $service.Path) {
        Safe-Remove $service.Path "Legacy service directory (migrated to $($service.New))"
    }
}

Write-Host "`n📄 Updating configuration files..." -ForegroundColor Cyan

# Update .gitignore for new structure
$gitignorePath = ".gitignore"
$gitignoreAdditions = @(
    "",
    "# Infinicore Platform",
    "platform/security/infinicorecipher/lib/*.so",
    "platform/security/infinicorecipher/lib/*.dll",
    "platform/security/infinicorecipher/lib/*.dylib",
    "platform/security/infinicorecipher/lib/*.a",
    "platform/security/infinicorecipher/lib/*.lib",
    "platform/security/infinicorecipher/lib/*.o",
    "platform/security/infinicorecipher/lib/*.obj",
    "",
    "# Application builds",
    "applications/*/build/",
    "applications/*/dist/",
    "applications/*/node_modules/",
    "",
    "# Platform services",
    "services/*/bin/",
    "services/*/obj/",
    "services/*/node_modules/",
    "",
    "# Development environment",
    ".env.local",
    ".env.development",
    ".env.staging",
    "docker-compose.override.yml",
    ""
)

if (Test-Path $gitignorePath) {
    $currentGitignore = Get-Content $gitignorePath
    $needsUpdate = $false
    
    foreach ($addition in $gitignoreAdditions) {
        if ($addition -and $currentGitignore -notcontains $addition) {
            $needsUpdate = $true
            break
        }
    }
    
    if ($needsUpdate) {
        $gitignoreAdditions | Add-Content $gitignorePath
        Write-Host "  ✓ Updated .gitignore for platform structure" -ForegroundColor Gray
    }
}

# Create platform-specific README if main README is outdated
if (Test-Path "README-PLATFORM.md" -and (Test-Path "README.md")) {
    $updateReadme = Read-Host "Replace README.md with platform version? (y/N)"
    if ($updateReadme -eq 'y' -or $updateReadme -eq 'Y') {
        Copy-Item "README-PLATFORM.md" "README.md" -Force
        Remove-Item "README-PLATFORM.md" -Force
        Write-Host "  ✓ Updated README.md with platform information" -ForegroundColor Gray
    }
}

Write-Host "`n🔍 Verifying cleanup..." -ForegroundColor Cyan

# Verify platform structure is intact
$platformChecks = @(
    "platform\security",
    "platform\education-core",
    "applications\galactic-code",
    "services\platform-gateway",
    "platform.config.json",
    "PLATFORM_MANIFEST.md"
)

$allGood = $true
foreach ($check in $platformChecks) {
    if (Test-Path $check) {
        Write-Host "  ✅ $check" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Missing: $check" -ForegroundColor Red
        $allGood = $false
    }
}

Write-Host "`n📊 Cleanup Summary:" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "✅ Cleanup completed successfully!" -ForegroundColor Green
    Write-Host "`n🎯 Your repository now has:" -ForegroundColor Yellow
    Write-Host "  • Clean Infinicore platform structure" -ForegroundColor White
    Write-Host "  • GalacticCode properly organized as platform application" -ForegroundColor White
    Write-Host "  • Platform services ready for development" -ForegroundColor White
    Write-Host "  • Educational framework infrastructure" -ForegroundColor White
    Write-Host "  • Professional directory organization" -ForegroundColor White
} else {
    Write-Host "⚠️ Cleanup completed with some issues." -ForegroundColor Yellow
    Write-Host "📋 Please check missing components and re-run migration scripts if needed." -ForegroundColor Cyan
}

Write-Host "`n🚀 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Install platform dependencies: npm install" -ForegroundColor White
Write-Host "  2. Start development environment: npm run dev" -ForegroundColor White
Write-Host "  3. Test GalacticCode integration: http://localhost:3000" -ForegroundColor White
Write-Host "  4. Configure educational framework settings" -ForegroundColor White
Write-Host "  5. Begin development of additional educational games" -ForegroundColor White

Write-Host "`n📝 Commit Changes:" -ForegroundColor Cyan
Write-Host "  git add ." -ForegroundColor White
Write-Host "  git commit -m 'Complete migration to Infinicore educational platform structure'" -ForegroundColor White

Write-Host "`n🎓 Welcome to the Infinicore Educational Platform!" -ForegroundColor Green
Write-Host "Your repository is now ready for enterprise-scale educational game development." -ForegroundColor White