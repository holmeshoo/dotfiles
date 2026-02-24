# PowerShell Installation Script for dotfiles

$dotfilesDir = Split-Path -Parent $PSScriptRoot
$scriptsDir = Join-Path $dotfilesDir "scripts"
$homeDir = $HOME

Write-Host "--- Dotfiles Installation (Windows) ---" -ForegroundColor Cyan

# 1. Symlinking Common Files
$commonFiles = @(
    "common\.gitconfig",
    "common\.vimrc",
    "common\.editorconfig",
    "common\.functions"
)

Write-Host "`nCreating symlinks..." -ForegroundColor Yellow
foreach ($file in $commonFiles) {
    $source = Join-Path $dotfilesDir $file
    # filenames in common already start with '.'
    $target = Join-Path $homeDir (Split-Path -Leaf $file)
    
    if (Test-Path $target) {
        Write-Warning "$target already exists. Skipping."
    } else {
        Write-Host "Linking $source to $target"
        New-Item -ItemType SymbolicLink -Path $target -Value $source -Force
    }
}

# 1.5 Special Symlink for mise (Windows)
$miseConfigDir = Join-Path $env:APPDATA "mise"
$miseConfigSource = Join-Path $dotfilesDir "common\.mise.toml"
$miseConfigTarget = Join-Path $miseConfigDir "config.toml"

if (!(Test-Path $miseConfigDir)) {
    New-Item -ItemType Directory -Path $miseConfigDir -Force
}
Write-Host "Linking mise config..." -ForegroundColor Yellow
New-Item -ItemType SymbolicLink -Path $miseConfigTarget -Value $miseConfigSource -Force

# 2. Setup PowerShell Profile
$profilePath = $PROFILE
$profileSource = Join-Path $dotfilesDir "windows\Microsoft.PowerShell_profile.ps1"

if (!(Test-Path (Split-Path $profilePath))) {
    New-Item -ItemType Directory -Path (Split-Path $profilePath) -Force
}

if (Test-Path $profilePath) {
    Write-Warning "PowerShell profile already exists at $profilePath. Manual linking might be required."
} else {
    Write-Host "Linking PowerShell profile..."
    New-Item -ItemType SymbolicLink -Path $profilePath -Value $profileSource -Force
}

# 3. Interactive Installation
function Confirm-Action($prompt) {
    $choice = Read-Host "$prompt [y/N]"
    return $choice -match "^[yY]$|^[yY][eE][sS]$"
}

Write-Host "`n--- Select Setup Levels ---" -ForegroundColor Yellow

if (Confirm-Action "Install EVERYTHING (Core, Language, and Heavy)?") {
    & "$scriptsDir\setup-tools.ps1"
    & "$scriptsDir\setup-runtimes.ps1"
    & "$scriptsDir\setup-apps.ps1"
} else {
    if (Confirm-Action "1. [Core] CLI Tools (micro, git, btop, etc.)?") { & "$scriptsDir\setup-tools.ps1" }
    if (Confirm-Action "2. [Language] Runtimes (Node, Python, Go)?") { & "$scriptsDir\setup-runtimes.ps1" }
    if (Confirm-Action "3. [Heavy] Applications (Docker, VSCode, Arc, Vivaldi)?") { & "$scriptsDir\setup-apps.ps1" }
}

Write-Host "`nSuccessfully installed dotfiles!" -ForegroundColor Green
