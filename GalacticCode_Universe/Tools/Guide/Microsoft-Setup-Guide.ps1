# ============================================
# Microsoft Organization Complete Setup Guide
# ============================================

Write-Host "=== KROK 1: Utworzenie Organizacji Microsoft ===" -ForegroundColor Cyan

Write-Host "`nOpcja A: Azure Free Account (Najlepsza dla większości)" -ForegroundColor Yellow
Write-Host "1. Otwórz: https://azure.microsoft.com/free/"
Write-Host "2. Kliknij 'Start free' lub 'Rozpocznij za darmo'"
Write-Host "3. Zaloguj się lub utwórz nowe konto Microsoft"
Write-Host "4. Wypełnij formularz:"
Write-Host "   - Kraj: Poland"
Write-Host "   - Imię i nazwisko"
Write-Host "   - Email weryfikacyjny"
Write-Host "   - Numer telefonu (do weryfikacji)"
Write-Host "   - Karta kredytowa (nie będzie obciążona dla free tier)"
Write-Host "5. Otrzymasz tenant z domeną: TWOJA-NAZWA.onmicrosoft.com"

Write-Host "`nOpcja B: Microsoft 365 Developer Program (Dla deweloperów)" -ForegroundColor Yellow
Write-Host "1. Otwórz: https://developer.microsoft.com/microsoft-365/dev-program"
Write-Host "2. Kliknij 'Join now'"
Write-Host "3. Zaloguj się kontem Microsoft"
Write-Host "4. Wypełnij ankietę (cel: development/testing)"
Write-Host "5. Skonfiguruj E5 subscription:"
Write-Host "   - Utwórz nazwę subskrypcji"
Write-Host "   - Wybierz username i hasło administratora"
Write-Host "   - Otrzymasz 25 licencji E5 na 90 dni (odnawialne)"

Write-Host "`nOpcja C: Microsoft 365 Business Trial" -ForegroundColor Yellow
Write-Host "1. Otwórz: https://www.microsoft.com/microsoft-365/business/compare-all-microsoft-365-business-products"
Write-Host "2. Wybierz plan (np. Business Premium)"
Write-Host "3. Kliknij 'Try free for 1 month'"
Write-Host "4. Utworzy nową organizację z 30-dniowym trial"

Write-Host "`n`n=== KROK 2: Połączenie z Microsoft Graph (Entra ID) ===" -ForegroundColor Cyan
Write-Host @"
# Zainstaluj moduł (jeśli nie zainstalowany)
Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force

# Połącz się z pełnymi uprawnieniami
Connect-MgGraph -Scopes @(
    'User.ReadWrite.All',
    'Group.ReadWrite.All', 
    'Directory.ReadWrite.All',
    'Domain.ReadWrite.All',
    'Organization.ReadWrite.All',
    'RoleManagement.ReadWrite.Directory'
)

# Sprawdź połączenie
Get-MgContext | Select-Object Account, Scopes, TenantId

# Sprawdź informacje o organizacji
Get-MgOrganization | Select-Object DisplayName, VerifiedDomains
"@

Write-Host "`n`n=== KROK 3: Dodanie Domeny Niestandardowej ===" -ForegroundColor Cyan
Write-Host @"
# 1. Sprawdź aktualne domeny
Get-MgDomain | Select-Object Id, IsDefault, IsVerified

# 2. Dodaj nową domenę
New-MgDomain -Id 'twoja-domena.com'

# 3. Pobierz rekordy DNS do weryfikacji
`$dnsRecords = Get-MgDomainVerificationDnsRecord -DomainId 'twoja-domena.com'
`$dnsRecords | Format-List

# 4. Dodaj rekord TXT w DNS swojej domeny:
#    Typ: TXT
#    Host: @ lub twoja-domena.com
#    Value: (wartość z powyższej komendy)
#    TTL: 3600

# 5. Poczekaj 15-30 minut i zweryfikuj domenę
Confirm-MgDomain -DomainId 'twoja-domena.com'

# 6. Ustaw jako domenę domyślną (opcjonalnie)
Update-MgDomain -DomainId 'twoja-domena.com' -IsDefault
"@

Write-Host "`n`n=== KROK 4: Utworzenie Użytkowników ===" -ForegroundColor Cyan
Write-Host @"
# Utwórz hasło
`$PasswordProfile = @{
    Password = 'TymczasoweHaslo123!'
    ForceChangePasswordNextSignIn = `$true
}

# Utwórz użytkownika
New-MgUser -DisplayName 'Jan Kowalski' ``
    -UserPrincipalName 'jan.kowalski@twoja-domena.onmicrosoft.com' ``
    -MailNickname 'jan.kowalski' ``
    -AccountEnabled ``
    -PasswordProfile `$PasswordProfile

# Pobierz wszystkich użytkowników
Get-MgUser -All | Select-Object DisplayName, UserPrincipalName, Id

# Dodaj użytkownika do grupy administratorów (opcjonalnie)
`$userId = (Get-MgUser -Filter "userPrincipalName eq 'jan.kowalski@twoja-domena.onmicrosoft.com'").Id
`$roleId = (Get-MgDirectoryRole -Filter "displayName eq 'Global Administrator'").Id
New-MgDirectoryRoleMemberByRef -DirectoryRoleId `$roleId -BodyParameter @{'@odata.id'="https://graph.microsoft.com/v1.0/directoryObjects/`$userId"}
"@

Write-Host "`n`n=== KROK 5: Utworzenie Grup ===" -ForegroundColor Cyan
Write-Host @"
# Utwórz grupę bezpieczeństwa
New-MgGroup -DisplayName 'Developers' ``
    -MailEnabled:`$false ``
    -MailNickname 'developers' ``
    -SecurityEnabled ``
    -Description 'Grupa developerów'

# Utwórz grupę Microsoft 365
New-MgGroup -DisplayName 'Team Marketing' ``
    -MailEnabled ``
    -MailNickname 'marketing' ``
    -SecurityEnabled ``
    -GroupTypes @('Unified') ``
    -Description 'Zespół marketingowy'

# Dodaj użytkownika do grupy
`$groupId = (Get-MgGroup -Filter "displayName eq 'Developers'").Id
`$userId = (Get-MgUser -Filter "displayName eq 'Jan Kowalski'").Id
New-MgGroupMember -GroupId `$groupId -DirectoryObjectId `$userId

# Sprawdź grupy
Get-MgGroup -All | Select-Object DisplayName, Mail, Id
"@

Write-Host "`n`n=== KROK 6: Połączenie z Power Platform ===" -ForegroundColor Cyan
Write-Host @"
# Zainstaluj moduły Power Platform
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser -Force
Install-Module -Name Microsoft.PowerApps.PowerShell -Scope CurrentUser -Force

# Połącz się z Power Platform
Add-PowerAppsAccount

# Sprawdź środowiska
Get-AdminPowerAppEnvironment | Select-Object DisplayName, EnvironmentName, Location

# Utwórz nowe środowisko
New-AdminPowerAppEnvironment -DisplayName 'Development' ``
    -LocationName 'europe' ``
    -EnvironmentSku 'Trial'

# Sprawdź aplikacje Power Apps
Get-AdminPowerApp | Select-Object DisplayName, AppName, Owner

# Sprawdź przepływy Power Automate
Get-AdminFlow | Select-Object DisplayName, FlowName, CreatedTime
"@

Write-Host "`n`n=== KROK 7: Konfiguracja Bezpieczeństwa ===" -ForegroundColor Cyan
Write-Host @"
# Włącz MFA dla administratorów
# (Zrób to przez portal Azure: portal.azure.com > Entra ID > Security > MFA)

# Utwórz politykę dostępu warunkowego
New-MgIdentityConditionalAccessPolicy -DisplayName 'Require MFA for Admins' ``
    -State 'enabled' ``
    -Conditions @{
        Users = @{
            IncludeRoles = @('62e90394-69f5-4237-9190-012177145e10') # Global Admin
        }
    } ``
    -GrantControls @{
        Operator = 'OR'
        BuiltInControls = @('mfa')
    }

# Sprawdź polityki bezpieczeństwa
Get-MgIdentityConditionalAccessPolicy | Select-Object DisplayName, State

# Włącz audit logging
# (Konfiguruj przez portal Azure: Entra ID > Audit logs > Diagnostic settings)
"@

Write-Host "`n`n=== KROK 8: Przypisanie Licencji ===" -ForegroundColor Cyan
Write-Host @"
# Sprawdź dostępne licencje
Get-MgSubscribedSku | Select-Object SkuPartNumber, ConsumedUnits -ExpandProperty PrepaidUnits

# Przypisz licencję użytkownikowi
`$userId = (Get-MgUser -Filter "displayName eq 'Jan Kowalski'").Id
`$skuId = (Get-MgSubscribedSku -All | Where-Object {`$_.SkuPartNumber -eq 'DEVELOPERPACK_E5'}).SkuId

Set-MgUserLicense -UserId `$userId ``
    -AddLicenses @{SkuId = `$skuId} ``
    -RemoveLicenses @()

# Sprawdź przypisane licencje użytkownika
Get-MgUserLicenseDetail -UserId `$userId | Select-Object SkuPartNumber
"@

Write-Host "`n`n=== KROK 9: Konfiguracja Power Platform w Szczegółach ===" -ForegroundColor Cyan
Write-Host @"
# Ustaw polityki DLP (Data Loss Prevention)
New-AdminDlpPolicy -DisplayName 'Production DLP' ``
    -EnvironmentName 'Default-xxxxx' ``
    -BlockNonBusinessDataGroup @()

# Utwórz niestandardowe środowisko z Dataverse
New-AdminPowerAppEnvironment -DisplayName 'Production' ``
    -LocationName 'europe' ``
    -EnvironmentSku 'Production' ``
    -ProvisionDatabase

# Sprawdź połączenia
Get-AdminPowerAppConnection -EnvironmentName 'Default-xxxxx' | Select-Object ConnectionName, DisplayName

# Eksportuj raport użycia
Get-AdminPowerAppConnectionRoleAssignment -EnvironmentName 'Default-xxxxx' | Export-Csv -Path 'connections.csv'
"@

Write-Host "`n`n=== KROK 10: Monitoring i Raporty ===" -ForegroundColor Cyan
Write-Host @"
# Pobierz logi audytu
Get-MgAuditLogDirectoryAudit -Top 50 | Select-Object ActivityDateTime, ActivityDisplayName, InitiatedBy

# Pobierz logi logowania
Get-MgAuditLogSignIn -Top 50 | Select-Object CreatedDateTime, UserPrincipalName, Status

# Raport użytkowników
Get-MgUser -All | Select-Object DisplayName, UserPrincipalName, AccountEnabled, CreatedDateTime | Export-Csv -Path 'users-report.csv'

# Raport grup
Get-MgGroup -All | Select-Object DisplayName, Mail, GroupTypes, CreatedDateTime | Export-Csv -Path 'groups-report.csv'

# Sprawdź stan usług Microsoft 365
# (Zobacz: https://status.office365.com lub admin.microsoft.com > Health > Service health)
"@

Write-Host "`n`n=== PRZYDATNE LINKI ===" -ForegroundColor Cyan
Write-Host @"
Portal Azure: https://portal.azure.com
Portal Entra ID: https://entra.microsoft.com
Portal Microsoft 365 Admin: https://admin.microsoft.com
Power Platform Admin Center: https://admin.powerplatform.microsoft.com
Power Apps: https://make.powerapps.com
Power Automate: https://make.powerautomate.com
Teams Admin: https://admin.teams.microsoft.com

Dokumentacja:
- Microsoft Graph: https://learn.microsoft.com/graph/
- Power Platform: https://learn.microsoft.com/power-platform/
- Entra ID: https://learn.microsoft.com/entra/
"@

Write-Host "`n`n=== GOTOWE! ===" -ForegroundColor Green
Write-Host "Możesz teraz wykonać kolejne kroki zgodnie z powyższym przewodnikiem." -ForegroundColor Green
