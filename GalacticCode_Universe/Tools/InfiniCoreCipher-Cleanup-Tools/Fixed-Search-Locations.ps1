# Fixed-Search-Locations.ps1
# Naprawiona wersja skryptu do sprawdzania lokalizacji

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

Write-Host "🔍 SPRAWDZANIE LOKALIZACJI INFINICORECIPHER" -ForegroundColor $Cyan
Write-Host "================================================" -ForegroundColor $Cyan
Write-Host ""

# Funkcja do sprawdzania folderu
function Check-Folder {
    param([string]$Path, [string]$Description)
    
    Write-Host "🔍 $Description" -ForegroundColor $Yellow
    Write-Host "   Ścieżka: $Path" -ForegroundColor $Cyan
    
    if (Test-Path $Path) {
        Write-Host "   ✅ ISTNIEJE!" -ForegroundColor $Green
        
        try {
            $Item = Get-Item $Path
            if ($Item.PSIsContainer) {
                # To jest folder
                $Contents = Get-ChildItem $Path -ErrorAction SilentlyContinue
                Write-Host "   📁 Typ: Folder" -ForegroundColor $Cyan
                Write-Host "   📋 Zawartość: $($Contents.Count) elementów" -ForegroundColor $Cyan
                
                if ($Contents.Count -gt 0) {
                    Write-Host "   📄 Pierwsze 10 elementów:" -ForegroundColor $Yellow
                    $Contents | Select-Object -First 10 | ForEach-Object {
                        $Type = if ($_.PSIsContainer) { "📁" } else { "📄" }
                        $Size = if (-not $_.PSIsContainer) { " ($([math]::Round($_.Length/1KB, 1)) KB)" } else { "" }
                        Write-Host "      $Type $($_.Name)$Size" -ForegroundColor $Yellow
                    }
                    
                    if ($Contents.Count -gt 10) {
                        Write-Host "      ... i $($Contents.Count - 10) więcej" -ForegroundColor $Yellow
                    }
                    
                    # Sprawdź czy to projekt
                    $ProjectFiles = @("package.json", "README.md", "frontend", "backend")
                    $FoundProjectFiles = @()
                    
                    foreach ($ProjectFile in $ProjectFiles) {
                        if (Test-Path (Join-Path $Path $ProjectFile)) {
                            $FoundProjectFiles += $ProjectFile
                        }
                    }
                    
                    if ($FoundProjectFiles.Count -gt 0) {
                        Write-Host "   🎯 WYGLĄDA NA PROJEKT! Znalezione:" -ForegroundColor $Green
                        foreach ($File in $FoundProjectFiles) {
                            Write-Host "      ✅ $File" -ForegroundColor $Green
                        }
                    }
                    
                    # Sprawdź rozmiar
                    try {
                        $Size = (Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
                        $SizeMB = [math]::Round($Size / 1MB, 2)
                        Write-Host "   📊 Rozmiar: $SizeMB MB" -ForegroundColor $Cyan
                    } catch {
                        Write-Host "   📊 Nie można obliczyć rozmiaru" -ForegroundColor $Yellow
                    }
                }
            } else {
                # To jest plik
                Write-Host "   📄 Typ: Plik" -ForegroundColor $Cyan
                $SizeKB = [math]::Round($Item.Length / 1KB, 1)
                Write-Host "   📊 Rozmiar: $SizeKB KB" -ForegroundColor $Cyan
            }
        } catch {
            Write-Host "   ❌ Błąd dostępu: $($_.Exception.Message)" -ForegroundColor $Red
        }
    } else {
        Write-Host "   ❌ NIE ISTNIEJE" -ForegroundColor $Red
    }
    
    Write-Host ""
}

# Lista lokalizacji do sprawdzenia
Write-Host "📋 SPRAWDZANIE GŁÓWNYCH LOKALIZACJI" -ForegroundColor $Cyan
Write-Host ""

# 1. Główna lokalizacja
Check-Folder "C:\InfiniCoreCipher-Startup" "Główna lokalizacja"

# 2. Pulpit użytkownika
$Desktop = "$env:USERPROFILE\Desktop"
Check-Folder $Desktop "Pulpit użytkownika"

# 3. Sprawdź foldery na pulpicie z nazwami zawierającymi kluczowe słowa
Write-Host "🔍 WYSZUKIWANIE NA PULPICIE" -ForegroundColor $Cyan
Write-Host ""

if (Test-Path $Desktop) {
    $Keywords = @("Infini", "Core", "Cipher", "Startup", "Code")
    $FoundAny = $false
    
    foreach ($Keyword in $Keywords) {
        Write-Host "🔍 Szukanie folderów z '$Keyword'..." -ForegroundColor $Yellow
        
        try {
            $Found = Get-ChildItem $Desktop -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$Keyword*" }
            
            if ($Found) {
                $FoundAny = $true
                Write-Host "   ✅ Znaleziono:" -ForegroundColor $Green
                foreach ($Folder in $Found) {
                    Write-Host "      📁 $($Folder.Name)" -ForegroundColor $Yellow
                    Write-Host "         Ścieżka: $($Folder.FullName)" -ForegroundColor $Cyan
                }
            } else {
                Write-Host "   ❌ Brak folderów z '$Keyword'" -ForegroundColor $Red
            }
        } catch {
            Write-Host "   ❌ Błąd wyszukiwania: $($_.Exception.Message)" -ForegroundColor $Red
        }
        Write-Host ""
    }
    
    if (-not $FoundAny) {
        Write-Host "📋 WSZYSTKIE FOLDERY NA PULPICIE:" -ForegroundColor $Cyan
        try {
            $AllFolders = Get-ChildItem $Desktop -Directory -ErrorAction SilentlyContinue
            if ($AllFolders) {
                foreach ($Folder in $AllFolders) {
                    Write-Host "   📁 $($Folder.Name)" -ForegroundColor $Yellow
                }
            } else {
                Write-Host "   📋 Brak folderów na pulpicie" -ForegroundColor $Yellow
            }
        } catch {
            Write-Host "   ❌ Błąd odczytu pulpitu" -ForegroundColor $Red
        }
    }
} else {
    Write-Host "❌ Nie można uzyskać dostępu do pulpitu" -ForegroundColor $Red
}

# 4. Dodatkowe lokalizacje
Write-Host ""
Write-Host "🔍 SPRAWDZANIE DODATKOWYCH LOKALIZACJI" -ForegroundColor $Cyan
Write-Host ""

$AdditionalPaths = @(
    @{ Path = "D:\InfiniCoreCipher-Startup"; Desc = "Dysk D:" },
    @{ Path = "$env:USERPROFILE\Documents\InfiniCoreCipher-Startup"; Desc = "Dokumenty" },
    @{ Path = "$env:USERPROFILE\Downloads\InfiniCoreCipher-Startup"; Desc = "Pobrane" },
    @{ Path = "C:\Projects\InfiniCoreCipher-Startup"; Desc = "Folder Projects" },
    @{ Path = "C:\Dev\InfiniCoreCipher-Startup"; Desc = "Folder Dev" }
)

foreach ($Location in $AdditionalPaths) {
    Check-Folder $Location.Path $Location.Desc
}

# PODSUMOWANIE
Write-Host "================================================" -ForegroundColor $Cyan
Write-Host "🎯 PODSUMOWANIE" -ForegroundColor $Cyan
Write-Host ""

Write-Host "💡 NASTĘPNE KROKI:" -ForegroundColor $Yellow
Write-Host "1. Jeśli znaleziono projekt - przejdź do tego folderu" -ForegroundColor $Yellow
Write-Host "2. Jeśli nie znaleziono - utwórz nowy projekt" -ForegroundColor $Yellow
Write-Host "3. Uruchom skrypty konfiguracyjne w odpowiednim folderze" -ForegroundColor $Yellow

Write-Host ""
Write-Host "🔧 PRZYDATNE KOMENDY:" -ForegroundColor $Cyan
Write-Host "cd `"ścieżka\do\znalezionego\folderu`"" -ForegroundColor $Yellow
Write-Host ".\Setup-InfinicocipherProject.ps1 -AutoStart" -ForegroundColor $Yellow

Write-Host ""
Write-Host "=== KONIEC SPRAWDZANIA ===" -ForegroundColor $Cyan