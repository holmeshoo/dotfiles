Write-Host "Setting up Language Runtimes..." -ForegroundColor Cyan

$dotfilesDir = Split-Path -Parent $PSScriptRoot

# 1. Try mise first (if installed)
if (Get-Command mise -ErrorAction SilentlyContinue) {
    Write-Host "Installing runtimes via mise..." -ForegroundColor Yellow
    mise install --yes
} else {
    # Fallback to Winget for basic runtimes
    $runtimes = @(
        "GoLang.Go",
        "Python.Python.3",
        "Nodejs.Nodejs.LTS"
    )
    foreach ($runtime in $runtimes) {
        Write-Host "Installing $runtime via Winget..."
        winget install --id $runtime -e --source winget --silent
    }
}

# 2. Install Global NPM Packages
if (Get-Command npm -ErrorAction SilentlyContinue) {
    $npmList = Join-Path $dotfilesDir "common\npm-packages.txt"
    if (Test-Path $npmList) {
        Write-Host "Installing global NPM packages..." -ForegroundColor Yellow
        $packages = Get-Content $npmList | Where-Object { $_ -and -not $_.StartsWith("#") }
        foreach ($pkg in $packages) {
            Write-Host "  -> $pkg"
            npm install -g $pkg.Trim()
        }
    }
}

# 3. Install Global Cargo Packages
if (Get-Command cargo -ErrorAction SilentlyContinue) {
    $cargoList = Join-Path $dotfilesDir "common\cargo-packages.txt"
    if (Test-Path $cargoList) {
        Write-Host "Installing global Cargo packages..." -ForegroundColor Yellow
        $packages = Get-Content $cargoList | Where-Object { $_ -and -not $_.StartsWith("#") }
        foreach ($pkg in $packages) {
            Write-Host "  -> $pkg"
            cargo install $pkg.Trim()
        }
    }
}

Write-Host "Runtimes and global packages installed." -ForegroundColor Green
