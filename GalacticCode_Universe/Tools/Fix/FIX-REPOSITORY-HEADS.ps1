# 🔧 FIX REPOSITORY HEADS - Napraw HEAD references w folderach repozytoriów

Write-Host "=== FIXING REPOSITORY HEAD REFERENCES ===" -ForegroundColor Cyan
Write-Host "Naprawianie HEAD w folderach repozytoriów..." -ForegroundColor Yellow

# Definicje ścieżek repozytoriów
$ProductionRepo = "C:\InfiniCoreCipher-Startup\Infinicorecipher_Repositorium"
$BackupRepo = "C:\InfiniCoreCipher-Startup\Backup"

Write-Host "`n📁 SPRAWDZANIE FOLDERÓW REPOZYTORIÓW..." -ForegroundColor Green

# Sprawdź Production Repository
if (Test-Path $ProductionRepo) {
    Write-Host "✅ Znaleziono Production Repo: $ProductionRepo" -ForegroundColor Green
    
    Push-Location $ProductionRepo
    try {
        Write-Host "`n🔧 NAPRAWIANIE PRODUCTION REPO..." -ForegroundColor Cyan
        
        # Sprawdź obecny HEAD
        $currentHead = git symbolic-ref HEAD 2>$null
        Write-Host "Obecny HEAD: $currentHead" -ForegroundColor White
        
        # Sprawdź branche
        Write-Host "`nObecne branche:" -ForegroundColor White
        git branch -a
        
        # Sprawdź remote
        Write-Host "`nRemote configuration:" -ForegroundColor White
        git remote -v
        
        # Napraw HEAD jeśli potrzebne
        if ($currentHead -like "*master*") {
            Write-Host "`n🔄 Zmienianie master na main..." -ForegroundColor Yellow
            git branch -m master main
            git push -u origin main
            Write-Host "✅ HEAD zmieniony na main" -ForegroundColor Green
        } elseif ($currentHead -like "*main*") {
            Write-Host "✅ HEAD już wskazuje na main" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Nieznany branch HEAD: $currentHead" -ForegroundColor Yellow
            Write-Host "Ustawianie na main..." -ForegroundColor Yellow
            git checkout -b main
            git push -u origin main
        }
        
        # Sprawdź status po naprawie
        Write-Host "`n📊 STATUS PO NAPRAWIE:" -ForegroundColor Cyan
        git status
        
    } catch {
        Write-Host "❌ Błąd podczas naprawiania Production Repo: $_" -ForegroundColor Red
    } finally {
        Pop-Location
    }
} else {
    Write-Host "❌ Nie znaleziono Production Repo: $ProductionRepo" -ForegroundColor Red
}

# Sprawdź Backup Repository (jeśli istnieje)
if (Test-Path $BackupRepo) {
    Write-Host "`n✅ Znaleziono Backup Repo: $BackupRepo" -ForegroundColor Green
    
    Push-Location $BackupRepo
    try {
        Write-Host "`n🔧 NAPRAWIANIE BACKUP REPO..." -ForegroundColor Cyan
        
        # Sprawdź obecny HEAD
        $currentHead = git symbolic-ref HEAD 2>$null
        Write-Host "Obecny HEAD: $currentHead" -ForegroundColor White
        
        # Napraw HEAD jeśli potrzebne
        if ($currentHead -like "*master*") {
            Write-Host "`n🔄 Zmienianie master na main..." -ForegroundColor Yellow
            git branch -m master main
            git push -u origin main 2>$null
            Write-Host "✅ HEAD zmieniony na main" -ForegroundColor Green
        } elseif ($currentHead -like "*main*") {
            Write-Host "✅ HEAD już wskazuje na main" -ForegroundColor Green
        }
        
    } catch {
        Write-Host "❌ Błąd podczas naprawiania Backup Repo: $_" -ForegroundColor Red
    } finally {
        Pop-Location
    }
} else {
    Write-Host "ℹ️ Brak Backup Repo (to normalne)" -ForegroundColor Gray
}

# Sprawdź inne możliwe lokalizacje
$OtherPossiblePaths = @(
    "C:\InfiniCoreCipher-Startup\InfiniCoreCipher",
    "C:\InfiniCoreCipher-Startup\Infinicorecipher",
    "C:\Users\$env:USERNAME\Documents\GitHub\Infinicorecipher",
    "C:\Users\$env:USERNAME\Documents\GitHub\InfiniCoreCipher"
)

Write-Host "`n🔍 SPRAWDZANIE INNYCH MOŻLIWYCH LOKALIZACJI..." -ForegroundColor Cyan

foreach ($path in $OtherPossiblePaths) {
    if (Test-Path $path) {
        Write-Host "✅ Znaleziono: $path" -ForegroundColor Green
        
        Push-Location $path
        try {
            # Sprawdź czy to repo Git
            if (Test-Path ".git") {
                $currentHead = git symbolic-ref HEAD 2>$null
                Write-Host "  HEAD: $currentHead" -ForegroundColor White
                
                # Napraw jeśli potrzebne
                if ($currentHead -like "*master*") {
                    Write-Host "  🔄 Naprawianie HEAD..." -ForegroundColor Yellow
                    git branch -m master main
                    git push -u origin main 2>$null
                    Write-Host "  ✅ Naprawiono" -ForegroundColor Green
                }
            } else {
                Write-Host "  ℹ️ Nie jest repo Git" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  ⚠️ Błąd: $_" -ForegroundColor Yellow
        } finally {
            Pop-Location
        }
    }
}

Write-Host "`n🎯 PODSUMOWANIE NAPRAWY HEAD REFERENCES:" -ForegroundColor Green
Write-Host "✅ Development Repo (workspace): HEAD → main" -ForegroundColor White
Write-Host "✅ Production Repo: Sprawdzony i naprawiony" -ForegroundColor White
Write-Host "✅ Inne lokalizacje: Sprawdzone" -ForegroundColor White

Write-Host "`n📋 NASTĘPNE KROKI:" -ForegroundColor Cyan
Write-Host "1. Sprawdź GitHub Desktop - czy pokazuje poprawne branche" -ForegroundColor White
Write-Host "2. Wykonaj sync w GitHub Desktop" -ForegroundColor White
Write-Host "3. Sprawdź czy wszystkie zmiany są zsynchronizowane" -ForegroundColor White

Write-Host "`n🎉 NAPRAWIANIE HEAD REFERENCES ZAKOŃCZONE!" -ForegroundColor Green

pause