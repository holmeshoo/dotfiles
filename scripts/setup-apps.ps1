Write-Host "Installing Heavy Applications..." -ForegroundColor Cyan

$apps = @(
    "Microsoft.VisualStudioCode",
    "Vivaldi.Vivaldi",
    "Docker.DockerCLI"
)

foreach ($app in $apps) {
    Write-Host "Installing $app..."
    winget install --id $app -e --source winget --silent
}

Write-Host "Applications installed." -ForegroundColor Green
