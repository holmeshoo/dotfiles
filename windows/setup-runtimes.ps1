Write-Host "Setting up Language Runtimes..." -ForegroundColor Cyan

# 1. Try mise (Standard approach)
if (Get-Command mise -ErrorAction SilentlyContinue) {
    Write-Host "Installing runtimes via mise..." -ForegroundColor Yellow
    # mise install uses .mise.toml (linked by install.ps1)
    mise install --yes
} else {
    # Fallback to Winget for basic runtimes if mise is missing
    Write-Warning "mise not found. Falling back to Winget for basic runtimes."
    $runtimes = @(
        "GoLang.Go",
        "Python.Python.3",
        "Nodejs.Nodejs.LTS"
    )
    foreach ($runtime in $runtimes) {
        Write-Host "Installing $runtime via Winget..."
        winget install --id $runtime -e --source winget --silent --accept-source-agreements --accept-package-agreements
    }
}

Write-Host "Runtimes setup complete." -ForegroundColor Green
