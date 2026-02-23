Write-Host "Installing Heavy Applications..." -ForegroundColor Cyan

$apps = @(
    "Docker.DockerDesktop",
    "Microsoft.VisualStudioCode",
    "TheBrowserCompany.Arc",
    "Vivaldi.Vivaldi"
)

foreach ($app in $apps) {
    Write-Host "Installing $app..."
    winget install --id $app -e --source winget --silent
}

Write-Host "Applications installed." -ForegroundColor Green
