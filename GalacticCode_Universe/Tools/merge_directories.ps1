# InfiniCoreCipher Directory Merge Script
Write-Host "🔧 InfiniCoreCipher Directory Merge Tool" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Safety check - ensure we're in the right directory
Write-Host "📍 Current location: $PWD" -ForegroundColor Yellow

if (-not (Test-Path ".git")) {
    Write-Host "❌ Error: Not in a Git repository!" -ForegroundColor Red
    Write-Host "Please navigate to C:\InfiniCoreCipher-Startup\InfiniCoreCipher first" -ForegroundColor Yellow
    exit 1
}

# Create backup commit first
Write-Host "💾 Creating backup commit..." -ForegroundColor Yellow
git add .
git commit -m "Backup before directory restructure - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

Write-Host "✅ Backup commit created" -ForegroundColor Green

# Define paths
$galacticSource = "GalacticCode_Universe\RepositoriumGitHub"
$infiniSource = "InfiniCoreCipher"
$galacticTarget = "galactic"
$coreTarget = "core"

Write-Host "`n🔍 Checking source directories..." -ForegroundColor Yellow

# Check and merge GalacticCode_Universe/RepositoriumGitHub
if (Test-Path $galacticSource) {
    Write-Host "✅ Found $galacticSource" -ForegroundColor Green
    
    Write-Host "📁 Creating galactic/ directory..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $galacticTarget -Force | Out-Null
    
    Write-Host "📦 Moving contents from $galacticSource to $galacticTarget..." -ForegroundColor Cyan
    Get-ChildItem $galacticSource -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring((Resolve-Path $galacticSource).Path.Length + 1)
        $targetPath = Join-Path $galacticTarget $relativePath
        
        if ($_.PSIsContainer) {
            New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        } else {
            $targetDir = Split-Path $targetPath -Parent
            if ($targetDir -and -not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            Copy-Item $_.FullName $targetPath -Force
        }
    }
    
    Write-Host "✅ Contents moved to galactic/" -ForegroundColor Green
    
    # Remove original directory
    Write-Host "🗑️ Removing original $galacticSource..." -ForegroundColor Yellow
    Remove-Item $galacticSource -Recurse -Force
    
    # Also remove the parent GalacticCode_Universe if it's empty
    if (Test-Path "GalacticCode_Universe") {
        $remaining = Get-ChildItem "GalacticCode_Universe"
        if (-not $remaining) {
            Remove-Item "GalacticCode_Universe" -Force
            Write-Host "🗑️ Removed empty GalacticCode_Universe directory" -ForegroundColor Yellow
        }
    }
    
} else {
    Write-Host "⚠️ $galacticSource not found - skipping" -ForegroundColor Yellow
}

# Check and merge InfiniCoreCipher
if (Test-Path $infiniSource) {
    Write-Host "`n✅ Found $infiniSource" -ForegroundColor Green
    
    Write-Host "📁 Creating core/ directory..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $coreTarget -Force | Out-Null
    
    Write-Host "📦 Moving contents from $infiniSource to $coreTarget..." -ForegroundColor Cyan
    Get-ChildItem $infiniSource -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring((Resolve-Path $infiniSource).Path.Length + 1)
        $targetPath = Join-Path $coreTarget $relativePath
        
        if ($_.PSIsContainer) {
            New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        } else {
            $targetDir = Split-Path $targetPath -Parent
            if ($targetDir -and -not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            Copy-Item $_.FullName $targetPath -Force
        }
    }
    
    Write-Host "✅ Contents moved to core/" -ForegroundColor Green
    
    # Remove original directory
    Write-Host "🗑️ Removing original $infiniSource..." -ForegroundColor Yellow
    Remove-Item $infiniSource -Recurse -Force
    
} else {
    Write-Host "`n⚠️ $infiniSource not found - skipping" -ForegroundColor Yellow
}

# Create updated README for the new structure
Write-Host "`n📝 Creating updated project structure documentation..." -ForegroundColor Yellow

$structureDoc = @"
# InfiniCoreCipher Project Structure

## Directory Organization

```
C:\InfiniCoreCipher-Startup\InfiniCoreCipher\
├── core/                    # Core InfiniCoreCipher application files
├── galactic/               # GalacticCode Universe components
├── automation/             # Automation framework
├── backend/                # Backend services
├── frontend/               # Frontend interface
├── docs/                   # Documentation
├── scripts/                # Utility scripts
├── package.json            # Project configuration
├── LICENSE                 # License file
└── README.md              # Main documentation
```

## Component Descriptions

### 🔐 core/
Contains the main InfiniCoreCipher application files and core functionality.

### 🌌 galactic/
Houses the GalacticCode Universe components and related modules.

### 🤖 automation/
Complete automation framework with:
- Cross-platform automation scripts
- Security monitoring tools
- Web dashboard interface
- Installation and testing utilities

### 🔧 backend/
Backend services and API implementations.

### 🎨 frontend/
User interface and frontend components.

### 📚 docs/
Project documentation and guides.

### 📜 scripts/
Utility scripts for development and deployment.

## Recent Changes

**Directory Restructure ($(Get-Date -Format 'yyyy-MM-dd'))**
- Merged `GalacticCode_Universe/RepositoriumGitHub/` → `galactic/`
- Merged `InfiniCoreCipher/` → `core/`
- Improved project organization and accessibility
- Maintained all functionality while simplifying structure

## Usage

Refer to individual component README files for specific usage instructions:
- `automation/README.md` - Automation framework
- `core/README.md` - Core application (if exists)
- `galactic/README.md` - Galactic components (if exists)
"@

$structureDoc | Out-File -FilePath "PROJECT_STRUCTURE.md" -Encoding UTF8

Write-Host "✅ Project structure documentation created" -ForegroundColor Green

# Show new directory structure
Write-Host "`n📊 New Directory Structure:" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green
Get-ChildItem . | Select-Object Name, @{Name="Type";Expression={if($_.PSIsContainer){"Directory"}else{"File"}}}, LastWriteTime | Format-Table -AutoSize

# Update Git
Write-Host "`n📝 Updating Git repository..." -ForegroundColor Yellow
git add .
git commit -m "Restructure project directories

- Merge GalacticCode_Universe/RepositoriumGitHub/ → galactic/
- Merge InfiniCoreCipher/ → core/  
- Improve project organization and accessibility
- Add PROJECT_STRUCTURE.md documentation
- Maintain all functionality with cleaner structure

This restructure simplifies navigation while preserving
all components and their relationships."

Write-Host "✅ Git repository updated" -ForegroundColor Green

# Final verification
Write-Host "`n🔍 Verification:" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green

if (Test-Path "core") {
    $coreFiles = (Get-ChildItem "core" -Recurse -File).Count
    Write-Host "✅ core/ directory: $coreFiles files" -ForegroundColor Green
}

if (Test-Path "galactic") {
    $galacticFiles = (Get-ChildItem "galactic" -Recurse -File).Count
    Write-Host "✅ galactic/ directory: $galacticFiles files" -ForegroundColor Green
}

if (Test-Path "automation") {
    $automationFiles = (Get-ChildItem "automation" -Recurse -File).Count
    Write-Host "✅ automation/ directory: $automationFiles files" -ForegroundColor Green
}

Write-Host "`n🎉 Directory merge completed successfully!" -ForegroundColor Green
Write-Host "`n📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Test functionality to ensure everything works" -ForegroundColor White
Write-Host "2. Update any hardcoded paths in configuration files" -ForegroundColor White
Write-Host "3. Push changes: git push origin main" -ForegroundColor White
Write-Host "4. Update documentation if needed" -ForegroundColor White

Write-Host "`n✅ Merge operation completed!" -ForegroundColor Green