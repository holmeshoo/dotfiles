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

Write-Host "Applications installed." -ForegroundColor Green
