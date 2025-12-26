# ============================================
# Microsoft Quick Start - Szybki Start
# ============================================

Write-Host "=== MICROSOFT ORGANIZATION SETUP - QUICK START ===" -ForegroundColor Cyan

# KROK 1: Najpierw utwórz organizację przez przeglądarkę
Write-Host "`n[1] Otwórz w przeglądarce: https://azure.microsoft.com/free/" -ForegroundColor Yellow
Write-Host "    Lub dla deweloperów: https://developer.microsoft.com/microsoft-365/dev-program" -ForegroundColor Yellow
Read-Host "`nNaciśnij Enter gdy utworzysz organizację i wrócisz tutaj"

# KROK 2: Połącz się z Microsoft Graph
Write-Host "`n[2] Łączenie z Microsoft Graph (Entra ID)..." -ForegroundColor Green
try {
    Connect-MgGraph -Scopes @(
        'User.ReadWrite.All',
        'Group.ReadWrite.All', 
        'Directory.ReadWrite.All',
        'Domain.ReadWrite.All',
        'Organization.ReadWrite.All',
        'RoleManagement.ReadWrite.Directory'
    ) -NoWelcome
    
    $context = Get-MgContext
    Write-Host "✓ Połączono jako: $($context.Account)" -ForegroundColor Green
    Write-Host "✓ Tenant ID: $($context.TenantId)" -ForegroundColor Green
    
    # Sprawdź organizację
    $org = Get-MgOrganization
    Write-Host "✓ Organizacja: $($org.DisplayName)" -ForegroundColor Green
    Write-Host "✓ Domeny:" -ForegroundColor Green
    Get-MgDomain | Select-Object Id, IsDefault, IsVerified | Format-Table
    
} catch {
    Write-Host "✗ Błąd połączenia: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# KROK 3: Połącz się z Power Platform
Write-Host "`n[3] Łączenie z Power Platform..." -ForegroundColor Green
try {
    Add-PowerAppsAccount
    
    Write-Host "✓ Połączono z Power Platform" -ForegroundColor Green
    Write-Host "✓ Środowiska:" -ForegroundColor Green
    Get-AdminPowerAppEnvironment | Select-Object DisplayName, Location, EnvironmentType | Format-Table
    
} catch {
    Write-Host "✗ Błąd połączenia Power Platform: $($_.Exception.Message)" -ForegroundColor Red
}

# KROK 4: Podsumowanie
Write-Host "`n=== PODSUMOWANIE ===" -ForegroundColor Cyan
Write-Host "✓ Połączono z Microsoft Graph (Entra ID)" -ForegroundColor Green
Write-Host "✓ Połączono z Power Platform" -ForegroundColor Green

Write-Host "`n=== CO DALEJ? ===" -ForegroundColor Yellow
Write-Host "1. Dodaj użytkowników:"
Write-Host "   `$pwd = @{Password='TymczasoweHaslo123!'; ForceChangePasswordNextSignIn=`$true}"
Write-Host "   New-MgUser -DisplayName 'Jan Kowalski' -UserPrincipalName 'jan@domena.onmicrosoft.com' -MailNickname 'jan' -AccountEnabled -PasswordProfile `$pwd"

Write-Host "`n2. Dodaj domenę niestandardową:"
Write-Host "   New-MgDomain -Id 'twoja-domena.com'"
Write-Host "   Get-MgDomainVerificationDnsRecord -DomainId 'twoja-domena.com'"

Write-Host "`n3. Utwórz środowisko Power Platform:"
Write-Host "   New-AdminPowerAppEnvironment -DisplayName 'Development' -LocationName 'europe' -EnvironmentSku 'Trial'"

Write-Host "`n4. Zobacz pełny przewodnik:"
Write-Host "   .\Microsoft-Setup-Guide.ps1" -ForegroundColor Cyan

Write-Host "`n=== PRZYDATNE PORTALE ===" -ForegroundColor Yellow
Write-Host "Azure Portal: https://portal.azure.com"
Write-Host "Entra ID: https://entra.microsoft.com"
Write-Host "Microsoft 365 Admin: https://admin.microsoft.com"
Write-Host "Power Platform: https://admin.powerplatform.microsoft.com"
Write-Host "Power Apps: https://make.powerapps.com"
