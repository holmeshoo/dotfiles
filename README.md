# dotfiles

⚠️ **Work In Progress**: This repository is currently under development and being actively updated.

Multi-platform dotfiles for macOS, Linux, and Windows.

## Structure

- `common/`: Shared configurations (.gitconfig, .vimrc, etc.)
- `macos/`: macOS specific files (Brewfile, etc.)
- `linux/`: Linux specific files (.bashrc_local, etc.)
- `windows/`: Windows specific files (PowerShell profile, etc.)
- `scripts/`:
    - `install.sh`: Main orchestrator (handles symlinking and calls other scripts).
    - `setup-macos.sh` / `setup-linux.sh`: OS-specific initializations.
    - `setup-tools.sh`: Core CLI tools (micro, git, etc.).
    - `setup-runtimes.sh`: Language runtimes (Node.js, Python via `mise`).
    - `setup-apps.sh`: Heavy applications (Docker, VSCode).

## Installation

### macOS / Linux (One-liner)

This script will automatically install `git` and `Homebrew` (on macOS) if they are missing, clone this repository to `~/dotfiles`, and set up your environment.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/holmeshoo/dotfiles/main/scripts/install.sh)"
```

### Manual Installation

```bash
git clone https://github.com/holmeshoo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/install.sh
```

### Windows (PowerShell)

```powershell
.\scripts\install.ps1
```

## Customization

- **Symlinks**: Edit `scripts/install.sh` to add or remove files to be linked.
- **Tools/Apps**: Modify the corresponding `scripts/setup-*.sh` files.
- **Local Overrides**: Use `~/.gitconfig.local`, `~/.bashrc_local`, or `~/.zshrc_local` for machine-specific settings.
