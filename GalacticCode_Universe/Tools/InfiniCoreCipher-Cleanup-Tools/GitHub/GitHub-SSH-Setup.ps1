# GitHub SSH Configuration Script
# Automatycznie dodaje klucze GitHub do known_hosts

Write-Host "=== GitHub SSH Configuration Script ===" -ForegroundColor Green
Write-Host "Konfiguracja SSH dla GitHub..." -ForegroundColor Yellow

# Sprawdź czy folder .ssh istnieje
$sshDir = "$env:USERPROFILE\.ssh"
if (!(Test-Path $sshDir)) {
    Write-Host "Tworzenie folderu .ssh..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}

# Ścieżka do pliku known_hosts
$knownHostsFile = "$sshDir\known_hosts"

# Oficjalne klucze GitHub (aktualne na grudzień 2024)
$githubKeys = @(
    "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl",
    "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=",
    "github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk="
)

Write-Host "Dodawanie kluczy GitHub do known_hosts..." -ForegroundColor Yellow

# Dodaj każdy klucz do known_hosts (jeśli jeszcze nie istnieje)
foreach ($key in $githubKeys) {
    if (Test-Path $knownHostsFile) {
        $existingContent = Get-Content $knownHostsFile -ErrorAction SilentlyContinue
        if ($existingContent -notcontains $key) {
            Add-Content -Path $knownHostsFile -Value $key
            Write-Host "✓ Dodano klucz: $($key.Split(' ')[1])" -ForegroundColor Green
        } else {
            Write-Host "✓ Klucz już istnieje: $($key.Split(' ')[1])" -ForegroundColor Cyan
        }
    } else {
        # Utwórz plik i dodaj klucz
        $key | Out-File -FilePath $knownHostsFile -Encoding UTF8
        Write-Host "✓ Utworzono known_hosts i dodano klucz: $($key.Split(' ')[1])" -ForegroundColor Green
    }
}

Write-Host "`n=== Konfiguracja SSH zakończona ===" -ForegroundColor Green
Write-Host "Klucze GitHub zostały dodane do known_hosts" -ForegroundColor Yellow
Write-Host "Możesz teraz bezpiecznie połączyć się z GitHub" -ForegroundColor Yellow

# Test połączenia SSH (opcjonalny)
Write-Host "`nTestowanie połączenia SSH z GitHub..." -ForegroundColor Yellow
try {
    $sshTest = ssh -T git@github.com 2>&1
    if ($sshTest -match "successfully authenticated") {
        Write-Host "✓ Połączenie SSH z GitHub działa poprawnie!" -ForegroundColor Green
    } else {
        Write-Host "⚠ Połączenie SSH wymaga konfiguracji klucza SSH" -ForegroundColor Yellow
        Write-Host "Wynik testu: $sshTest" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠ Nie można przetestować SSH (ssh nie jest dostępne)" -ForegroundColor Yellow
}

Write-Host "`n=== Gotowe do push na GitHub ===" -ForegroundColor Green
Write-Host "Użyj: git push -u origin main" -ForegroundColor Cyan