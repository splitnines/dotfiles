# shellcheck shell=bash
# shellcheck disable=SC1091
set -o vi

case $- in
*i*) ;;
*) return ;;
esac

# Turn off ctrl-c echo
[[ $- == *i* ]] && stty -echoctl

HISTFILE="$HOME/.local/state/bash/bash_history"
mkdir -p "${HISTFILE%/*}"
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
export PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
export XAUTHORITY="$HOME/.Xauthority"

shopt -s cdspell
shopt -s autocd
shopt -s checkwinsize

[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# ===========================
# Path
# ===========================
PATH="/sbin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
[[ -d "$HOME/.local/bin" ]] &&
    PATH="$PATH:$HOME/.local/bin"
[[ -d "$HOME/bin" ]] && PATH=$PATH:"$HOME/bin"
# Ubuntu
[[ -d "/snap/bin" ]] &&
    PATH="$PATH:/snap/bin"
[[ -d "$HOME/.cargo/bin" ]] &&
    PATH="$PATH:$HOME/.cargo/bin"
[[ -d "/usr/local/go/bin" ]] &&
    PATH="$PATH:/usr/local/go/bin"
[[ -d "$HOME/.opencode/bin" ]] &&
    PATH="$PATH:$HOME/.opencode/bin"
# Pi on Arch
[[ -d "$HOME/.local/share/npm/bin" ]] &&
    PATH="$PATH:$HOME/.local/share/npm/bin"
# Pi on Ubuntu
[[ -d "$HOME/.local/share/pi-node/current/bin" ]] &&
    PATH="$PATH:$HOME/.local/share/pi-node/current/bin"

# WSL
if grep -qi "microsoft" /proc/version 2>/dev/null; then
    for p in /usr/lib/wsl/lib /mnt/c/WINDOWS/System32 /mnt/c/WINDOWS; do
        [[ -d "$p" ]] && PATH="$PATH:$p"
    done
fi

# ===========================
# Prioritize local fzf install
# ===========================
if [[ -d "$HOME/.fzf/bin" ]]; then
    PATH="$HOME/.fzf/bin:$PATH"
fi

export PATH

# ===========================
# ls, directory colors
# ===========================
if [[ -x /usr/bin/dircolors ]]; then
    if [[ -f "$HOME/.config/shell/dircolors-onedark" ]]; then
        eval "$(dircolors -b "$HOME/.config/shell/dircolors-onedark")"
    elif [[ -f "$HOME/.dircolors" ]]; then
        eval "$(dircolors -b "$HOME/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi
fi

# ===========================
# OneDark Color Scheme
# ===========================
if [[ -s "$HOME/.config/shell/onedark-colors.sh" ]]; then
    source "$HOME/.config/shell/onedark-colors.sh"
fi

# ===========================
# Python venv auto-activation
# ===========================
# VIRTUAL_ENV_DISABLE_PROMPT=1
__auto_venv_path=''

__find_venv_dir() {
    local dir
    local name

    dir=$PWD
    while [[ "$dir" != "/" ]]; do
        for name in .venv venv env; do
            if [[ -f "$dir/$name/bin/activate" ]]; then
                printf '%s/%s\n' "$dir" "$name"
                return 0
            fi
        done
        dir=${dir%/*}
        [[ -n "$dir" ]] || dir=/
    done

    return 1
}

__auto_venv() {
    local found_venv

    found_venv=$(__find_venv_dir 2>/dev/null || true)

    if [[ -n "$__auto_venv_path" ]]; then
        if [[ -z "$found_venv" ]]; then
            if command -v deactivate >/dev/null 2>&1; then
                deactivate >/dev/null 2>&1 || true
            else
                PATH=$(printf '%s' "$PATH" | tr ':' '\n' | grep -v "^$__auto_venv_path/bin$" | paste -sd:)
                export PATH
                unset VIRTUAL_ENV
            fi
            __auto_venv_path=''
            return 0
        fi

        if [[ "$found_venv" != "$__auto_venv_path" ]]; then
            if command -v deactivate >/dev/null 2>&1; then
                deactivate >/dev/null 2>&1 || true
            fi
            __auto_venv_path=''
        fi
    fi

    if [[ -n "$found_venv" ]]; then
        if [[ -n "$VIRTUAL_ENV" ]] && [[ -z "$__auto_venv_path" ]]; then
            return 0
        fi

        if [[ "$VIRTUAL_ENV" != "$found_venv" ]]; then
            . "$found_venv/bin/activate"
        fi
        __auto_venv_path=$found_venv
    fi
}

# ===========================
# Prompt
# ===========================
# identify the os for building the prompt
__os_icon() {
    local os=""

    if [[ -r /etc/os-release ]]; then
        . /etc/os-release
        os="$ID"
    fi

    if [[ "$os" == "arch" ]]; then
        printf ""
    elif [[ "$os" == "ubuntu" ]]; then
        printf ""
    else
        printf "@"
    fi
}

__git_branch_name() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
    git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || return 0
}

__git_is_dirty() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1
    git update-index -q --refresh >/dev/null 2>&1

    ! git diff --quiet --ignore-submodules --cached 2>/dev/null ||
        ! git diff --quiet --ignore-submodules 2>/dev/null ||
        [[ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]]
}

__set_prompt() {
    local prompt_color info_color branch_color venv_color dirty_color prompt_symbol dollar
    local venv_segment git_segment branch

    prompt_color='\[\033[0;90m\]'
    info_color='\[\033[0;34m\]'
    branch_color='\[\033[0;31m\]'
    venv_color='\[\033[0;32m\]'
    dirty_color='\[\033[38;5;208m\]'
    prompt_symbol="$(__os_icon)"
    dollar='$'

    if [[ "$EUID" -eq 0 ]]; then
        prompt_color='\[\033[0;94m\]'
        info_color='\[\033[0;31m\]'
        branch_color='\[\033[0;34m\]'
        venv_color='\[\033[0;32m\]'
        dollar='#'
    fi

    venv_segment=''
    if [[ -n "$VIRTUAL_ENV" ]]; then
        venv_segment="${prompt_color}${venv_color}π ${prompt_color}"
    fi

    git_segment=''
    branch=$(__git_branch_name)
    if [[ -n "$branch" ]]; then
        git_segment=" ${branch_color}${branch}"
        if __git_is_dirty; then
            if [[ "$prompt_symbol" == "@" ]]; then
                git_segment+=" ${dirty_color} !! "
            else
                git_segment+=" ${dirty_color}$prompt_symbol "
            fi
        fi
        git_segment+="\[\033[0m\]"
    fi

    PS1="\n${prompt_color}${venv_segment}${info_color}\u${prompt_symbol}\h ${prompt_color}${info_color}\w${prompt_color}${git_segment}\n${info_color}${dollar}\[\033[0m\] "

    case "$TERM" in
    xterm* | rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]${PS1}"
        ;;
    esac
}

# ===========================
# History behavior / completion
# ===========================
shopt -s cmdhist
stty stop undef 2>/dev/null || true
bind 'set editing-mode vi'
bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string \1\e[5 q\2'
bind 'set vi-cmd-mode-string \1\e[2 q\2'
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'
bind 'set mark-symlinked-directories on'
bind 'set menu-complete-display-prefix on'
bind 'set colored-stats on'
bind 'set visible-stats on'
bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'
bind '"\C-p":history-search-backward'
bind '"\C-n":history-search-forward'

# ===========================
# Bash completion
# ===========================
if ! shopt -oq posix; then
    shopt -s progcomp

    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        . /usr/share/bash-completion/bash_completion
    fi
fi

# ===========================
# Pager settings
# ===========================
export PAGER="less"
export LESS="-R -X -F --use-color"
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_md=$'\e[38;2;97;175;239m\e[1m'
export LESS_TERMCAP_mr=$'\e[38;2;198;120;221m'
export LESS_TERMCAP_us=$'\e[38;2;152;195;121m'
export LESS_TERMCAP_so=$'\e[48;2;40;44;52m\e[38;2;229;192;123m'

# Use nvim for viewing man pages
export MANPAGER='nvim +Man!'

# The one, true editor
export EDITOR="nvim"
export VISUAL="nvim"

export BAT_THEME="OneHalfDark"

export FZF_CTRL_T_OPTS="--preview 'ls --color=always -lah {}'"

# Better globbing
shopt -s dotglob globstar extglob

# Push cd history to stack
cd() {
    local oldpwd="$PWD"

    builtin cd "$@" || return

    # Keep the previous directory in the stack so popd/fcd work.
    if [[ "$oldpwd" != "$PWD" ]]; then
        pushd -n "$oldpwd" >/dev/null || true
    fi
}

PROMPT_COMMAND="__auto_venv;__set_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

# =========================
# SSH agent
# =========================
SSH_ENV="$HOME/.ssh/agent_env"
SSH_BOOTSTRAP="$HOME/.ssh/ssh_agent.sh"

if [[ -x "$SSH_BOOTSTRAP" ]]; then
    "$SSH_BOOTSTRAP"
    # shellcheck source=/home/rickey/.ssh/agent_env
    [[ -f "$SSH_ENV" ]] && source "$SSH_ENV" >/dev/null
fi

# ===========================
# fzf defaults
# ===========================
export FZF_DEFAULT_OPTS="
  --height=100%
  --border=sharp
  --margin=1,3
  --padding=1
  --color=fg:#abb2bf,fg+:#ffffff,hl:#e5c07b,hl+:#e5c07b
  --color=info:#56b6c2,prompt:#61afef,pointer:#98c379,marker:#98c379,spinner:#e06c75,header:#61afef
  --color=border:#3e4451,label:#61afef
"
# Search command history
fh() {
    local cmd
    cmd=$(fc -l 1 | fzf --tac --no-sort --prompt='History → ' | sed 's/^[[:space:]]*[0-9*]*[[:space:]]*//') || return
    eval "$cmd"
}

# Search with preview
fv() {
    local file
    file=$(find . -type f | fzf \
        --preview 'batcat --style=numbers --color=always {} 2>/dev/null || cat {}' \
        --preview-window=up:50%:wrap --prompt='Select file → ' --exit-0)
    [[ -n "$file" ]] && nvim "$file"
}

# Search cd history
cdh() {
    local dir
    dir=$(dirs -v | fzf --prompt="Jump to dir → " | awk '{print $2}')
    [[ -z "$dir" ]] && return
    [[ "$dir" == "~"* ]] && cd "${dir/#\~/$HOME}" || cd "$dir" || echo "No such directory: $dir"
}

fcd() {
    command -v find >/dev/null 2>&1 || {
        echo "required command not found: find"
        return 1
    }
    command -v fzf >/dev/null 2>&1 || {
        echo "required command not found: fzf"
        return 1
    }

    local search_path="${1-$HOME}"
    local dir
    local prompt="Search in $search_path → "

    dir=$(find "$search_path" -type d -print 2>/dev/null |
        fzf --prompt="$prompt")

    # shellcheck disable=SC2164
    [[ -d "$dir" ]] && cd "$dir"
}

# Search and kill processes
fk() {
    ps -ef | sed 1d | fzf -m --prompt='Kill process → ' | awk '{print $2}' | xargs -r kill -9
}

# ===========================
# Python environment helpers
# ===========================
pyon() {
    local venv_dir
    if [[ -n "$1" ]]; then
        venv_dir="$1"
    elif [[ -d .venv ]]; then
        venv_dir=".venv"
    elif [[ -d venv ]]; then
        venv_dir="venv"
    else
        echo "${E_RED:-}No virtual environment found.${E_RESET:-}"
        return 1
    fi

    if [[ ! -f "$venv_dir/bin/activate" ]]; then
        echo "${E_RED:-}No activate script found in $venv_dir/bin.${E_RESET:-}"
        return 1
    fi

    echo "${E_GREEN:-}Activating Python environment: ${E_BLUE:-}${venv_dir}${E_RESET:-}"
    source "$venv_dir/bin/activate"
}

pyoff() {
    if [[ -z "$VIRTUAL_ENV" ]]; then
        echo "${E_RED:-}No virtual environment active.${E_RESET:-}"
        return 1
    fi
    if type deactivate &>/dev/null; then
        deactivate
        echo "${E_ORANGE:-}Python environment deactivated.${E_RESET:-}"
    else
        PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "$VIRTUAL_ENV/bin" | paste -sd:)
        export PATH
        unset VIRTUAL_ENV
        echo "${E_ORANGE:-}Python environment deactivated (manual cleanup).${E_RESET:-}"
    fi
}

# copy command output to clipboard
y() {
    command -v xclip >/dev/null 2>&1 &&
        xclip -selection clipboard
}

# Run fastfetch or neofetch
ff() {
    command -v fastfetch >/dev/null 2>&1 && fastfetch && return 0
    command -v neofetch >/dev/null 2>&1 && neofetch
}

# Screenkey
sk() {
    if pgrep -x screenkey >/dev/null; then
        pkill -x screenkey
    else
        screenkey -g '1920x300+1900+20' -s large >/dev/null 2>&1 &
    fi
}

# Display i3 keybindings
i3keys() {
    grep -hE '^[[:space:]]*bindsym' \
        ~/.config/i3/config 2>/dev/null
}

# ===========================
# Aliases
# ===========================
alias bat='/usr/bin/batcat --style=plain --theme="OneHalfDark" --pager="less -RFX"'
alias bt='bluetoothctl'
alias btc='bluetoothctl connect'
alias btC='bluetoothctl devices Connected'
alias btd='bluetoothctl disconnect'
alias btl='bluetoothctl devices'
alias ....="cd ../../.."
alias ...="cd ../.."
alias ..="cd .."
alias egrep='egrep --color=auto'
alias feh='feh --image-bg black --auto-zoom --scale-down'
alias ga='git add .'
alias gb='git --no-pager branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff | nvim -'
alias gf='git fetch'
alias g='git'
alias gm='git merge'
alias gs='git status'
alias grep='grep --color=auto'
alias h='fc -l 1'
alias hl='rg --passthru'
alias l='ls --color=auto'
alias la='ls -A'
alias le='less -X'
if command -v eza >/dev/null 2>&1; then
    alias ll='eza -lA --git'
else
    alias ll='ls -Alh'
fi
command -v xdg-open >/dev/null 2>&1 &&
    alias open='xdg-open'
alias ls='ls --color=auto'
alias md="mkdir -p"
alias micc='arecord -f cd -vv -D default /dev/null'
alias montage='feh --image-bg black --montage'
alias nv='nvim'
alias path='echo "$PATH" | tr ":" "\n"'
alias p="ping"
alias pull='git pull'
alias push='git push'
alias py='python3'
alias q='exit'
alias rcd="script -m advanced"
alias rs="rsync -avzr"
alias slides='feh --image-bg black -D 3 --auto-zoom --scale-down'
alias ta="tmux attach -t"
alias tl="tmux ls | column -t"
alias t="telnet"
alias ts="tailscale"
alias z='zathura'

if [[ -f "$HOME/.config/shell/local_aliases" ]]; then
    source "$HOME/.config/shell/local_aliases"
fi

# Load any local env vars
[[ -f "$HOME/.config/shell/myenv" ]] && source "$HOME/.config/shell/myenv"

# Git autocompletion
if command -v git >/dev/null 2>&1; then
    if [[ -r /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    fi

    if [[ -r /usr/share/bash-completion/completions/git ]]; then
        source /usr/share/bash-completion/completions/git
    elif [[ -r /usr/share/git/completion/git-completion.bash ]]; then
        source /usr/share/git/completion/git-completion.bash
    fi

    if declare -F __git_complete >/dev/null; then
        __git_complete g git
    fi
fi

case $TERM in
xterm* | tmux* | screen*) printf '\e]0;%s@%s\a' "$USER" "${HOSTNAME%%.*}" ;;
esac

export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    \. "$NVM_DIR/nvm.sh"
fi
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"

# Use pinentry-tty if in a terminal and the GUI if not
if command -v gpg-connect-agent >/dev/null 2>&1 && [[ -t 1 ]]; then
    GPG_TTY="$(tty)"
    export GPG_TTY
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
fi

# CML environment variables
export CISCO_USER=cisco
export CISCO_PASS=cisco
export BREAKOUT_PASSWORD=cisco
