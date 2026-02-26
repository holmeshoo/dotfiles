# PowerShell Installation Script for dotfiles

$dotfilesDir = Split-Path -Parent $PSScriptRoot
$scriptsDir = $PSScriptRoot
$homeDir = $HOME

Write-Host "--- Dotfiles Installation (Windows) ---" -ForegroundColor Cyan

# --- 1. Symlinking (Early Step) ---
Write-Host "`nCreating symlinks..." -ForegroundColor Yellow

# Ensure local override files exist
$localFilesList = Join-Path $dotfilesDir "common\local-files.txt"
if (Test-Path $localFilesList) {
    $files = Get-Content $localFilesList | Where-Object { $_ -and -not $_.StartsWith("#") }
    foreach ($f in $files) {
        $fullPath = Join-Path $dotfilesDir "common\$($f.Trim())"
        if (!(Test-Path $fullPath)) {
            Write-Host "Creating template for $f"
            "# Local overrides (Not committed to git)" | Out-File -FilePath $fullPath -Encoding utf8
        }
    }
}

# Read and apply links (Common + Windows-specific)
$linksFiles = @(
    (Join-Path $dotfilesDir "common\links.txt"),
    (Join-Path $dotfilesDir "windows\links.txt")
)

foreach ($linksFile in $linksFiles) {
    if (Test-Path $linksFile) {
        Write-Host "Processing links from $(Split-Path -Leaf $linksFile)..."
        $lines = Get-Content $linksFile | Where-Object { $_ -and -not $_.StartsWith("#") }
        foreach ($line in $lines) {
            $parts = $line.Split(":")
            if ($parts.Count -lt 2) { continue }
            
            $srcName = $parts[0].Trim()
            $dstRel = $parts[1].Trim()
            
            $source = Join-Path $dotfilesDir "common\$srcName"
            $target = Join-Path $homeDir $dstRel
            
            if (!(Test-Path $source)) {
                Write-Warning "Source file $source not found. Skipping."
                continue
            }
            
            # Ensure target directory exists
            $targetDir = Split-Path $target
            if (!(Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force
            }
            
            # Remove existing link or file
            if (Test-Path $target) {
                Remove-Item -Path $target -Force -Recurse
            }
            
            Write-Host "Linking $dstRel"
            New-Item -ItemType SymbolicLink -Path $target -Value $source -Force
        }
    }
}

# --- 2. Interactive Installation Selection ---
function Confirm-Action($prompt) {
    $choice = Read-Host "$prompt [y/N]"
    return $choice -match "^[yY]$|^[yY][eE][sS]$"
}

Write-Host "`n--- Select Setup Levels ---" -ForegroundColor Yellow

$DO_CORE = $false
$DO_RUNTIME = $false
$DO_APPS = $false
$DO_FONTS = $false

if (Confirm-Action "Install EVERYTHING (Core, Language, Heavy, and Fonts)?") {
    $DO_CORE = $DO_RUNTIME = $DO_APPS = $DO_FONTS = $true
} else {
    $DO_CORE = Confirm-Action "1. [Core] CLI Tools?"
    $DO_RUNTIME = Confirm-Action "2. [Language] Runtimes?"
    $DO_APPS = Confirm-Action "3. [Heavy] Applications?"
    $DO_FONTS = Confirm-Action "4. [Fonts] System Fonts?"
}

# --- 3. Execution ---
if ($DO_RUNTIME) { & "$scriptsDir\setup-runtimes.ps1" }
if ($DO_CORE) { & "$scriptsDir\setup-tools.ps1" }
if ($DO_APPS) { & "$scriptsDir\setup-apps.ps1" }
if ($DO_FONTS) { & "$scriptsDir\setup-fonts.ps1" }

Write-Host "`nSuccessfully installed dotfiles!" -ForegroundColor Green
