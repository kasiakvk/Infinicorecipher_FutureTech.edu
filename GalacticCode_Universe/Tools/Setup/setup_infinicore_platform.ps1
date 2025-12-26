# PowerShell script to set up Infinicore Educational Platform structure

Write-Host "🎓 Setting up Infinicore Educational Platform..." -ForegroundColor Green

# Create platform directory structure
$directories = @(
    "platform\security\lib",
    "platform\security\config", 
    "platform\security\tests",
    "platform\security\docs",
    "platform\networking",
    "platform\data",
    "platform\monitoring",
    "platform\user-management",
    "platform\analytics",
    "platform\education-core\progress-tracking",
    "platform\education-core\assessment-engine",
    "platform\education-core\content-management",
    "platform\education-core\gamification",
    "applications\galactic-code\web-client\src",
    "applications\galactic-code\web-client\public",
    "applications\galactic-code\unity-client",
    "applications\galactic-code\mobile-client",
    "applications\galactic-code\config",
    "applications\galactic-code\content",
    "applications\galactic-code\docs",
    "applications\math-quest",
    "applications\science-lab",
    "applications\history-explorer",
    "applications\language-master",
    "services\platform-gateway",
    "services\auth-service",
    "services\user-service",
    "services\analytics-service",
    "services\progress-service",
    "services\achievement-service",
    "services\content-service",
    "services\game-orchestrator",
    "infrastructure\cloud\terraform",
    "infrastructure\cloud\kubernetes",
    "infrastructure\cloud\monitoring",
    "infrastructure\automation\ci-cd",
    "infrastructure\automation\deployment",
    "infrastructure\automation\testing",
    "testing\unit",
    "testing\integration",
    "testing\e2e",
    "testing\performance",
    "testing\security",
    "testing\educational",
    "documentation\platform-architecture",
    "documentation\educational-framework",
    "documentation\game-development",
    "documentation\api",
    "documentation\security",
    "documentation\user-guides",
    "tools\game-sdk",
    "tools\analytics-tools",
    "tools\content-authoring",
    "tools\platform-cli",
    "tools\testing-framework",
    "packages\infinicore-education",
    "packages\infinicore-gaming",
    "packages\infinicore-analytics",
    "packages\infinicore-security",
    "packages\infinicore-ui",
    "assets\branding",
    "assets\audio",
    "assets\video",
    "assets\templates",
    "environments\local",
    "environments\development",
    "environments\staging",
    "environments\production",
    "environments\educational",
    "scripts\setup",
    "scripts\game-deployment",
    "scripts\analytics",
    "scripts\migration"
)

Write-Host "📁 Creating Infinicore platform directory structure..." -ForegroundColor Yellow
foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  ✓ Created: $dir" -ForegroundColor Gray
    }
}

Write-Host "✅ Infinicore platform structure created successfully!" -ForegroundColor Green
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Run: .\create_platform_configs.ps1" -ForegroundColor White
Write-Host "  2. Run: .\migrate_galacticcode_to_platform.ps1" -ForegroundColor White
Write-Host "  3. Set up platform services and educational framework" -ForegroundColor White