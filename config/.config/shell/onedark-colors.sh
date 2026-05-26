# ==========================================
# OneDark Color Palette (Universal Shell)
# ==========================================
# Source this file from zshrc, tmux.conf, or scripts:
#   source ~/.config/shell/onedark-colors.sh

# Base Colors (HEX)
ONEDARK_BLACK="#282c34"
ONEDARK_BRIGHT_BLACK="#3e4451"
ONEDARK_WHITE="#abb2bf"
ONEDARK_GRAY="#5c6370"

# Accents (HEX)
ONEDARK_RED="#e06c75"
ONEDARK_GREEN="#98c379"
ONEDARK_YELLOW="#e5c07b"
ONEDARK_BLUE="#61afef"
ONEDARK_MAGENTA="#c678dd"
ONEDARK_CYAN="#56b6c2"
ONEDARK_ORANGE="#fa9c05"

# ==========================================
# Zsh-Safe Color Variables (for PS1, etc.)
# ==========================================
ESC=$'\e'

RESET="%{${ESC}[0m%}"
BLACK="%{${ESC}[38;2;40;44;52m%}"
BRIGHT_BLACK="%{${ESC}[38;2;62;68;81m%}"
WHITE="%{${ESC}[38;2;171;178;191m%}"
GRAY="%{${ESC}[38;2;92;99;112m%}"

RED="%{${ESC}[38;2;224;108;117m%}"
GREEN="%{${ESC}[38;2;152;195;121m%}"
YELLOW="%{${ESC}[38;2;229;192;123m%}"
BLUE="%{${ESC}[38;2;97;175;239m%}"
MAGENTA="%{${ESC}[38;2;198;120;221m%}"
CYAN="%{${ESC}[38;2;86;182;194m%}"
ORANGE="%{${ESC}[38;2;250;156;5m%}"

# ==========================================
# ANSI Escape Colors (for scripts / Python helpers)
# ==========================================
E_RESET=$'\e[0m'
E_BLACK=$'\e[38;2;40;44;52m'
E_BRIGHT_BLACK=$'\e[38;2;62;68;81m'
E_WHITE=$'\e[38;2;171;178;191m'
E_GRAY=$'\e[38;2;92;99;112m'

E_RED=$'\e[38;2;224;108;117m'
E_GREEN=$'\e[38;2;152;195;121m'
E_YELLOW=$'\e[38;2;229;192;123m'
E_BLUE=$'\e[38;2;97;175;239m'
E_MAGENTA=$'\e[38;2;198;120;221m'
E_CYAN=$'\e[38;2;86;182;194m'
E_ORANGE=$'\e[38;2;250;156;5m'

# ==========================================
# Optional: Print Color Palette
# ==========================================
print_colors() {
  local BLOCK='█'
  printf "\n"
  printf "%b%s%b " "$E_BLACK" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_GRAY" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_RED" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_YELLOW" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_MAGENTA" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_ORANGE" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_BRIGHT_BLACK" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_WHITE" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_GREEN" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_BLUE" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_CYAN" "$BLOCK" "$E_RESET"
  printf "\n"
  printf "%b%-14s%s%b\n" "$E_BLACK" "BLACK" "#282c34" "$E_RESET"
  printf "%b%-14s%s%b\n" "$E_GRAY" "GRAY" "#5c6370" "$E_RESET"
  printf "%b%-14s%s%b\n" "$E_RED" "RED" "#e06c75" "$E_RESET"
  printf "%b%-14s%s%b\n" "$E_YELLOW" "YELLOW" "#e5c07b" "$E_RESET"
  printf "%b%-14s%s%b\n" "$E_MAGENTA" "MAGENTA" "#c678dd" "$E_RESET"
  printf "%b%-14s%s%b\n" "$E_ORANGE" "ORANGE" "#fa9c05" "$E_RESET"
  printf "%b%-14s%s%b\n" "$E_BRIGHT_BLACK" "BRIGHT_BLACK" "#3e4451" "$E_RESET"
  printf "%b%-14s%s%b\n" "$E_WHITE" "WHITE" "#abb2bf" "$E_RESET"
  printf "%b%-14s%s%b\n" "$E_GREEN" "GREEN" "#98c379" "$E_RESET"
  printf "%b%-14s%s%b\n" "$E_BLUE" "BLUE" "#61afef" "$E_RESET"
  printf "%b%-14s%s%b\n" "$E_CYAN" "CYAN" "#56b6c2" "$E_RESET"
  printf "%b%s%b " "$E_BLACK" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_GRAY" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_RED" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_YELLOW" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_MAGENTA" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_ORANGE" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_BRIGHT_BLACK" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_WHITE" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_GREEN" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_BLUE" "$BLOCK" "$E_RESET"
  printf "%b%s%b " "$E_CYAN" "$BLOCK" "$E_RESET"
  printf "\n"
}
