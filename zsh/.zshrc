# ZSH config

# ===========================
# Path
# ===========================
typeset -U path PATH
path=(
  /usr/local/sbin
  /usr/local/bin
  /usr/sbin
  /usr/bin
  /sbin
  /bin
)
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "$HOME/bin" ]] && path=("$HOME/bin" $path)
[[ -d "$HOME/.cargo/bin" ]] && path=("$HOME/.cargo/bin" $path)
[[ -d "/usr/local/go/bin" ]] && path=("/usr/local/go/bin" $path)

# Windows interop (optional, WSL only)
if grep -qi "microsoft" /proc/version 2>/dev/null; then
    IS_WSL=true
else
    IS_WSL=false
fi

if $IS_WSL; then
    for p in /usr/lib/wsl/lib /mnt/c/WINDOWS/System32 /mnt/c/WINDOWS; do
        [[ -d $p ]] && path+=($p)
    done
fi

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export PATH

# ===========================
# Prompt
# ===========================
ESC=$'\e'

RESET="%{${ESC}[0m%}"
GRAY="%{${ESC}[38;2;64;64;64m%}"
GREEN="%{${ESC}[38;2;0;200;0m%}"
BLUE="%{${ESC}[38;2;68;157;252m%}"
RED="%{${ESC}[38;2;214;4;4m%}"
ORANGE="%{${ESC}[38;2;250;156;5m%}"

# add git dirty branch indication to prompt
git_branch() {
  local branch dirty
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  [[ -z $branch ]] && return

  local dirty_icon="⚡"

  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    dirty="$dirty_icon"
  else
    dirty=""
  fi

  printf " %s%s%s%s%s" "$RED" "$branch" "$ORANGE" "$dirty" "$RESET"
}

# add python venv indication to prompt
python_env() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local env_name=${VIRTUAL_ENV:t}
    printf "%s[%s%s%s]-%s" "$GRAY" "$GREEN" "$env_name" "$GRAY" "$RESET"
  fi
}

setopt PROMPT_SUBST
build_prompt() {
  PS1=$'\n'"$(python_env)${GRAY}[${BLUE}%n@%m${GRAY}]-[${RESET}${BLUE}%~${RESET}${GRAY}]$(git_branch)"$'\n'"${BLUE}❯ ${RESET}"
}
unsetopt PROMPT_CR
unsetopt PROMPT_SP

autoload -Uz add-zsh-hook
add-zsh-hook precmd build_prompt

# ===========================
# History
# ===========================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_DUPS       # Don't record duplicate commands
setopt HIST_IGNORE_SPACE      # Skip commands starting with a space
setopt HIST_REDUCE_BLANKS     # Remove extra blanks
setopt INC_APPEND_HISTORY      # Append to history immediately
setopt SHARE_HISTORY           # Share history across sessions
setopt APPEND_HISTORY          # Don’t overwrite, just append
setopt EXTENDED_HISTORY        # Record timestamps
setopt HIST_EXPIRE_DUPS_FIRST  # Drop oldest duplicates when trimming
setopt HIST_SAVE_NO_DUPS       # Don’t save duplicate entries

alias h='fc -li 1'

# Force write to history after each command
autoload -Uz add-zsh-hook
save_history_now() { fc -AI; }
add-zsh-hook precmd save_history_now

# ===========================
# Completion
# ===========================
autoload -Uz compinit && compinit

# Git completion & aliases
if type git &>/dev/null; then
  autoload -Uz bashcompinit && bashcompinit
  source <(git completion zsh 2>/dev/null || git completion bash 2>/dev/null)
fi

# git aliases
alias g='git'
alias ga='git add .'
alias gb='git branch'
alias gc='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias pull='git pull'
alias push='git push'
alias gs='git status'

# ===========================
# Tab completion enhancements
# ===========================

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}:ma=48;5;238;38;5;229"
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*'

setopt AUTO_MENU
setopt AUTO_LIST
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt AUTO_PARAM_SLASH
setopt MENU_COMPLETE

# ===========================
# Autocorrection
# ===========================
setopt CORRECT
setopt CORRECT_ALL

# ===========================
# Misc settings
# ===========================
DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="true"

# pager settings
PAGER="less"
export LESS_TERMCAP_mb=$'\e[1;31m'      # Start bold red
export LESS_TERMCAP_md=$'\e[1;32m'      # Start bold green
export LESS_TERMCAP_me=$'\e[0m'         # End mode
export LESS_TERMCAP_se=$'\e[0m'         # End standout mode
export LESS_TERMCAP_so=$'\e[1;44;33m'   # Start standout (yellow text on blue background)
export LESS_TERMCAP_ue=$'\e[0m'         # End underline
export LESS_TERMCAP_us=$'\e[1;4;36m'    # Start underline cyan

# The one, true editor
export EDITOR="nvim"
export VISUAL="nvim"

# colors
autoload -U colors and colors

# Better globbing
setopt globdots
setopt EXTENDED_GLOB

# ===========================
# Aliases
# ===========================
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -AlFh'
alias ls='ls --color=auto'
alias path='echo "$PATH" | tr ":" "\n"'
alias q='exit'
alias le='less -X'
alias bat='/usr/bin/batcat --style=plain'
alias nv='/usr/bin/nvim'
alias cal='ncal -C'
alias python='/usr/bin/python3'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ty="ttyper -w25 -lenglish1000"
alias tl="/usr/bin/tmux ls"
alias ta="/usr/bin/tmux attach -t"
alias update="sudo apt update && sudo apt upgrade -y"
alias p="/usr/bin/ping"
alias t="/usr/bin/telnet"
alias rcd="/usr/bin/script -m advanced"
alias md="mkdir -p"

[ -f "$HOME/.local_aliases" ] && source "$HOME/.local_aliases"

case $TERM in
  xterm*|tmux*|screen*) print -Pn "\e]0;%n@%m\a" ;;
esac

[ -f "$HOME/.myenv" ] && source "$HOME/.myenv"

# ===========================
# Vi mode and cursor changes
# ===========================
bindkey -v
function zle-keymap-select {
  [[ $KEYMAP == vicmd ]] && echo -ne "\e[2 q" || echo -ne "\e[6 q"
}
zle -N zle-keymap-select
function zle-line-init { zle -K viins; echo -ne "\e[6 q"; }
zle -N zle-line-init
function zle-line-finish { echo -ne "\e[2 q"; }
zle -N zle-line-finish

# ===========================
# SSH Agent Loader
# ===========================
# SSH_ENV="$HOME/.ssh/agent_env"
# SSH_BOOTSTRAP="$HOME/.ssh/ssh_agent.zsh"
#
# if [[ -x "$SSH_BOOTSTRAP" ]]; then
#     # Run the script if agent file missing or invalid
#     if [[ ! -f "$SSH_ENV" ]] || ! grep -q "SSH_AUTH_SOCK" "$SSH_ENV"; then
#         # "$SSH_BOOTSTRAP" /dev/null
#         "$SSH_BOOTSTRAP"
#     fi
#
#     # Load environment from the file (if it exists)
#     if [[ -f "$SSH_ENV" ]]; then
#         source "$SSH_ENV" >/dev/null
#
#         # If agent PID is stale, restart
#         if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
#             "$SSH_BOOTSTRAP" >/dev/null
#             source "$SSH_ENV" >/dev/null
#         fi
#     fi
# fi
SSH_ENV="$HOME/.ssh/agent_env"
SSH_BOOTSTRAP="$HOME/.ssh/ssh_agent.zsh"

if [[ -x "$SSH_BOOTSTRAP" ]]; then
    # Run the bootstrap script to ensure the agent is started/reused
    "$SSH_BOOTSTRAP"
    # Then load its environment variables into this shell
    [[ -f "$SSH_ENV" ]] && source "$SSH_ENV" >/dev/null
fi

# ===========================
# fzf integration and functiions
# ===========================
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh
export FZF_DEFAULT_OPTS='--height=100% --border'

fh() {
  local cmd
  cmd=$(fc -l 1 | fzf --tac --no-sort --prompt='History → ' | sed 's/^[[:space:]]*[0-9*]*[[:space:]]*//') || return
  eval "$cmd"
}

fv() {
  local file
  file=$(find . -type f | fzf \
    --preview 'batcat --style=numbers --color=always {} 2>/dev/null || cat {}' \
    --preview-window=up:50%:wrap --prompt='Select file → ' --exit-0)
  [[ -n "$file" ]] && nvim "$file"
}

fcd() {
  local dir
  dir=$(dirs -v | fzf --prompt="Jump to dir → " | awk '{print $2}')
  [[ -z "$dir" ]] && return
  [[ "$dir" == "~"* ]] && cd "${dir/#\~/$HOME}" || cd "$dir" || echo "No such directory: $dir"
}

fs() {
  local file
  file=$(rg --files-with-matches --no-heading --color=never "$1" 2>/dev/null |
    fzf --prompt="Search results → " --exit-0)
  [[ -n "$file" ]] && nvim "$file"
}

fsa() {
  local file
  file=$(find / \
    -path /proc -prune -o \
    -path /sys -prune -o \
    -path /dev -prune -o \
    -path /run -prune -o \
    -path /tmp -prune -o \
    -path /var/lib -prune -o \
    -path /var/run -prune -o \
    -path /snap -prune -o \
    -type f -readable -print 2>/dev/null | \
    fzf --prompt='Search all files → ')

  [[ -n "$file" ]] && nvim "$file"
}

fk() {
  ps -ef | sed 1d | fzf -m --prompt='Kill process → ' | awk '{print $2}' | xargs -r kill -9
}

# ===========================
# Python environment helpers
# ===========================
E_RESET=$'\e[0m'
E_RED=$'\e[38;2;214;4;4m'
E_GREEN=$'\e[38;2;0;200;0m'
E_BLUE=$'\e[38;2;68;157;252m'
E_ORANGE=$'\e[38;2;250;156;5m'

pyon() {
  local venv_dir
  if [[ -n "$1" ]]; then
    venv_dir="$1"
  elif [[ -d .venv ]]; then
    venv_dir=".venv"
  elif [[ -d venv ]]; then
    venv_dir="venv"
  else
    echo "${E_RED}No virtual environment found.${E_RESET}"
    return 1
  fi

  if [[ ! -f "$venv_dir/bin/activate" ]]; then
    echo "${E_RED}No activate script found in $venv_dir/bin.${E_RESET}"
    return 1
  fi

  echo "${E_GREEN}Activating Python environment: ${E_BLUE}${venv_dir}${E_RESET}"
  source "$venv_dir/bin/activate"
}

pyoff() {
  if [[ -z "$VIRTUAL_ENV" ]]; then
    echo "${E_RED}No virtual environment active.${E_RESET}"
    return 1
  fi
  if type deactivate &>/dev/null; then
    deactivate
    echo "${E_ORANGE}Python environment deactivated.${E_RESET}"
  else
    export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "$VIRTUAL_ENV/bin" | paste -sd:)
    unset VIRTUAL_ENV
    echo "${E_ORANGE}Python environment deactivated (manual cleanup).${E_RESET}"
  fi
}

# ===========================
# Auto Python venv activation
# ===========================
autoload -Uz add-zsh-hook

# Track which venv is active
__ZSH_AUTO_VENV_CURRENT=""

__zsh_auto_venv() {
  local dir venv_path=""

  # Walk up the directory tree to find .venv or venv
  dir=$PWD
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.venv" ]]; then
      venv_path="$dir/.venv"
      break
    elif [[ -d "$dir/venv" ]]; then
      venv_path="$dir/venv"
      break
    fi
    dir=${dir:h}
  done

  # If found and not already active, activate it
  if [[ -n "$venv_path" && "$VIRTUAL_ENV" != "$venv_path" ]]; then
    # If another venv is active, deactivate first
    if [[ -n "$VIRTUAL_ENV" && "$VIRTUAL_ENV" != "$venv_path" ]]; then
      pyoff >/dev/null
    fi
    source "$venv_path/bin/activate" >/dev/null 2>&1 && \
      __ZSH_AUTO_VENV_CURRENT="$venv_path" && \
      echo "${E_GREEN}Activated Python venv:${E_BLUE} ${venv_path}${E_RESET}"
    return
  fi

  # If no venv found but one is active, deactivate it
  if [[ -z "$venv_path" && -n "$VIRTUAL_ENV" ]]; then
    pyoff >/dev/null
    __ZSH_AUTO_VENV_CURRENT=""
  fi
}

# Hook runs every time you cd
add-zsh-hook chpwd __zsh_auto_venv

# Run once at shell startup too
__zsh_auto_venv
