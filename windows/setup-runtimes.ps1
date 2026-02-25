Write-Host "Setting up Language Runtimes..." -ForegroundColor Cyan

# Windowsでは mise の代わりに Winget または各インストーラを使用
$runtimes = @(
    "GoLang.Go",
    "Python.Python.3",
    "Nodejs.Nodejs.LTS"
)

foreach ($runtime in $runtimes) {
    Write-Host "Installing $runtime..."
    winget install --id $runtime -e --source winget --silent
}

Write-Host "Runtimes setup complete." -ForegroundColor Green
