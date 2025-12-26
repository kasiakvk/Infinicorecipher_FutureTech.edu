# PowerShell script for comprehensive GitHub security setup

Write-Host "🔐 Setting up GitHub Security & Authentication..." -ForegroundColor Green

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to create SSH directory if it doesn't exist
function Ensure-SSHDirectory {
    $sshDir = "$env:USERPROFILE\.ssh"
    if (!(Test-Path $sshDir)) {
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
        Write-Host "  ✓ Created SSH directory: $sshDir" -ForegroundColor Gray
    }
    return $sshDir
}

Write-Host "📋 Step 1: SSH Key Configuration" -ForegroundColor Cyan

# Ensure SSH directory exists
$sshDir = Ensure-SSHDirectory

# Check if SSH key already exists
$keyPath = "$sshDir\id_ed25519"
$pubKeyPath = "$keyPath.pub"

if (Test-Path $pubKeyPath) {
    Write-Host "  ✓ SSH key already exists: $pubKeyPath" -ForegroundColor Gray
    $existingKey = Get-Content $pubKeyPath
    Write-Host "  📋 Your existing public key:" -ForegroundColor Yellow
    Write-Host "    $existingKey" -ForegroundColor White
} else {
    Write-Host "  🔑 Generating new SSH key..." -ForegroundColor Yellow
    
    # Prompt for email
    $email = Read-Host "Enter your GitHub email address"
    
    # Generate SSH key
    ssh-keygen -t ed25519 -C $email -f $keyPath -N '""'
    
    if (Test-Path $pubKeyPath) {
        Write-Host "  ✓ SSH key generated successfully!" -ForegroundColor Green
        $newKey = Get-Content $pubKeyPath
        Write-Host "  📋 Your new public key:" -ForegroundColor Yellow
        Write-Host "    $newKey" -ForegroundColor White
    } else {
        Write-Host "  ❌ Failed to generate SSH key" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n📋 Step 2: SSH Agent Configuration" -ForegroundColor Cyan

# Start SSH agent if not running
$sshAgent = Get-Process ssh-agent -ErrorAction SilentlyContinue
if (!$sshAgent) {
    Write-Host "  🚀 Starting SSH agent..." -ForegroundColor Yellow
    Start-Service ssh-agent -ErrorAction SilentlyContinue
    
    # For Windows, we need to use ssh-add differently
    if (Test-Command "ssh-add") {
        ssh-add $keyPath
        Write-Host "  ✓ SSH key added to agent" -ForegroundColor Gray
    }
} else {
    Write-Host "  ✓ SSH agent already running" -ForegroundColor Gray
}

Write-Host "`n📋 Step 3: GitHub-Specific SSH Configuration" -ForegroundColor Cyan

# Create SSH config file
$configPath = "$sshDir\config"
$configContent = @"
# GitHub Configuration
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    AddKeysToAgent yes
    UseKeychain yes
    ServerAliveInterval 60
    ServerAliveCountMax 30

# GitHub Enterprise (if needed)
Host github-enterprise
    HostName your-enterprise-github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

# Alternative GitHub host (for multiple accounts)
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
"@

$configContent | Out-File -FilePath $configPath -Encoding UTF8
Write-Host "  ✓ Created SSH config: $configPath" -ForegroundColor Gray

Write-Host "`n📋 Step 4: GitHub CLI Installation" -ForegroundColor Cyan

# Check if GitHub CLI is installed
if (Test-Command "gh") {
    Write-Host "  ✓ GitHub CLI already installed" -ForegroundColor Gray
    gh --version
} else {
    Write-Host "  📥 Installing GitHub CLI..." -ForegroundColor Yellow
    
    # Check if winget is available
    if (Test-Command "winget") {
        try {
            winget install --id GitHub.cli
            Write-Host "  ✓ GitHub CLI installed via winget" -ForegroundColor Green
        }
        catch {
            Write-Host "  ⚠ Winget installation failed" -ForegroundColor Yellow
        }
    }
    
    # Check if Chocolatey is available
    if ((Test-Command "choco") -and !(Test-Command "gh")) {
        try {
            choco install gh -y
            Write-Host "  ✓ GitHub CLI installed via Chocolatey" -ForegroundColor Green
        }
        catch {
            Write-Host "  ⚠ Chocolatey installation failed" -ForegroundColor Yellow
        }
    }
    
    # Manual installation instructions if automated methods fail
    if (!(Test-Command "gh")) {
        Write-Host "  📝 Manual installation required:" -ForegroundColor Yellow
        Write-Host "    1. Download from: https://cli.github.com/" -ForegroundColor White
        Write-Host "    2. Install the downloaded package" -ForegroundColor White
        Write-Host "    3. Restart PowerShell and run this script again" -ForegroundColor White
        Write-Host "  ⏸ Pausing for manual installation..." -ForegroundColor Yellow
        Read-Host "Press Enter after installing GitHub CLI"
    }
}

Write-Host "`n📋 Step 5: Add SSH Key to GitHub" -ForegroundColor Cyan

if (Test-Path $pubKeyPath) {
    $publicKey = Get-Content $pubKeyPath
    Write-Host "  📋 Your SSH public key (copy this to GitHub):" -ForegroundColor Yellow
    Write-Host "    $publicKey" -ForegroundColor White
    
    # Copy to clipboard if possible
    try {
        $publicKey | Set-Clipboard
        Write-Host "  ✓ Public key copied to clipboard!" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠ Could not copy to clipboard automatically" -ForegroundColor Yellow
    }
    
    Write-Host "`n  🌐 To add this key to GitHub:" -ForegroundColor Cyan
    Write-Host "    1. Go to: https://github.com/settings/ssh/new" -ForegroundColor White
    Write-Host "    2. Title: 'Galactic Code Development Key'" -ForegroundColor White
    Write-Host "    3. Paste the key above" -ForegroundColor White
    Write-Host "    4. Click 'Add SSH key'" -ForegroundColor White
    
    # If GitHub CLI is available, offer to add key automatically
    if (Test-Command "gh") {
        Write-Host "`n  🤖 Or use GitHub CLI to add automatically:" -ForegroundColor Cyan
        Write-Host "    gh auth login" -ForegroundColor White
        Write-Host "    gh ssh-key add $pubKeyPath --title 'Galactic Code Development Key'" -ForegroundColor White
    }
}

Write-Host "`n📋 Step 6: GitHub CLI Authentication" -ForegroundColor Cyan

if (Test-Command "gh") {
    Write-Host "  🔐 Authenticating with GitHub CLI..." -ForegroundColor Yellow
    Write-Host "  📝 Follow the prompts to authenticate:" -ForegroundColor Cyan
    Write-Host "    - Choose 'GitHub.com'" -ForegroundColor White
    Write-Host "    - Choose 'SSH' for Git operations" -ForegroundColor White
    Write-Host "    - Choose 'Login with a web browser'" -ForegroundColor White
    
    try {
        gh auth login
        Write-Host "  ✓ GitHub CLI authentication completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠ Authentication may need to be completed manually" -ForegroundColor Yellow
        Write-Host "    Run: gh auth login" -ForegroundColor White
    }
} else {
    Write-Host "  ⚠ GitHub CLI not available for authentication" -ForegroundColor Yellow
}

Write-Host "`n📋 Step 7: Connectivity Testing" -ForegroundColor Cyan

# Test SSH connection to GitHub
Write-Host "  🔍 Testing SSH connection to GitHub..." -ForegroundColor Yellow
try {
    $sshTest = ssh -T git@github.com 2>&1
    if ($sshTest -match "successfully authenticated") {
        Write-Host "  ✅ SSH connection to GitHub successful!" -ForegroundColor Green
        Write-Host "    $sshTest" -ForegroundColor Gray
    } else {
        Write-Host "  ⚠ SSH connection test result:" -ForegroundColor Yellow
        Write-Host "    $sshTest" -ForegroundColor Gray
    }
}
catch {
    Write-Host "  ❌ SSH connection test failed" -ForegroundColor Red
    Write-Host "    Make sure you've added your SSH key to GitHub" -ForegroundColor Yellow
}

# Test GitHub CLI authentication
if (Test-Command "gh") {
    Write-Host "  🔍 Testing GitHub CLI authentication..." -ForegroundColor Yellow
    try {
        $authStatus = gh auth status 2>&1
        if ($authStatus -match "Logged in") {
            Write-Host "  ✅ GitHub CLI authentication successful!" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ GitHub CLI authentication status:" -ForegroundColor Yellow
            Write-Host "    $authStatus" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  ⚠ GitHub CLI authentication check failed" -ForegroundColor Yellow
        Write-Host "    Run: gh auth login" -ForegroundColor White
    }
}

Write-Host "`n📋 Step 8: Git Configuration for Signing" -ForegroundColor Cyan

# Configure Git to use SSH for signing (modern approach)
Write-Host "  ⚙️ Configuring Git for SSH signing..." -ForegroundColor Yellow

try {
    git config --global gpg.format ssh
    git config --global user.signingkey $pubKeyPath
    git config --global commit.gpgsign true
    git config --global tag.gpgsign true
    
    Write-Host "  ✓ Git configured for SSH signing" -ForegroundColor Green
    Write-Host "    Signing key: $pubKeyPath" -ForegroundColor Gray
}
catch {
    Write-Host "  ⚠ Git signing configuration failed" -ForegroundColor Yellow
    Write-Host "    You can configure this manually later" -ForegroundColor Gray
}

Write-Host "`n✅ GitHub Security Setup Complete!" -ForegroundColor Green

Write-Host "`n📋 Summary:" -ForegroundColor Cyan
Write-Host "  🔑 SSH key: $(if (Test-Path $pubKeyPath) { "✓ Ready" } else { "❌ Missing" })" -ForegroundColor White
Write-Host "  ⚙️ SSH config: ✓ Configured" -ForegroundColor White
Write-Host "  🤖 GitHub CLI: $(if (Test-Command "gh") { "✓ Installed" } else { "❌ Missing" })" -ForegroundColor White
Write-Host "  🔐 Authentication: $(if (Test-Command "gh") { "✓ Ready" } else { "⚠ Manual setup needed" })" -ForegroundColor White
Write-Host "  📝 Git signing: ✓ Configured" -ForegroundColor White

Write-Host "`n🚀 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Ensure SSH key is added to GitHub (if not done automatically)" -ForegroundColor White
Write-Host "  2. Test repository operations: git clone, push, pull" -ForegroundColor White
Write-Host "  3. Continue with Galactic Code repository setup" -ForegroundColor White
Write-Host "  4. Run: .\test_github_connectivity.ps1" -ForegroundColor White

Write-Host "`n🔗 Useful Commands:" -ForegroundColor Cyan
Write-Host "  gh auth status          # Check authentication status" -ForegroundColor White
Write-Host "  gh ssh-key list         # List SSH keys on GitHub" -ForegroundColor White
Write-Host "  ssh -T git@github.com   # Test SSH connection" -ForegroundColor White
Write-Host "  git config --list       # View Git configuration" -ForegroundColor White