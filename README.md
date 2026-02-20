# dotfiles

Multi-platform dotfiles for macOS, Linux, and Windows.

## Structure

- `common/`: Shared configurations (.gitconfig, .vimrc, etc.)
- `macos/`: macOS specific files (Brewfile, etc.)
- `linux/`: Linux specific files (.bashrc_local, etc.)
- `windows/`: Windows specific files (PowerShell profile, etc.)
- `scripts/`: Installation scripts

## Installation

### macOS / Linux

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

### Windows (PowerShell)

```powershell
.\scripts\install.ps1
```

## Customization

- Edit files in `common/` for shared settings.
- Platform-specific overrides can be added to:
  - `linux/.bashrc_local`
  - `macos/` (e.g., Brewfile)
  - `windows/Microsoft.PowerShell_profile.ps1`
