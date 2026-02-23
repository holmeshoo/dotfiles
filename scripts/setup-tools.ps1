Write-Host "Installing Core Tools via Winget..." -ForegroundColor Cyan

$tools = @(
    "zyedidia.micro",
    "Git.Git",
    "aristocratos.btop",
    "GNU.Wget"
)

foreach ($tool in $tools) {
    Write-Host "Installing $tool..."
    winget install --id $tool -e --source winget --silent
}

Write-Host "Core Tools installed." -ForegroundColor Green
