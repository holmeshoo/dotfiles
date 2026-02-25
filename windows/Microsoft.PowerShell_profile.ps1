# PowerShell Profile

# --- Path Settings ---
$env:PATH = "$HOME\.local\bin;$env:PATH"

# --- Aliases ---
Set-Alias g git
Set-Alias vi vim
function ll { Get-ChildItem -Force }
function la { Get-ChildItem -Force }

# Git Aliases (equivalent to .aliases)
function gs { git status }
function ga { git add $args }
function gc { git commit $args }
function gp { git push $args }
function gl { git log --oneline --graph --all }

# --- Utility Functions (equivalent to .functions) ---

# Create directory and enter it
function mkd($path) {
    New-Item -ItemType Directory -Path $path -Force
    Set-Location $path
}

# Display PATH in a readable list
function path {
    $env:PATH -split ";"
}

# Extract archive (PowerShell native)
function extract($file) {
    if (Test-Path $file) {
        Expand-Archive -Path $file -DestinationPath . -Force
    } else {
        Write-Error "File not found: $file"
    }
}

# --- Starship Prompt ---
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
