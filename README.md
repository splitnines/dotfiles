# Dotfiles

Personal Linux/WSL dotfiles for shell, terminal, editor, WM, and desktop UI.

This repository is organized as GNU Stow packages. Each top-level directory
contains files that are symlinked into `$HOME`.

## Repository layout

- `zsh/` - Zsh shell config (`~/.zshrc`), prompt, aliases, fzf helpers,
  python venv helpers, weather completion, auto-venv activation.
- `nvim/` - Neovim config (`~/.config/nvim`), plugins via `lazy.nvim`, LSP,
  telescope, cmp, treesitter, formatting, and UI styling.
- `tmux/` - tmux config (`~/.tmux.conf`), vi key mode, clipboard integration,
  popup session launcher, OneDark-inspired statusline.
- `i3/` - i3 WM config (`~/.config/i3/config`), keybindings, startup apps,
  workspace setup, audio/screenshot shortcuts.
- `polybar/` - Polybar top bar config + scripts (`launch.sh`, `volume.sh`).
- `picom/` - compositor config and launcher with NVIDIA-specific tuning.
- `rofi/` - rofi launcher theme and behavior.
- `dunst/` - notification daemon config.
- `alacritty/` - terminal emulator config and keybindings.
- `ssh/` - SSH agent bootstrap script loaded from shell startup.
- `onedark/` - shared OneDark color scripts and dircolors theme.
- `autotiling/` - Python autotiling daemon for i3/sway (`i3ipc` based).
- `aim/` - Aim CLI config and prompt templates.

Top-level supporting files:

- `bg` - wallpaper referenced by i3 config.
- `local_colors.lua` - optional local Neovim UI overrides.
- `.gitignore` - repository ignore rules.

## Core dependencies

Install these first:

- `git`
- `stow`
- `zsh`
- `tmux`
- `neovim` (current config expects a modern release with `vim.lsp.config`)
- `fzf` (repo expects current upstream install in `~/.fzf`)
- `ripgrep` (`rg`) for Telescope live grep
- Nerd Font: `JetBrainsMono Nerd Font`

## Desktop/runtime dependencies (Linux)

Required for the i3 desktop flow configured here:

- `i3` (or sway for autotiling.py logic)
- `polybar`
- `picom`
- `rofi`
- `dunst`
- `dex`
- `parcellite`
- `clipman`
- `nm-applet`
- `xss-lock`
- `i3lock`
- `hsetroot`
- `flameshot`
- `wpctl` (PipeWire / WirePlumber)
- `xclip` and/or `xsel` (clipboard integrations)
- `lspci` (used by picom launcher for NVIDIA detection)

## Bootstrap packages by distro

Use one of these as a starting point, then install Neovim LSP/tools in the
next section.

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install -y \
  git stow zsh tmux neovim ripgrep fzf \
  i3 polybar picom rofi dunst dex parcellite clipman \
  network-manager-gnome xss-lock i3lock hsetroot flameshot \
  pipewire wireplumber wl-clipboard xclip xsel pciutils \
  x11-xserver-utils xdotool curl wget make gcc
```

### Fedora

```bash
sudo dnf install -y \
  git stow zsh tmux neovim ripgrep fzf \
  i3 polybar picom rofi dunst dex-autostart parcellite clipman \
  NetworkManager-applet xss-lock i3lock hsetroot flameshot \
  pipewire wireplumber wl-clipboard xclip xsel pciutils \
  xsetroot xset xdotool curl wget make gcc
```

### Arch Linux

```bash
sudo pacman -S --needed \
  git stow zsh tmux neovim ripgrep fzf \
  i3-wm polybar picom rofi dunst dex parcellite clipman \
  network-manager-applet xss-lock i3lock-color hsetroot flameshot \
  pipewire wireplumber wl-clipboard xclip xsel pciutils \
  xorg-xsetroot xorg-xset xdotool curl wget make gcc
```

Notes:

- Package names can differ slightly by distro/repo.
- `JetBrainsMono Nerd Font` is usually installed separately (Nerd Fonts release
  tarball or distro font package).
- `wpctl` is provided by PipeWire/WirePlumber userland.
- `bash-language-server` is usually installed via npm:

```bash
sudo npm install -g bash-language-server
```

- Python tools used by Neovim and `autotiling` can be installed via `uv`:

```bash
uv tool install ruff
uv tool install ty
```

## Python dependencies (autotiling)

The `autotiling` package uses:

- Python `>= 3.13`
- `uv`
- Python package `i3ipc>=2.2.1`

The launcher script currently runs:

- `~/.config/autotiling/.venv/bin/python autotiling.py`

If your username/path differs, update that script accordingly.

## Neovim dependencies and toolchain

### Plugin/runtime requirements

- `git` (plugin installs)
- `make` (for `telescope-fzf-native.nvim` build)
- Treesitter compiler toolchain (`gcc`/`clang`, `make`)
- Language servers/tools used by config:
  - `lua-language-server`
  - `clangd`
  - `bash-language-server`
  - `ruff`
  - `ty`

Notes:

- `mason.nvim` and related plugins are configured for tooling management.
- `gp.nvim` expects `OPENAI_API_KEY` in the environment.

### External command usage inside Neovim config

Some custom commands call system tools:

- `column`, `sort`, `awk`, `head`, `tail`, `cat`, `sh` (CSV tools)
- `rg` through Telescope pickers

## Install and stow

Clone and stow selected packages:

```bash
git clone https://github.com/splitnines/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh nvim tmux ssh onedark alacritty i3 polybar picom rofi dunst autotiling aim
```

If you only want shell/editor basics:

```bash
stow zsh nvim tmux ssh onedark
```

## fzf setup (recommended)

This repo prefers upstream fzf binaries in `~/.fzf/bin`:

```bash
rm -rf ~/.fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --bin
```

## Post-install checklist

- Set default shell to zsh (if needed): `chsh -s /usr/bin/zsh`
- Ensure `~/.config/local/i3/config.local` exists (i3 includes it)
- Ensure wallpaper path `~/dotfiles/bg` exists
- Install JetBrainsMono Nerd Font
- Export secrets in `~/.myenv` or shell env:
  - `OPENAI_API_KEY` for `gp.nvim`
- For local shell-only aliases/secrets, use:
  - `~/.local_aliases`
  - `~/.myenv`

## What each major config file does

### Shell and terminal

- `zsh/.zshrc`
  - PATH setup (Linux + WSL handling)
  - OneDark colors loading
  - custom prompt with git dirty marker + python venv indicator
  - history tuning, vi mode, completion styles
  - git aliases and utility aliases
  - fzf-powered functions (`fh`, `fv`, `fcd`, `fsh`, `fsa`, `fk`)
  - python venv helpers (`pyon`, `pyoff`) and auto-venv on `cd`
  - SSH agent bootstrap invocation
- `alacritty/.config/alacritty/alacritty.toml`
  - OneDark-ish palette, transparent dark background, Nerd Font, vi mode toggle,
    paste/reset font keybinds.
- `tmux/.tmux.conf`
  - Prefix on `C-a`, vi key mode, mouse support, custom statusline,
    pane/session management, clipboard copy via `xsel`, popup terminal session.

### Window manager and desktop UI

- `i3/.config/i3/config`
  - startup orchestration (polybar, picom, dunst, dex, clipboard managers)
  - workspace naming/binds, split/layout controls, resize mode
  - audio/media keys (PipeWire), lock/screen timeout, screenshot keys
  - launches autotiling helper on startup
- `polybar/.config/polybar/config.ini`
  - top bar with i3 workspaces, date/time, CPU/disk/memory, volume/mic/tray
- `polybar/.config/polybar/launch.sh`
  - restarts polybar and launches one instance per monitor
- `polybar/.config/polybar/volume.sh`
  - volume label/icons via `wpctl`
- `picom/.config/picom/picom.conf`
  - compositor backend/vsync and Alacritty opacity rule
- `picom/.config/picom/picom-nvidia.conf`
  - NVIDIA GLX adjustments
- `picom/.config/picom/launch.sh`
  - safe startup and optional NVIDIA config append
- `rofi/.config/rofi/config.rasi`
  - launcher styling (colors, border radius, sizing)
- `dunst/.config/dunst/dunstrc`
  - notification font, spacing/history, urgency colors.

### Neovim core

- `nvim/.config/nvim/init.lua`
  - entrypoint requiring `core.*` and plugin setup.
- `nvim/.config/nvim/lua/core/options.lua`
  - editor options, diagnostics UI behavior, shell, clipboard, spellfile.
- `nvim/.config/nvim/lua/core/keymaps.lua`
  - keymaps for window movement, telescope, gp.nvim, diagnostics, markdown,
    spell toggle, and navigation.
- `nvim/.config/nvim/lua/core/autocmds.lua`
  - filetype indentation rules, yank highlight, clangd attach logic,
    gx open behavior, python format-on-save via ruff.

### Neovim plugin config files

- `nvim/.config/nvim/lua/plugins/init.lua` - bootstraps and configures lazy.nvim.
- `nvim/.config/nvim/lua/plugins/ui.lua` - colorscheme and popup/floating UI highlights.
- `nvim/.config/nvim/lua/plugins/lsp.lua` - mason + LSP server config (`lua_ls`, `clangd`, `bashls`, `ruff`, `ty`).
- `nvim/.config/nvim/lua/plugins/telescope.lua` - telescope defaults, file browser, search keymaps.
- `nvim/.config/nvim/lua/plugins/conform.lua` - formatter setup (currently stylua configured).
- `nvim/.config/nvim/lua/plugins/cmp.lua` - completion setup (`nvim-cmp` + snippets/path/LSP).
- `nvim/.config/nvim/lua/plugins/treesitter.lua` - parser installs and syntax/indent enablement.
- `nvim/.config/nvim/lua/plugins/whichkey.lua` - keymap hint UI groups.
- `nvim/.config/nvim/lua/plugins/gitsigns.lua` - git gutter signs.
- `nvim/.config/nvim/lua/plugins/markdown.lua` - render-markdown plugin config.
- `nvim/.config/nvim/lua/plugins/todo-comments.lua` - TODO/FIX annotation highlighting + jumps.
- `nvim/.config/nvim/lua/plugins/autopairs.lua` - auto-pairs.
- `nvim/.config/nvim/lua/plugins/dressing.lua` - improved input/select UIs.
- `nvim/.config/nvim/lua/plugins/indent.lua` - indent guides.
- `nvim/.config/nvim/lua/plugins/surround.lua` - surround text objects.
- `nvim/.config/nvim/lua/plugins/smear.lua` - cursor animation.
- `nvim/.config/nvim/lua/plugins/undotree.lua` - undo tree toggle.
- `nvim/.config/nvim/lua/plugins/gp.lua` - AI chat/completion plugin agents.
- `nvim/.config/nvim/lua/plugins/extras.lua` - extra custom commands and lint toggle.
- `nvim/.config/nvim/lua/csv/tools.lua` - CSV utilities (`CSVSort*`, `CSVSelect`, `CSVAlign`, `CSVColumns`).

### SSH and colors

- `ssh/.ssh/ssh_agent.zsh`
  - starts/reuses ssh-agent, auto-adds `~/.ssh/id_*` private keys,
    writes `~/.ssh/agent_env`.
- `onedark/.config/onedark-colors.sh`
  - shared OneDark color variables for shell/scripts.
- `onedark/.dircolors-onedark`
  - dircolors theme for `ls` and completion visuals.

### Autotiling

- `autotiling/.config/autotiling/autotiling.py`
  - listens to i3/sway events and switches split orientation based on
    focused window dimensions; supports output/workspace filters and ratios.
- `autotiling/.config/autotiling/autotiling`
  - launch wrapper with PID tracking/restart behavior.
- `autotiling/.config/autotiling/pyproject.toml`
  - project metadata and dependency declaration (`i3ipc`).
- `autotiling/.config/autotiling/uv.lock`
  - lockfile for reproducible installs with `uv`.

### Aim CLI files

- `aim/.config/aim/aim_prompt.md` - system prompt for terminal-first AI output.
- `aim/.config/aim/aimrc.json` - model selection.
- `aim_prompt.md` / `aimrc.json` - mirrored top-level variants.

## Local machine customization

- `local_colors.lua` contains host-specific Neovim highlight overrides.
  If loaded manually, it can override popup and border highlights.

## Known assumptions

- This setup assumes Linux desktop components (i3/polybar/picom/etc).
- Some scripts assume standard GNU userland tools are available.
- Some paths are user-specific (notably autotiling launcher).
