# Search-New-Locations.ps1
# Sprawdzenie nowych lokalizacji: C:\InfiniCoreCipher-Startup i Desktop

$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Cyan = "Cyan"

Write-Host "🔍 SPRAWDZANIE NOWYCH LOKALIZACJI" -ForegroundColor $Cyan
Write-Host ""

# Lista lokalizacji do sprawdzenia
$TargetPaths = @(
    "C:\InfiniCoreCipher-Startup",
    "$env:USERPROFILE\Desktop",
    "$env:PUBLIC\Desktop",
    "$env:USERPROFILE\Desktop\InfiniCoreCipher-Startup",
    "$env:USERPROFILE\Desktop\*Infini*",
    "$env:USERPROFILE\Desktop\*Cipher*"
)

Write-Host "📋 Sprawdzane lokalizacje:" -ForegroundColor $Cyan

foreach ($Path in $TargetPaths) {
    Write-Host ""
    Write-Host "🔍 Sprawdzanie: $Path" -ForegroundColor $Yellow
    
    if ($Path -like "*`**") {
        # Wyszukiwanie z wildcardami
        try {
            $BasePath = Split-Path $Path -Parent
            $Pattern = Split-Path $Path -Leaf
            
            if (Test-Path $BasePath) {
                $Found = Get-ChildItem -Path $BasePath -Directory -Name $Pattern -ErrorAction SilentlyContinue
                
                if ($Found) {
                    foreach ($Folder in $Found) {
                        $FullPath = Join-Path $BasePath $Folder
                        Write-Host "  ✅ ZNALEZIONO: $FullPath" -ForegroundColor $Green
                        
                        # Sprawdź zawartość
                        try {
                            $Contents = Get-ChildItem $FullPath -ErrorAction SilentlyContinue
                            if ($Contents) {
                                Write-Host "    📋 Zawartość ($($Contents.Count) elementów):" -ForegroundColor $Cyan
                                $Contents | Select-Object -First 8 | ForEach-Object {
                                    $Type = if ($_.PSIsContainer) { "📁" } else { "📄" }
                                    $Size = if (-not $_.PSIsContainer) { " ($([math]::Round($_.Length/1KB, 1)) KB)" } else { "" }
                                    Write-Host "      $Type $($_.Name)$Size" -ForegroundColor $Yellow
                                }
                                if ($Contents.Count -gt 8) {
                                    Write-Host "      ... i $($Contents.Count - 8) więcej elementów" -ForegroundColor $Yellow
                                }
                            } else {
                                Write-Host "    📋 Folder pusty" -ForegroundColor $Yellow
                            }
                        } catch {
                            Write-Host "    ❌ Brak dostępu do zawartości" -ForegroundColor $Red
                        }
                    }
                } else {
                    Write-Host "  ❌ Nie znaleziono" -ForegroundColor $Red
                }
            } else {
                Write-Host "  ❌ Ścieżka bazowa nie istnieje" -ForegroundColor $Red
            }
        } catch {
            Write-Host "  ❌ Błąd wyszukiwania: $($_.Exception.Message)" -ForegroundColor $Red
        }
    } else {
        # Dokładne sprawdzenie ścieżki
        if (Test-Path $Path) {
            Write-Host "  ✅ ISTNIEJE: $Path" -ForegroundColor $Green
            
            # Sprawdź czy to folder czy plik
            $Item = Get-Item $Path
            if ($Item.PSIsContainer) {
                Write-Host "    📁 Typ: Folder" -ForegroundColor $Cyan
                
                # Sprawdź zawartość folderu
                try {
                    $Contents = Get-ChildItem $Path -ErrorAction SilentlyContinue
                    if ($Contents) {
                        Write-Host "    📋 Zawartość ($($Contents.Count) elementów):" -ForegroundColor $Cyan
                        
                        # Pokaż pierwsze 10 elementów
                        $Contents | Select-Object -First 10 | ForEach-Object {
                            $Type = if ($_.PSIsContainer) { "📁" } else { "📄" }
                            $Size = if (-not $_.PSIsContainer) { " ($([math]::Round($_.Length/1KB, 1)) KB)" } else { "" }
                            $Modified = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
                            Write-Host "      $Type $($_.Name)$Size - $Modified" -ForegroundColor $Yellow
                        }
                        
                        if ($Contents.Count -gt 10) {
                            Write-Host "      ... i $($Contents.Count - 10) więcej elementów" -ForegroundColor $Yellow
                        }
                        
                        # Sprawdź czy to wygląda na projekt
                        $ProjectFiles = $Contents | Where-Object { 
                            $_.Name -eq "package.json" -or 
                            $_.Name -eq "README.md" -or 
                            $_.Name -like "*.ps1" -or
                            $_.Name -eq "frontend" -or
                            $_.Name -eq "backend"
                        }
                        
                        if ($ProjectFiles) {
                            Write-Host "    🎯 WYGLĄDA NA PROJEKT! Znalezione pliki projektowe:" -ForegroundColor $Green
                            foreach ($File in $ProjectFiles) {
                                $Type = if ($File.PSIsContainer) { "📁" } else { "📄" }
                                Write-Host "      $Type $($File.Name)" -ForegroundColor $Green
                            }
                        }
                        
                    } else {
                        Write-Host "    📋 Folder pusty" -ForegroundColor $Yellow
                    }
                } catch {
                    Write-Host "    ❌ Brak dostępu do zawartości: $($_.Exception.Message)" -ForegroundColor $Red
                }
                
                # Sprawdź rozmiar folderu
                try {
                    $Size = (Get-ChildItem $Path -Recurse -File | Measure-Object -Property Length -Sum).Sum
                    $SizeMB = [math]::Round($Size / 1MB, 2)
                    Write-Host "    📊 Rozmiar: $SizeMB MB" -ForegroundColor $Cyan
                } catch {
                    Write-Host "    📊 Nie można obliczyć rozmiaru" -ForegroundColor $Yellow
                }
                
            } else {
                Write-Host "    📄 Typ: Plik" -ForegroundColor $Cyan
                $SizeKB = [math]::Round($Item.Length / 1KB, 1)
                Write-Host "    📊 Rozmiar: $SizeKB KB" -ForegroundColor $Cyan
            }
        } else {
            Write-Host "  ❌ Nie istnieje" -ForegroundColor $Red
        }
    }
}

# Dodatkowe wyszukiwanie na pulpicie
Write-Host ""
Write-Host "🔍 DODATKOWE WYSZUKIWANIE NA PULPICIE" -ForegroundColor $Cyan

$DesktopPath = "$env:USERPROFILE\Desktop"
if (Test-Path $DesktopPath) {
    Write-Host "Sprawdzanie pulpitu: $DesktopPath" -ForegroundColor $Yellow
    
    # Szukaj folderów z nazwami zawierającymi kluczowe słowa
    $Keywords = @("Infini", "Core", "Cipher", "Startup", "Code")
    
    foreach ($Keyword in $Keywords) {
        $Found = Get-ChildItem $DesktopPath -Directory -Name "*$Keyword*" -ErrorAction SilentlyContinue
        if ($Found) {
            Write-Host "  ✅ Znaleziono foldery z '$Keyword':" -ForegroundColor $Green
            foreach ($Folder in $Found) {
                Write-Host "    📁 $Folder" -ForegroundColor $Yellow
            }
        }
    }
    
    # Pokaż wszystkie foldery na pulpicie
    $AllFolders = Get-ChildItem $DesktopPath -Directory -ErrorAction SilentlyContinue
    if ($AllFolders) {
        Write-Host ""
        Write-Host "  📋 Wszystkie foldery na pulpicie:" -ForegroundColor $Cyan
        foreach ($Folder in $AllFolders) {
            Write-Host "    📁 $($Folder.Name)" -ForegroundColor $Yellow
        }
    }
} else {
    Write-Host "❌ Nie można uzyskać dostępu do pulpitu" -ForegroundColor $Red
}

Write-Host ""
Write-Host "=== KONIEC SPRAWDZANIA ===" -ForegroundColor $Cyan