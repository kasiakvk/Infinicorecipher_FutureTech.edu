# 🔧 GIT CONFIGURATION SETUP - Konfiguracja Git dla InfiniCoreCipher

Write-Host "=== GIT CONFIGURATION SETUP ===" -ForegroundColor Cyan
Write-Host "Konfigurowanie Git dla InfiniCoreCipher Enterprise..." -ForegroundColor Yellow

# Sprawdź obecną konfigurację
Write-Host "`n📊 OBECNA KONFIGURACJA GIT:" -ForegroundColor Green
Write-Host "Sprawdzanie obecnych ustawień..." -ForegroundColor White

try {
    Write-Host "`nUser configuration:" -ForegroundColor Cyan
    $userName = git config --global user.name
    $userEmail = git config --global user.email
    Write-Host "Name: $userName" -ForegroundColor White
    Write-Host "Email: $userEmail" -ForegroundColor White
    
    Write-Host "`nBranch configuration:" -ForegroundColor Cyan
    $defaultBranch = git config --global init.defaultBranch
    Write-Host "Default branch: $defaultBranch" -ForegroundColor White
    
    Write-Host "`nEditor configuration:" -ForegroundColor Cyan
    $editor = git config --global core.editor
    Write-Host "Editor: $editor" -ForegroundColor White
    
} catch {
    Write-Host "⚠️ Niektóre konfiguracje nie są ustawione" -ForegroundColor Yellow
}

Write-Host "`n🔧 KONFIGUROWANIE DLA INFINICORECIPHER..." -ForegroundColor Green

# Ustaw domyślną nazwę brancha na 'main'
Write-Host "Ustawianie domyślnego brancha na 'main'..." -ForegroundColor White
git config --global init.defaultBranch main

# Ustaw user identity dla InfiniCoreCipher (jeśli nie ustawione)
if (-not $userName -or $userName -eq "") {
    Write-Host "Ustawianie user.name..." -ForegroundColor White
    git config --global user.name "InfiniCoreCipher"
}

if (-not $userEmail -or $userEmail -eq "") {
    Write-Host "Ustawianie user.email..." -ForegroundColor White
    git config --global user.email "infinicorecipher@futuretechedu.com"
}

# Ustaw edytor (jeśli nie ustawiony)
if (-not $editor -or $editor -eq "") {
    Write-Host "Ustawianie domyślnego edytora..." -ForegroundColor White
    # Sprawdź czy Notepad++ jest dostępny
    if (Test-Path "C:\Program Files\Notepad++\notepad++.exe") {
        git config --global core.editor "'C:/Program Files/Notepad++/notepad++.exe' -multiInst -notabbar -nosession -noPlugin"
        Write-Host "✅ Ustawiono Notepad++ jako edytor" -ForegroundColor Green
    } elseif (Test-Path "C:\Program Files (x86)\Notepad++\notepad++.exe") {
        git config --global core.editor "'C:/Program Files (x86)/Notepad++/notepad++.exe' -multiInst -notabbar -nosession -noPlugin"
        Write-Host "✅ Ustawiono Notepad++ (x86) jako edytor" -ForegroundColor Green
    } else {
        git config --global core.editor "notepad"
        Write-Host "✅ Ustawiono Notepad jako edytor" -ForegroundColor Green
    }
}

# Dodatkowe ustawienia dla lepszej pracy z GitHub
Write-Host "`n⚙️ DODATKOWE USTAWIENIA GITHUB..." -ForegroundColor Cyan

# Automatyczne kolorowanie
git config --global color.ui auto
git config --global color.status auto
git config --global color.branch auto
git config --global color.diff auto

# Ustawienia push
git config --global push.default simple
git config --global pull.rebase false

# Ustawienia dla Windows
git config --global core.autocrlf true
git config --global core.safecrlf false

# Ustawienia bezpieczeństwa
git config --global credential.helper manager-core

Write-Host "`n📋 FINALNA KONFIGURACJA:" -ForegroundColor Green
Write-Host "Sprawdzanie wszystkich ustawień..." -ForegroundColor White

# Pokaż finalną konfigurację
git config --list --show-origin | Where-Object { $_ -match "(user\.|init\.|core\.editor|color\.|push\.|pull\.)" }

Write-Host "`n🎯 WERYFIKACJA KONFIGURACJI:" -ForegroundColor Cyan

# Test konfiguracji
Write-Host "User name: $(git config --global user.name)" -ForegroundColor White
Write-Host "User email: $(git config --global user.email)" -ForegroundColor White
Write-Host "Default branch: $(git config --global init.defaultBranch)" -ForegroundColor White
Write-Host "Editor: $(git config --global core.editor)" -ForegroundColor White

Write-Host "`n✅ GIT CONFIGURATION SETUP ZAKOŃCZONE!" -ForegroundColor Green
Write-Host "Wszystkie nowe repozytoria będą używać brancha 'main'" -ForegroundColor White
Write-Host "Konfiguracja jest gotowa dla InfiniCoreCipher Enterprise" -ForegroundColor White

pause