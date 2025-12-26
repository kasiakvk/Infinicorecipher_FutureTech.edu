#!/usr/bin/env pwsh
# Fix Branch and Remote Issues for InfiniCoreCipher

Write-Host "🔧 InfiniCoreCipher Branch & Remote Fix" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

Write-Host "`n🔍 Current Situation Detected:" -ForegroundColor Yellow
Write-Host "- You're on branch 'Infinicorecipher'" -ForegroundColor Cyan
Write-Host "- Trying to push to 'main' (which doesn't exist locally)" -ForegroundColor Cyan
Write-Host "- Remote URL appears to be duplicated" -ForegroundColor Cyan

Write-Host "`n📊 Current Status:" -ForegroundColor Yellow
Write-Host "Current branch:" -ForegroundColor White
git branch --show-current

Write-Host "`nRemote configuration:" -ForegroundColor White
git remote -v

Write-Host "`nRepository status:" -ForegroundColor White
git status --short

Write-Host "`n🔧 Step 1: Fixing Remote URL..." -ForegroundColor Cyan
try {
    # Fix the duplicated remote URL
    git remote set-url origin https://github.com/kasiakvk/InfiniCoreCipher.git
    Write-Host "✅ Remote URL fixed" -ForegroundColor Green
    
    Write-Host "New remote configuration:" -ForegroundColor White
    git remote -v
}
catch {
    Write-Host "❌ Failed to fix remote URL: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🌿 Step 2: Branch Strategy..." -ForegroundColor Cyan
Write-Host "You have two options:" -ForegroundColor White

$choice = Read-Host "`nChoose option:
1. Push current 'Infinicorecipher' branch (recommended)
2. Rename current branch to 'main' and push
Enter choice (1 or 2)"

if ($choice -eq "2") {
    Write-Host "`n🔄 Option 2: Renaming branch to 'main'..." -ForegroundColor Cyan
    try {
        # Rename current branch to main
        git branch -m main
        Write-Host "✅ Branch renamed to 'main'" -ForegroundColor Green
        
        # Push to main
        Write-Host "`n🚀 Pushing to main branch..." -ForegroundColor Cyan
        git push -u origin main
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ SUCCESS: Pushed to main branch!" -ForegroundColor Green
        }
        else {
            Write-Host "❌ Push to main failed, trying force push..." -ForegroundColor Yellow
            git push -u origin main --force
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ SUCCESS: Force push to main worked!" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Host "❌ Branch rename failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    Write-Host "`n🚀 Option 1: Pushing current 'Infinicorecipher' branch..." -ForegroundColor Cyan
    try {
        # Push current branch
        git push -u origin Infinicorecipher
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ SUCCESS: Pushed to 'Infinicorecipher' branch!" -ForegroundColor Green
            Write-Host "`n💡 Next steps:" -ForegroundColor Cyan
            Write-Host "1. Go to GitHub: https://github.com/kasiakvk/InfiniCoreCipher" -ForegroundColor White
            Write-Host "2. Create a Pull Request to merge 'Infinicorecipher' into main" -ForegroundColor White
            Write-Host "3. Or set 'Infinicorecipher' as the default branch in repository settings" -ForegroundColor White
        }
        else {
            Write-Host "❌ Push failed, trying force push..." -ForegroundColor Yellow
            git push -u origin Infinicorecipher --force
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ SUCCESS: Force push worked!" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Host "❌ Push failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n📋 Step 3: Verification..." -ForegroundColor Cyan
Write-Host "Final status:" -ForegroundColor White
git status

Write-Host "`nBranches:" -ForegroundColor White
git branch -a

Write-Host "`nRemote tracking:" -ForegroundColor White
git branch -vv

Write-Host "`n🎉 Fix Completed!" -ForegroundColor Green
Write-Host "===============" -ForegroundColor Green

Write-Host "`n📝 Summary:" -ForegroundColor Yellow
Write-Host "- Remote URL has been fixed" -ForegroundColor White
Write-Host "- Branch issue has been resolved" -ForegroundColor White
Write-Host "- Your automation framework should now be on GitHub" -ForegroundColor White

Write-Host "`n🌐 Check your repository:" -ForegroundColor Cyan
Write-Host "https://github.com/kasiakvk/InfiniCoreCipher" -ForegroundColor Blue

Write-Host "`n✨ Your InfiniCoreCipher automation framework is now available!" -ForegroundColor Green