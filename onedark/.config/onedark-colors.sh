# ==========================================
# OneDark Color Palette (Universal Shell)
# ==========================================
# Source this file from zshrc, tmux.conf, or scripts:
#   source ~/.config/onedark-colors.sh

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
print_onedark_colors() {
  echo
  echo "  ${E_BLACK}BLACK${E_RESET}          ${E_BRIGHT_BLACK}BRIGHT_BLACK${E_RESET}"
  echo "  ${E_GRAY}GRAY${E_RESET}            ${E_WHITE}WHITE${E_RESET}"
  echo
  echo "  ${E_RED}RED${E_RESET}              ${E_GREEN}GREEN${E_RESET}"
  echo "  ${E_YELLOW}YELLOW${E_RESET}          ${E_BLUE}BLUE${E_RESET}"
  echo "  ${E_MAGENTA}MAGENTA${E_RESET}        ${E_CYAN}CYAN${E_RESET}"
  echo "  ${E_ORANGE}ORANGE${E_RESET}"
  echo
}
