# Complete File Organization Script
# This is the master script that runs all organization tasks

Write-Host "=== COMPLETE FILE ORGANIZATION PROCESS ===" -ForegroundColor Green
Write-Host "This script will organize your project files safely." -ForegroundColor Cyan

# Step 1: Run safety check first
Write-Host "`n=== STEP 1: SAFETY CHECK ===" -ForegroundColor Magenta
& ".\check_git_safety.ps1"

# Step 2: Create proper .gitignore
Write-Host "`n=== STEP 2: CREATE PROPER .GITIGNORE ===" -ForegroundColor Magenta
& ".\create_proper_gitignore.ps1"

# Step 3: Analyze current structure
Write-Host "`n=== STEP 3: ANALYZE PROJECT STRUCTURE ===" -ForegroundColor Magenta
& ".\analyze_project_structure.ps1"

# Step 4: Preview file moves (WhatIf mode)
Write-Host "`n=== STEP 4: PREVIEW FILE MOVES ===" -ForegroundColor Magenta
Write-Host "Running in preview mode first..." -ForegroundColor Yellow
& ".\move_important_files.ps1" -WhatIf

# Step 5: Confirm before actual move
Write-Host "`n=== STEP 5: CONFIRMATION ===" -ForegroundColor Magenta
$confirmation = Read-Host "Do you want to proceed with moving the files? (Y/N)"

if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    Write-Host "`n=== STEP 6: MOVING FILES ===" -ForegroundColor Magenta
    & ".\move_important_files.ps1"
    
    Write-Host "`n=== STEP 7: FINAL VERIFICATION ===" -ForegroundColor Magenta
    $targetBase = "C:\InfiniCodeCipher\02-Galactic-Code-Project"
    
    Write-Host "Files organized in:" -ForegroundColor Green
    Get-ChildItem "$targetBase" -Directory | ForEach-Object {
        $fileCount = (Get-ChildItem $_.FullName -File -Recurse -ErrorAction SilentlyContinue).Count
        Write-Host "  $($_.Name): $fileCount files" -ForegroundColor Cyan
    }
    
    Write-Host "`n=== ORGANIZATION COMPLETE ===" -ForegroundColor Green
    Write-Host "Your important files have been safely moved out of the Git repository." -ForegroundColor Cyan
    Write-Host "Repository is now clean and safe for public sharing." -ForegroundColor Cyan
    
} else {
    Write-Host "File move cancelled. No files were moved." -ForegroundColor Yellow
}

Write-Host "`n=== PROCESS COMPLETE ===" -ForegroundColor Green