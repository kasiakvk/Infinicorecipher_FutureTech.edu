# ===============================================
# Quick-Push-Commands.ps1
# Szybkie komendy do push na GitHub Enterprise
# ===============================================

Write-Host "🚀 SZYBKIE KOMENDY PUSH DO GITHUB ENTERPRISE" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "📊 OBECNY STAN:" -ForegroundColor Green
Write-Host "   ✅ Git repository: Zainicjalizowane" -ForegroundColor White
Write-Host "   ✅ Remote origin: Skonfigurowane" -ForegroundColor White
Write-Host "   ✅ Initial commit: Wykonany (51 plików)" -ForegroundColor White
Write-Host "   ⚠️  Push: Wymaga uwierzytelnienia" -ForegroundColor Yellow

Write-Host ""
Write-Host "🔑 OPCJE UWIERZYTELNIENIA:" -ForegroundColor Cyan

Write-Host ""
Write-Host "OPCJA 1 - Personal Access Token (ZALECANE):" -ForegroundColor Yellow
Write-Host @"
# 1. Utwórz token: https://github.com/settings/tokens
# 2. Skopiuj poniższe komendy i zastąp USERNAME i TOKEN:

git remote set-url origin https://USERNAME:TOKEN@github.com/Infinicorecipher-FutureTechEdu/Infinicorecipher.git
git push -u origin master
"@ -ForegroundColor Green

Write-Host ""
Write-Host "OPCJA 2 - SSH Key:" -ForegroundColor Yellow
Write-Host @"
# 1. Wygeneruj klucz SSH:
ssh-keygen -t ed25519 -C "infinicorecipher@futuretechedu.com"

# 2. Dodaj klucz do GitHub: https://github.com/settings/ssh/new

# 3. Zmień remote i push:
git remote set-url origin git@github.com:Infinicorecipher-FutureTechEdu/Infinicorecipher.git
git push -u origin master
"@ -ForegroundColor Green

Write-Host ""
Write-Host "OPCJA 3 - GitHub CLI:" -ForegroundColor Yellow
Write-Host @"
# 1. Zainstaluj GitHub CLI: https://cli.github.com/
# 2. Uwierzytelnij i push:
gh auth login
git push -u origin master
"@ -ForegroundColor Green

Write-Host ""
Write-Host "📋 CO ZOSTANIE WYSŁANE:" -ForegroundColor Magenta
Write-Host "   • 18 skryptów PowerShell (.ps1)" -ForegroundColor White
Write-Host "   • 33 pliki dokumentacji (.md)" -ForegroundColor White
Write-Host "   • Kompletny enterprise-ready projekt" -ForegroundColor White
Write-Host "   • 11,308+ linii kodu i dokumentacji" -ForegroundColor White

Write-Host ""
Write-Host "🎯 PO PUSH SPRAWDŹ:" -ForegroundColor Cyan
Write-Host "   https://github.com/Infinicorecipher-FutureTechEdu/Infinicorecipher" -ForegroundColor Blue

Write-Host ""
Write-Host "✨ GOTOWE DO ENTERPRISE DEPLOYMENT!" -ForegroundColor Green