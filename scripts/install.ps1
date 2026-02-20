# PowerShell Installation Script

$dotfilesDir = Split-Path -Parent $PSScriptRoot
$homeDir = $HOME

Write-Host "Setting up dotfiles from $dotfilesDir"

# Common files
$files = @(
    "common\.gitconfig",
    "common\.vimrc",
    "common\.editorconfig"
)

# Windows specific
$profilePath = "$homeDir\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$profileSource = "$dotfilesDir\windows\Microsoft.PowerShell_profile.ps1"

# Create symlinks
foreach ($file in $files) {
    $source = Join-Path $dotfilesDir $file
    $target = Join-Path $homeDir (".$(Split-Path -Leaf $file)")
    
    if (Test-Path $target) {
        Write-Warning "$target already exists. Skipping."
    } else {
        Write-Host "Linking $source to $target"
        New-Item -ItemType SymbolicLink -Path $target -Value $source
    }
}

# Setup PowerShell profile
if (-not (Test-Path (Split-Path $profilePath))) {
    New-Item -ItemType Directory -Path (Split-Path $profilePath) -Force
}

if (Test-Path $profilePath) {
    Write-Warning "PowerShell profile already exists at $profilePath"
} else {
    Write-Host "Linking $profileSource to $profilePath"
    New-Item -ItemType SymbolicLink -Path $profilePath -Value $profileSource
}

Write-Host "Done!"
