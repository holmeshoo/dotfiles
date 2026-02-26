Write-Host "Installing Heavy Applications via Winget..." -ForegroundColor Cyan

$listFile = Join-Path $PSScriptRoot "winget-apps.txt"

if (Test-Path $listFile) {
    # Using simple Split logic matching scripts/setup-apps.sh
    $lines = Get-Content $listFile | Where-Object { $_ -and -not $_.StartsWith("#") }

    foreach ($line in $lines) {
        $parts = $line.Split(":")
        $id = $parts[0].Trim()
        
        # We don't necessarily have a check_cmd for every winget app in the same way,
        # but Winget is smart enough skip already installed ones.
        Write-Host "Installing $id..." -ForegroundColor Green
        winget install --id $id -e --source winget --silent --accept-source-agreements --accept-package-agreements
    }
}

Write-Host "Applications installed." -ForegroundColor Green
