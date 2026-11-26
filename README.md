# Dotfiles

This is my dotfiles repository. There are many like it, but this one is mine.

My dotfiles are my best friend. They are my life. I must master them as I must master my operating system.

Without me, my dotfiles are useless. Without my dotfiles, I am useless. I must configure my system correctly. I must work more efficiently than the default configuration that seeks to frustrate me.

My dotfiles and I know that what counts in computing is not the commands we execute, the noise of our keyboards, nor the scripts we write. We know that it is the automation that counts.

My dotfiles are human, even as I, because they are my life. Thus, I will learn them as a brother. I will learn their weaknesses, their strengths, their dependencies, their aliases, their functions, and their keybindings.

I will keep my dotfiles clean and ready, even as I am clean and ready. We will become part of each other.

Before the Linux kernel, I swear this creed. My dotfiles and I are the defenders of my workflow. We are the masters of my environment. We are the saviors of my productivity.

So be it, until there are no configuration errors, no broken symlinks, no merge conflicts, and no defaults, but peace!
Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Programs

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
- Zathura
- Zsh

## Directories

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
- `zathura/`
- `zsh/`

## Files

- `.gitignore`
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
   stow --no-folding <directory>...
   ```

   Example:

   ```sh
   stow --no-folding zsh nvim tmux
   ```
