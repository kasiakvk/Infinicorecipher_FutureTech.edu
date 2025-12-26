# =====================================================
# Połączenie z Microsoft 365 Developer - Prosty skrypt
# =====================================================

Write-Host "`n=== POŁĄCZENIE Z MICROSOFT 365 DEVELOPER ===" -ForegroundColor Cyan

# Krok 1: Sprawdź czy masz konto
Write-Host "`n📌 WAŻNE PYTANIE:" -ForegroundColor Yellow
Write-Host "Czy masz już konto Microsoft 365 Developer?" -ForegroundColor White
Write-Host "(np. admin@twoja-firma.onmicrosoft.com)`n" -ForegroundColor Gray

$hasAccount = Read-Host "Wpisz 'tak' jeśli masz, 'nie' jeśli nie masz"

if ($hasAccount -ne 'tak') {
    Write-Host "`n❌ Najpierw musisz utworzyć konto M365 Developer!" -ForegroundColor Red
    Write-Host "`nOtwieranie strony rejestracji..." -ForegroundColor Yellow
    Start-Process "https://developer.microsoft.com/microsoft-365/dev-program"
    
    Write-Host "`nKROKI DO WYKONANIA:" -ForegroundColor Cyan
    Write-Host "1. Kliknij 'Join now'" -ForegroundColor White
    Write-Host "2. Zaloguj się kontem Microsoft" -ForegroundColor White
    Write-Host "3. Wypełnij formularz" -ForegroundColor White
    Write-Host "4. Wybierz 'Instant sandbox' (najszybsze)" -ForegroundColor White
    Write-Host "5. Poczekaj 1-10 minut" -ForegroundColor White
    Write-Host "6. Zapisz dane logowania!" -ForegroundColor White
    Write-Host "`nPo utworzeniu konta, uruchom ten skrypt ponownie.`n" -ForegroundColor Green
    exit
}

# Krok 2: Połącz z Microsoft Graph
Write-Host "`n✅ Świetnie! Łączę z Microsoft Graph..." -ForegroundColor Green
Write-Host "Za chwilę otworzy się okno przeglądarki.`n" -ForegroundColor Yellow

Write-Host "⚠️  WAŻNE:" -ForegroundColor Red
Write-Host "Zaloguj się kontem ORGANIZACYJNYM:" -ForegroundColor Red
Write-Host "  ✓ admin@twoja-firma.onmicrosoft.com" -ForegroundColor Green
Write-Host "  ✗ NIE osobistym kontem Microsoft (hotmail/outlook/live)`n" -ForegroundColor Red

Read-Host "Naciśnij Enter aby kontynuować"

try {
    Connect-MgGraph -Scopes 'User.ReadWrite.All','Group.ReadWrite.All','Directory.ReadWrite.All','Domain.ReadWrite.All' -NoWelcome
    
    $ctx = Get-MgContext
    
    if (-not $ctx.Account) {
        Write-Host "`n✗ Nie udało się połączyć" -ForegroundColor Red
        exit
    }
    
    Write-Host "`n✓ POŁĄCZONO Z MICROSOFT GRAPH!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host "Account: $($ctx.Account)" -ForegroundColor White
    Write-Host "Tenant ID: $($ctx.TenantId)" -ForegroundColor White
    
    # Sprawdź czy to konto organizacyjne
    try {
        $org = Get-MgOrganization -ErrorAction Stop
        
        Write-Host "`n✓ TO KONTO ORGANIZACYJNE!" -ForegroundColor Green
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        Write-Host "Organizacja: $($org.DisplayName)" -ForegroundColor Cyan
        
        Write-Host "`n📋 DOMENY:" -ForegroundColor Cyan
        Get-MgDomain | Select-Object @{N='Domena';E={$_.Id}}, @{N='Domyślna';E={$_.IsDefault}}, @{N='Zweryfikowana';E={$_.IsVerified}} | Format-Table -AutoSize
        
        Write-Host "`n👥 UŻYTKOWNICY (Top 10):" -ForegroundColor Cyan
        Get-MgUser -Top 10 | Select-Object DisplayName, UserPrincipalName | Format-Table -AutoSize
        
    } catch {
        Write-Host "`n❌ TO KONTO OSOBISTE (MSA), NIE ORGANIZACYJNE!" -ForegroundColor Red
        Write-Host "Potrzebujesz konta Microsoft 365 Developer.`n" -ForegroundColor Yellow
        Write-Host "Rozłączam..." -ForegroundColor Gray
        Disconnect-MgGraph
        exit
    }
    
    # Krok 3: Połącz z Power Platform
    Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host "Łączenie z Power Platform..." -ForegroundColor Cyan
    
    try {
        Add-PowerAppsAccount -ErrorAction Stop
        
        Write-Host "`n✓ POŁĄCZONO Z POWER PLATFORM!" -ForegroundColor Green
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        
        Write-Host "`n🌍 ŚRODOWISKA:" -ForegroundColor Cyan
        $envs = Get-AdminPowerAppEnvironment
        $envs | Select-Object DisplayName, Location, EnvironmentType | Format-Table -AutoSize
        
        Write-Host "`n📱 APLIKACJE POWER APPS:" -ForegroundColor Cyan
        $apps = Get-AdminPowerApp
        if ($apps) {
            $apps | Select-Object DisplayName, AppName, CreatedTime | Format-Table -AutoSize
        } else {
            Write-Host "Brak aplikacji (to normalne dla nowego konta)" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "`n⚠️  Błąd Power Platform: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Microsoft Graph działa poprawnie." -ForegroundColor Green
    }
    
    # Sukces!
    Write-Host "`n" -ForegroundColor Green
    Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✓ SUKCES! JESTEŚ POŁĄCZONY!             ║" -ForegroundColor Green
    Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Green
    
    Write-Host "`n🎯 CO MOŻESZ TERAZ ZROBIĆ:" -ForegroundColor Cyan
    Write-Host "1. Zarządzaj użytkownikami: Get-MgUser" -ForegroundColor White
    Write-Host "2. Twórz grupy: New-MgGroup" -ForegroundColor White
    Write-Host "3. Sprawdź Power Apps: Get-AdminPowerApp" -ForegroundColor White
    Write-Host "4. Zobacz środowiska: Get-AdminPowerAppEnvironment" -ForegroundColor White
    Write-Host "5. Uruchom pełny przewodnik: .\Microsoft-Setup-Guide.ps1`n" -ForegroundColor White
    
} catch {
    Write-Host "`n✗ Błąd: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nSprawdź czy:" -ForegroundColor Yellow
    Write-Host "1. Masz konto M365 Developer" -ForegroundColor White
    Write-Host "2. Zalogowałeś się ORGANIZACYJNYM kontem" -ForegroundColor White
    Write-Host "3. Masz połączenie z internetem`n" -ForegroundColor White
}
