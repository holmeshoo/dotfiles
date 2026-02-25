Write-Host "Installing Fonts via Winget..." -ForegroundColor Cyan

$listFile = Join-Path $PSScriptRoot "winget-fonts.txt"

if (Test-Path $listFile) {
    $fonts = Get-Content $listFile | Where-Object { $_ -and -not $_.StartsWith("#") }

    foreach ($item in $fonts) {
        $parts = $item.Split(":")
        $id = $parts[0].Trim()
        
        # Winget doesn't always have a clear 'cmd' to check for fonts, 
        # so we'll just try to install. Winget handles 'already installed' well.
        Write-Host "Installing $id..." -ForegroundColor Green
        winget install --id $id -e --source winget --silent --accept-source-agreements --accept-package-agreements
    }
}

Write-Host "Fonts installation complete." -ForegroundColor Green
