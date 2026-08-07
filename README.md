# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Programs

- Aim
- Alacritty
- Bash
- dunst
- gsimplecal
- i3
- Neovim
- Pi
- Picom
- Polybar
- Ranger
- Rofi
- Screenkey
- SSH
- tmux
- WirePlumber
- YARA
- Zathura
- Zsh

## Directories

- `aim/`
- `alacritty/`
- `applications/`
- `autotiling/`
- `bash/`
- `config/`
- `dunst/`
- `i3/`
- `local-bin/`
- `nvim/`
- `pi/`
- `picom/`
- `polybar/`
- `ranger/`
- `rofi/`
- `screenkey/`
- `ssh/`
- `tests/`
- `themes/`
- `tmux/`
- `wireplumber/`
- `yara/`
- `zathura/`
- `zsh/`

## Files

- `.gitignore`
- `.gp.md`
- `local_colors.lua`
- `README.md`

## Installation

1. Install Git and GNU Stow.
2. Clone the repository:

   ```sh
   git clone git@github.com:splitnines/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

3. Stow the required directories:

   ```sh
   stow <directory>...
   ```

   Example:

   ```sh
   stow zsh nvim tmux
   ```
