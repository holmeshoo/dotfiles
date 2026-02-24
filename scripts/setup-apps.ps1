Write-Host "Installing Heavy Applications..." -ForegroundColor Cyan

# List of [WingetID:CommandName]
$apps = @(
    "Microsoft.VisualStudioCode:code",
    "Vivaldi.Vivaldi:vivaldi",
    "Docker.DockerCLI:docker",
    "Docker.DockerCompose:docker-compose"
)

foreach ($item in $apps) {
    $parts = $item.Split(":")
    $id = $parts[0]
    $cmd = $parts[1]

    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        Write-Host "$id is already available (as $cmd). Skipping..." -ForegroundColor Yellow
    } else {
        Write-Host "Installing $id..." -ForegroundColor Green
        winget install --id $id -e --source winget --silent
    }
}

Write-Host "Applications installed." -ForegroundColor Green
