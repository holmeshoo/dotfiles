Write-Host "Installing Heavy Applications via Winget..." -ForegroundColor Cyan

$listFile = Join-Path $PSScriptRoot "winget-apps.txt"

if (Test-Path $listFile) {
    $apps = Get-Content $listFile | Where-Object { $_ -and -not $_.StartsWith("#") }

    foreach ($item in $apps) {
        $parts = $item.Split(":")
        $id = $parts[0].Trim()
        $cmd = $parts[1].Trim()

        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            Write-Host "$id is already available. Skipping..." -ForegroundColor Yellow
        } else {
            Write-Host "Installing $id..." -ForegroundColor Green
            winget install --id $id -e --source winget --silent
        }
    }
}

# Link VSCode settings (Windows)
$vscSettingsDir = Join-Path $env:APPDATA "Code\User"
$vscSettingsSource = Join-Path $dotfilesDir "common\vscode\settings.json"
$vscSettingsTarget = Join-Path $vscSettingsDir "settings.json"

if (!(Test-Path $vscSettingsDir)) {
    New-Item -ItemType Directory -Path $vscSettingsDir -Force
}
Write-Host "Linking VSCode settings..." -ForegroundColor Yellow
New-Item -ItemType SymbolicLink -Path $vscSettingsTarget -Value $vscSettingsSource -Force

Write-Host "Applications installed." -ForegroundColor Green
