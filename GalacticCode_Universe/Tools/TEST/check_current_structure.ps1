# PowerShell script to analyze current repository structure and suggest corrections

Write-Host "🔍 Analyzing Current Repository Structure..." -ForegroundColor Green

# Function to check if path exists and report
function Check-Path {
    param(
        [string]$Path,
        [string]$Description,
        [string]$Status = "Expected"
    )
    
    $exists = Test-Path $Path
    $icon = if ($exists) { "✅" } else { "❌" }
    $color = if ($exists) { "Green" } else { "Red" }
    
    Write-Host "  $icon $Description" -ForegroundColor $color
    if (!$exists -and $Status -eq "Expected") {
        Write-Host "    Missing: $Path" -ForegroundColor Yellow
    }
    return $exists
}

Write-Host "`n📋 Current Structure Analysis:" -ForegroundColor Cyan

# Check current structure
Write-Host "`n🏗️ Infrastructure & Core:" -ForegroundColor Yellow
Check-Path "core" "Core infrastructure directory"
Check-Path "core\infinicorecipher" "Infinicorecipher security module"
Check-Path "core\networking" "Networking infrastructure"
Check-Path "infrastructure" "Infrastructure directory"
Check-Path "services" "Services directory"

Write-Host "`n🎮 Applications:" -ForegroundColor Yellow
Check-Path "applications" "Applications directory"
Check-Path "applications\web-client" "Web client application"
Check-Path "applications\unity-client" "Unity client application"
Check-Path "applications\mobile-client" "Mobile client application"

Write-Host "`n🧪 Testing & Documentation:" -ForegroundColor Yellow
Check-Path "testing" "Testing directory"
Check-Path "Documentation" "Documentation directory"

Write-Host "`n⚠️ Issues Identified:" -ForegroundColor Red

# Check for issues in current structure
$issues = @()

# Issue 1: Missing Infinicore Platform structure
if (!(Test-Path "platform")) {
    $issues += "Missing 'platform' directory for Infinicore platform core"
}

# Issue 2: GalacticCode not properly organized as platform application
if (!(Test-Path "applications\galactic-code")) {
    $issues += "GalacticCode not organized as platform application"
}

# Issue 3: Scattered files in root
$rootFiles = @("index.html", "game.html", "privacy.html", "terms.html")
foreach ($file in $rootFiles) {
    if (Test-Path $file) {
        $issues += "Root file '$file' should be moved to applications/galactic-code/web-client/"
    }
}

# Issue 4: Legacy Unity project location
if (Test-Path "GalacticCode-Unity") {
    $issues += "Unity project 'GalacticCode-Unity' should be moved to applications/galactic-code/unity-client/"
}

# Issue 5: Legacy web assets
if (Test-Path "galactic_code_pack") {
    $issues += "Legacy pack 'galactic_code_pack' should be moved to applications/galactic-code/web-client/legacy/"
}

# Issue 6: Website directory
if (Test-Path "GalacticCode_Universe-Website") {
    $issues += "Website directory should be integrated into applications/galactic-code/web-client/"
}

# Issue 7: Missing platform configuration
if (!(Test-Path "platform.config.json")) {
    $issues += "Missing platform.config.json configuration file"
}

# Issue 8: Missing platform services
$platformServices = @("platform-gateway", "auth-service", "user-service", "analytics-service")
foreach ($service in $platformServices) {
    if (!(Test-Path "services\$service")) {
        $issues += "Missing platform service: services/$service"
    }
}

# Display issues
if ($issues.Count -gt 0) {
    foreach ($issue in $issues) {
        Write-Host "  ❌ $issue" -ForegroundColor Red
    }
} else {
    Write-Host "  ✅ No major issues found!" -ForegroundColor Green
}

Write-Host "`n📊 Structure Comparison:" -ForegroundColor Cyan

Write-Host "`n🔴 Current Structure (Needs Improvement):" -ForegroundColor Red
Write-Host @"
GalacticCode_Universe/
├── Documentation/                # ✅ Good
├── applications/                 # ✅ Good start
│   ├── web-client/               # ⚠️ Should be galactic-code/web-client/
│   ├── mobile-client/            # ⚠️ Should be galactic-code/mobile-client/
│   └── unity-client/             # ⚠️ Should be galactic-code/unity-client/
├── core/                         # ⚠️ Should be platform/security/
├── infrastructure/               # ✅ Good
├── services/                     # ⚠️ Missing platform services
├── Scripts/                      # ✅ Good (scripts/)
├── galactic_code_pack/           # ❌ Should be moved
├── GalacticCode-Unity/           # ❌ Should be moved
├── index.html, game.html         # ❌ Should be moved
└── package.json                  # ✅ Good
"@ -ForegroundColor Gray

Write-Host "`n🟢 Recommended Infinicore Platform Structure:" -ForegroundColor Green
Write-Host @"
Infinicore_Platform/
├── platform/                    # Platform core infrastructure
│   ├── security/                # Infinicorecipher integration
│   ├── education-core/          # Educational framework
│   └── analytics/               # Platform analytics
├── applications/                # Educational applications
│   └── galactic-code/           # GalacticCode game
│       ├── web-client/          # Web interface
│       ├── unity-client/        # Unity game
│       ├── mobile-client/       # Mobile app
│       └── config/              # Game configuration
├── services/                    # Platform microservices
│   ├── platform-gateway/        # Main API gateway
│   ├── auth-service/            # Authentication
│   ├── user-service/            # User management
│   └── analytics-service/       # Learning analytics
├── infrastructure/              # Cloud infrastructure
├── testing/                     # Comprehensive testing
├── documentation/               # Platform documentation
└── tools/                       # Development tools
"@ -ForegroundColor Gray

Write-Host "`n🔧 Recommended Actions:" -ForegroundColor Yellow

Write-Host "`n1. 🏗️ Create Infinicore Platform Structure:" -ForegroundColor Cyan
Write-Host "   .\setup_infinicore_platform.ps1" -ForegroundColor White

Write-Host "`n2. ⚙️ Configure Platform Services:" -ForegroundColor Cyan
Write-Host "   .\create_platform_configs.ps1" -ForegroundColor White

Write-Host "`n3. 🌌 Migrate GalacticCode Properly:" -ForegroundColor Cyan
Write-Host "   .\migrate_galacticcode_to_platform.ps1" -ForegroundColor White

Write-Host "`n4. 🧹 Clean Up Legacy Structure:" -ForegroundColor Cyan
Write-Host "   .\cleanup_legacy_structure.ps1" -ForegroundColor White

Write-Host "`n💡 Benefits of Proper Structure:" -ForegroundColor Green
Write-Host "  ✅ Clear separation between platform and applications" -ForegroundColor White
Write-Host "  ✅ Scalable architecture for multiple educational games" -ForegroundColor White
Write-Host "  ✅ Professional organization for team collaboration" -ForegroundColor White
Write-Host "  ✅ Educational framework integration" -ForegroundColor White
Write-Host "  ✅ Platform services for authentication, analytics, etc." -ForegroundColor White

Write-Host "`n🚀 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Backup current structure (automatic in migration script)" -ForegroundColor White
Write-Host "  2. Run the platform setup scripts in order" -ForegroundColor White
Write-Host "  3. Test the new structure with npm run dev" -ForegroundColor White
Write-Host "  4. Update team documentation and workflows" -ForegroundColor White

Write-Host "`n⚠️ Important Notes:" -ForegroundColor Red
Write-Host "  • All your existing code will be preserved" -ForegroundColor White
Write-Host "  • Migration scripts create backups automatically" -ForegroundColor White
Write-Host "  • You can rollback if needed" -ForegroundColor White
Write-Host "  • The new structure is more professional and scalable" -ForegroundColor White