Write-Host "Installing Core Tools via Winget..." -ForegroundColor Cyan

# List of [WingetID:CommandName]
$tools = @(
    "zyedidia.micro:micro",
    "Git.Git:git",
    "aristocratos.btop:btop",
    "GNU.Wget:wget"
)

foreach ($item in $tools) {
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

Write-Host "Core Tools installed." -ForegroundColor Green
