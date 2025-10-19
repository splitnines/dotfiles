# Dotfiles

These are my personal dotfiles for Linux and WSL environments.  
They define my shell, editor and terminal preferences.

## Overview

This repo includes configurations for:

- **Zsh** — custom prompt, aliases, fzf integration, Python venv indicator  
- **Tmux** — full-length commands, vi key bindings, mouse support, custom status bar  
- **Neovim** — plugin management with `lazy.nvim`, LSP, Mason, Telescope, Treesitter, and color themes  
- **Shell Utilities** — helper scripts and functions for navigation, search, and workflow automation  

## Installation

Clone the repo and run the setup script:

```bash
git clone https://github.com/splitnines/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh nvim tmux
```

