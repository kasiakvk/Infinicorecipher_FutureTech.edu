# PowerShell script to test GitHub connectivity and authentication

Write-Host "🔍 Testing GitHub Connectivity & Authentication..." -ForegroundColor Green

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

# Function to run test with status reporting
function Run-Test {
    param(
        [string]$TestName,
        [scriptblock]$TestScript
    )
    
    Write-Host "`n🧪 Testing: $TestName" -ForegroundColor Cyan
    try {
        $result = & $TestScript
        if ($result.Success) {
            Write-Host "  ✅ PASS: $($result.Message)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  ❌ FAIL: $($result.Message)" -ForegroundColor Red
            if ($result.Details) {
                Write-Host "     Details: $($result.Details)" -ForegroundColor Yellow
            }
            return $false
        }
    }
    catch {
        Write-Host "  ❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Test 1: SSH Key Existence
$test1 = Run-Test "SSH Key Files" {
    $sshDir = "$env:USERPROFILE\.ssh"
    $keyPath = "$sshDir\id_ed25519"
    $pubKeyPath = "$keyPath.pub"
    
    if ((Test-Path $keyPath) -and (Test-Path $pubKeyPath)) {
        $keyInfo = Get-Content $pubKeyPath
        return @{
            Success = $true
            Message = "SSH key pair exists"
            Details = "Public key: $($keyInfo.Substring(0, 50))..."
        }
    } else {
        return @{
            Success = $false
            Message = "SSH key pair missing"
            Details = "Run github_security_setup.ps1 to generate keys"
        }
    }
}

# Test 2: SSH Agent
$test2 = Run-Test "SSH Agent" {
    try {
        $sshAdd = ssh-add -l 2>&1
        if ($sshAdd -match "ed25519" -or $sshAdd -match "The agent has no identities") {
            return @{
                Success = $true
                Message = "SSH agent is running"
                Details = $sshAdd
            }
        } else {
            return @{
                Success = $false
                Message = "SSH agent issues"
                Details = $sshAdd
            }
        }
    }
    catch {
        return @{
            Success = $false
            Message = "SSH agent not accessible"
            Details = "May need to start SSH service"
        }
    }
}

# Test 3: SSH Configuration
$test3 = Run-Test "SSH Configuration" {
    $configPath = "$env:USERPROFILE\.ssh\config"
    if (Test-Path $configPath) {
        $config = Get-Content $configPath -Raw
        if ($config -match "github\.com") {
            return @{
                Success = $true
                Message = "SSH config exists with GitHub settings"
                Details = "Config file: $configPath"
            }
        } else {
            return @{
                Success = $false
                Message = "SSH config exists but no GitHub settings"
                Details = "Add GitHub configuration to $configPath"
            }
        }
    } else {
        return @{
            Success = $false
            Message = "SSH config file missing"
            Details = "Run github_security_setup.ps1 to create config"
        }
    }
}

# Test 4: GitHub SSH Connection
$test4 = Run-Test "GitHub SSH Connection" {
    try {
        $sshTest = ssh -o ConnectTimeout=10 -T git@github.com 2>&1
        if ($sshTest -match "successfully authenticated") {
            $username = ($sshTest -split "Hi ")[1] -split "!")[0]
            return @{
                Success = $true
                Message = "SSH connection successful"
                Details = "Authenticated as: $username"
            }
        } elseif ($sshTest -match "Permission denied") {
            return @{
                Success = $false
                Message = "SSH authentication failed"
                Details = "Check if SSH key is added to GitHub account"
            }
        } else {
            return @{
                Success = $false
                Message = "SSH connection issues"
                Details = $sshTest
            }
        }
    }
    catch {
        return @{
            Success = $false
            Message = "SSH connection error"
            Details = $_.Exception.Message
        }
    }
}

# Test 5: GitHub CLI Installation
$test5 = Run-Test "GitHub CLI Installation" {
    if (Test-Command "gh") {
        $version = gh --version 2>&1
        return @{
            Success = $true
            Message = "GitHub CLI installed"
            Details = $version[0]
        }
    } else {
        return @{
            Success = $false
            Message = "GitHub CLI not installed"
            Details = "Install from https://cli.github.com/ or run github_security_setup.ps1"
        }
    }
}

# Test 6: GitHub CLI Authentication
$test6 = Run-Test "GitHub CLI Authentication" {
    if (Test-Command "gh") {
        try {
            $authStatus = gh auth status 2>&1
            if ($authStatus -match "Logged in") {
                $account = ($authStatus | Select-String "account (.+)" | ForEach-Object { $_.Matches[0].Groups[1].Value })
                return @{
                    Success = $true
                    Message = "GitHub CLI authenticated"
                    Details = "Account: $account"
                }
            } else {
                return @{
                    Success = $false
                    Message = "GitHub CLI not authenticated"
                    Details = "Run: gh auth login"
                }
            }
        }
        catch {
            return @{
                Success = $false
                Message = "GitHub CLI authentication check failed"
                Details = $_.Exception.Message
            }
        }
    } else {
        return @{
            Success = $false
            Message = "GitHub CLI not available"
            Details = "Install GitHub CLI first"
        }
    }
}

# Test 7: Git Configuration
$test7 = Run-Test "Git Configuration" {
    try {
        $userName = git config --global user.name 2>&1
        $userEmail = git config --global user.email 2>&1
        $signingKey = git config --global user.signingkey 2>&1
        
        if ($userName -and $userEmail) {
            $details = "Name: $userName, Email: $userEmail"
            if ($signingKey) {
                $details += ", Signing: Configured"
            }
            return @{
                Success = $true
                Message = "Git properly configured"
                Details = $details
            }
        } else {
            return @{
                Success = $false
                Message = "Git configuration incomplete"
                Details = "Missing user name or email"
            }
        }
    }
    catch {
        return @{
            Success = $false
            Message = "Git configuration error"
            Details = $_.Exception.Message
        }
    }
}

# Test 8: Repository Operations Test
$test8 = Run-Test "Repository Operations" {
    if (Test-Command "gh" -and $test4 -and $test6) {
        try {
            # Test creating a simple repository operation
            $testRepo = "test-connectivity-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            
            Write-Host "    Creating test repository..." -ForegroundColor Gray
            gh repo create $testRepo --private --clone
            
            if (Test-Path $testRepo) {
                Set-Location $testRepo
                
                # Test basic Git operations
                "# Test Repository" | Out-File README.md
                git add README.md
                git commit -m "Initial commit"
                git push origin main
                
                # Clean up
                Set-Location ..
                Remove-Item $testRepo -Recurse -Force
                gh repo delete $testRepo --confirm
                
                return @{
                    Success = $true
                    Message = "Repository operations successful"
                    Details = "Created, committed, pushed, and deleted test repo"
                }
            } else {
                return @{
                    Success = $false
                    Message = "Repository creation failed"
                    Details = "Could not create test repository"
                }
            }
        }
        catch {
            return @{
                Success = $false
                Message = "Repository operations failed"
                Details = $_.Exception.Message
            }
        }
    } else {
        return @{
            Success = $false
            Message = "Prerequisites not met"
            Details = "SSH connection or GitHub CLI authentication required"
        }
    }
}

# Summary
Write-Host "`n📊 Test Summary:" -ForegroundColor Cyan
$passedTests = @($test1, $test2, $test3, $test4, $test5, $test6, $test7, $test8) | Where-Object { $_ -eq $true }
$totalTests = 8
$passedCount = $passedTests.Count

Write-Host "  Tests Passed: $passedCount/$totalTests" -ForegroundColor $(if ($passedCount -eq $totalTests) { "Green" } else { "Yellow" })

if ($passedCount -eq $totalTests) {
    Write-Host "`n🎉 All tests passed! GitHub connectivity is fully configured." -ForegroundColor Green
    Write-Host "✅ You're ready to work with GitHub repositories securely!" -ForegroundColor Green
} elseif ($passedCount -ge 6) {
    Write-Host "`n⚠️ Most tests passed. Minor issues may need attention." -ForegroundColor Yellow
    Write-Host "🔧 Review failed tests and run fixes as needed." -ForegroundColor Yellow
} else {
    Write-Host "`n❌ Several tests failed. GitHub setup needs attention." -ForegroundColor Red
    Write-Host "🔧 Run github_security_setup.ps1 to fix configuration issues." -ForegroundColor Red
}

Write-Host "`n🔧 Quick Fixes:" -ForegroundColor Cyan
Write-Host "  Missing SSH keys:     .\github_security_setup.ps1" -ForegroundColor White
Write-Host "  GitHub CLI auth:      gh auth login" -ForegroundColor White
Write-Host "  Git configuration:    git config --global user.name 'Your Name'" -ForegroundColor White
Write-Host "  SSH connection:       ssh -T git@github.com" -ForegroundColor White

Write-Host "`n🚀 Ready for Galactic Code setup!" -ForegroundColor Green
Write-Host "  Next: .\setup_galactic_structure.ps1" -ForegroundColor White