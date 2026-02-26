Write-Host "Installing Core Tools (Windows)..." -ForegroundColor Cyan

$dotfilesDir = Split-Path -Parent $PSScriptRoot

# 1. Install Winget Packages
$listFile = Join-Path $PSScriptRoot "winget-packages.txt"
if (Test-Path $listFile) {
    $tools = Get-Content $listFile | Where-Object { $_ -and -not $_.StartsWith("#") }
    foreach ($id in $tools) {
        Write-Host "Installing $id via Winget..."
        winget install --id $id -e --source winget --silent --accept-source-agreements --accept-package-agreements
    }
}

# 2. Ensure mise and core runtimes are present for global packages
if (Get-Command mise -ErrorAction SilentlyContinue) {
    Write-Host "Ensuring runtimes for global packages..." -ForegroundColor Yellow
    mise use --global node@lts
    mise use --global rust@latest
}

# 3. Global NPM Packages (Equivalent to setup-tools.sh)
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

# 4. Global Cargo Packages (Equivalent to setup-tools.sh)
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

Write-Host "Core Tools installed." -ForegroundColor Green
