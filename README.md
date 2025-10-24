# Dotfiles

These are my personal dotfiles for Linux and WSL environments.  
They define my shell, editor and terminal preferences.

## Overview

This repo includes configurations for:

- **Zsh** — custom prompt, aliases, fzf integration, Python venv indicator, etc...  
- **Tmux** — vi key bindings, mouse support, custom status bar, etc...  
- **Neovim** — plugin management with `lazy.nvim`, LSP, Mason, Telescope, Treesitter, and color themes, etc...
- **SSH** - ssh agent script that loads at shell start up, etc...
- **OneDark** - global color scheme

## Installation

Clone the repo and run the setup script:

```bash
git clone https://github.com/splitnines/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh nvim tmux ssh onedark
```

## Requirement

Latest version of fzf is needed

```bash
rm -rf ~/.fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --bin
sudo apt remove fzf
```

