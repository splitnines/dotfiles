set -o vi

case $- in
    *i*) ;;
    *) return ;;
esac

HISTCONTROL=ignoreboth
HISTSIZE=50000
HISTFILESIZE=50000
HISTFILE="$HOME/.cache/bash/bash_history"

shopt -s histappend
shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ===========================
# Path
# ===========================
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/usr/local/go/bin"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.cargo/bin" ] && PATH="$HOME/.cargo/bin:$PATH"
[ -d "/usr/local/go/bin" ] && PATH="/usr/local/go/bin:$PATH"

if grep -qi "microsoft" /proc/version 2>/dev/null; then
    IS_WSL=true
else
    IS_WSL=false
fi

if $IS_WSL; then
    for p in /usr/lib/wsl/lib /mnt/c/WINDOWS/System32 /mnt/c/WINDOWS; do
        [ -d "$p" ] && PATH="$PATH:$p"
    done
fi

export XAUTHORITY="$HOME/.Xauthority"

# ===========================
# NVM setup
# ===========================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

export PATH

# ===========================
# Prioritize local fzf install
# ===========================
if [ -d "$HOME/.fzf/bin" ]; then
    PATH="$HOME/.fzf/bin:$PATH"
fi

# ===========================
# ls, directory colors
# ===========================
if [ -x /usr/bin/dircolors ]; then
    if [ -f "$HOME/.config/shell/dircolors-onedark" ]; then
        eval "$(dircolors -b "$HOME/.config/shell/dircolors-onedark")"
    elif [ -f "$HOME/.dircolors" ]; then
        eval "$(dircolors -b "$HOME/.config/shell/dircolors")"
    else
        eval "$(dircolors -b)"
    fi
fi

[ -f "$HOME/.config/shell/local_aliases" ] && source "$HOME/.config/shell/local_aliases"

# ===========================
# OneDark Color Scheme
# ===========================
if [ -f "$HOME/.config/shell/onedark-colors.sh" ]; then
    . "$HOME/.config/shell/onedark-colors.sh"
fi
# else
#     printf 'Warning: ~/.config/shell/onedark-colors.sh not found\n' >&2
# fi

# ===========================
# Python venv auto-activation
# ===========================
VIRTUAL_ENV_DISABLE_PROMPT=1
__auto_venv_path=''

__find_venv_dir() {
    local dir
    local name

    dir=$PWD
    while [ "$dir" != "/" ]; do
        for name in .venv venv env; do
            if [ -f "$dir/$name/bin/activate" ]; then
                printf '%s/%s\n' "$dir" "$name"
                return 0
            fi
        done
        dir=${dir%/*}
        [ -n "$dir" ] || dir=/
    done

    return 1
}

__auto_venv() {
    local found_venv

    found_venv=$(__find_venv_dir 2>/dev/null || true)

    if [ -n "$__auto_venv_path" ]; then
        if [ -z "$found_venv" ]; then
            if [ "$VIRTUAL_ENV" = "$__auto_venv_path" ] && command -v deactivate >/dev/null 2>&1; then
                deactivate >/dev/null 2>&1 || true
            fi
            __auto_venv_path=''
            return 0
        fi

        if [ "$found_venv" != "$__auto_venv_path" ]; then
            if [ "$VIRTUAL_ENV" = "$__auto_venv_path" ] && command -v deactivate >/dev/null 2>&1; then
                deactivate >/dev/null 2>&1 || true
            fi
            __auto_venv_path=''
        fi
    fi

    if [ -n "$found_venv" ]; then
        if [ -n "$VIRTUAL_ENV" ] && [ -z "$__auto_venv_path" ]; then
            return 0
        fi

        if [ "$VIRTUAL_ENV" != "$found_venv" ]; then
            . "$found_venv/bin/activate"
        fi
        __auto_venv_path=$found_venv
    fi
}

# ===========================
# Prompt
# ===========================
__git_branch_name() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
    git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || return 0
}

__git_is_dirty() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1
    git update-index -q --refresh >/dev/null 2>&1
    ! git diff --quiet --ignore-submodules --cached 2>/dev/null || \
    ! git diff --quiet --ignore-submodules 2>/dev/null
}

__set_prompt() {
    local prompt_color info_color branch_color venv_color dirty_color prompt_symbol dollar
    local venv_segment git_segment branch

    prompt_color='\[\033[0;90m\]'
    info_color='\[\033[0;34m\]'
    branch_color='\[\033[0;31m\]'
    venv_color='\[\033[0;32m\]'
    dirty_color='\[\033[38;5;208m\]'
    prompt_symbol='@'
    dollar='$'

    if [ "$EUID" -eq 0 ]; then
        prompt_color='\[\033[0;94m\]'
        info_color='\[\033[0;31m\]'
        branch_color='\[\033[0;31m\]'
        venv_color='\[\033[0;32m\]'
    fi

    venv_segment=''
    if [ -n "$VIRTUAL_ENV" ]; then
        venv_segment="${prompt_color}[${venv_color}$(basename "$VIRTUAL_ENV")${prompt_color}]-"
    fi

    git_segment=''
    branch=$(__git_branch_name)
    if [ -n "$branch" ]; then
        git_segment=" ${branch_color}${branch}"
        if __git_is_dirty; then
            git_segment+=" ${dirty_color}⚡"
        fi
        git_segment+="\[\033[0m\]"
    fi

    PS1="${prompt_color}\n${venv_segment}[${info_color}\u${prompt_symbol}\h${prompt_color}]-[${info_color}\w${prompt_color}]${git_segment}\n${info_color}${dollar}\[\033[0m\] "

    case "$TERM" in
        xterm*|rxvt*)
            PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]${PS1}"
            ;;
    esac
}

# ===========================
# History behavior / completion
# ===========================
shopt -s cmdhist
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
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# fzf integration
if [ -f "$HOME/.fzf/shell/key-bindings.bash" ]; then
    . "$HOME/.fzf/shell/key-bindings.bash"
fi

if [ -f "$HOME/.fzf/shell/completion.bash" ]; then
    . "$HOME/.fzf/shell/completion.bash"
fi

if command -v git >/dev/null 2>&1; then
    if [ -f /usr/share/bash-completion/completions/git ]; then
        . /usr/share/bash-completion/completions/git
    elif [ -f /etc/bash_completion.d/git ]; then
        . /etc/bash_completion.d/git
    fi
fi

# ===========================
# Misc settings
# ===========================
PAGER="less"
export LESS="-R --use-color"
export MANPAGER="less -R --use-color"
export MANROFFOPT="-c"
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_md=$'\e[38;2;97;175;239m'

PROMPT_COMMAND="__auto_venv;__set_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

# =========================
# SSH agent
# =========================
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
if [[ -f ~/.fzf/shell/key-bindings.bash ]]; then
  source ~/.fzf/shell/key-bindings.bash
fi

if [[ -f ~/.fzf/shell/completion.bash ]]; then
  source ~/.fzf/shell/completion.bash
fi

# ===========================
# fzf defaults
# ===========================
export FZF_DEFAULT_OPTS="
  --height=100%
  --border=rounded
  --margin=1,3
  --padding=1
  --color=fg:#abb2bf,fg+:#ffffff,hl:#e5c07b,hl+:#e5c07b
  --color=info:#56b6c2,prompt:#61afef,pointer:#98c379,marker:#98c379,spinner:#e06c75,header:#61afef
  --color=border:#3e4451,label:#61afef
"
#  --color=bg:#141414,bg+:#2b3038,fg:#abb2bf,fg+:#ffffff,hl:#e5c07b,hl+:#e5c07b


# Search command history
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

# Search cd history
fcd() {
  local dir
  dir=$(dirs -v | fzf --prompt="Jump to dir → " | awk '{print $2}')
  [[ -z "$dir" ]] && return
  [[ "$dir" == "~"* ]] && cd "${dir/#\~/$HOME}" || cd "$dir" || echo "No such directory: $dir"
}

# Search and kill processes
fk() {
  ps -ef | sed 1d | fzf -m --prompt='Kill process → ' | awk '{print $2}' | xargs -r kill -9
}

# ===========================
# Weather
# ===========================
typeset -ga WEATHER_CITIES
WEATHER_CITIES_FILE="$HOME/.config/zsh/weather_cities.zsh"
[[ -f $WEATHER_CITIES_FILE ]] && source "$WEATHER_CITIES_FILE"

weather() {
  local city="$1"
  local state="$2"
  local country="${3:-usa}"

  if [[ -z "$city" ]]; then
    echo "usage: weather <city> [state] [country]"
    return 1
  fi

  city="${city// /+}"
  state=${state// /+}

  curl "http://wttr.in/${city}${state:+,+$state}+${country}?u"
}

_weather() {
  local -a states countries

  states=(
    al ak az ar ca co ct de fl ga hi id il in ia ks ky
    la me md ma mi mn ms mo mt ne nv nh nj nm ny nc
    nd oh ok or pa ri sc sd tn tx ut vt va wa wv wi wy
  )

  countries=(usa)

  _arguments -C \
    '1:city:->city' \
    '2:state:->state' \
    '3:country:->country'

  case $state in
    city)
      compadd -Q -a WEATHER_CITIES
      ;;
    state)
      compadd -a states
      ;;
    country)
      compadd -a countries
      ;;
  esac
}

# Screenkey
sk() {
  if pgrep -x screenkey > /dev/null; then
    pkill -x screenkey
  else
    screenkey -g '1920x300+1600+0' -s large >/dev/null 2>&1 &
  fi
}

# =====================
# Aliases
# =====================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias bat='/usr/bin/batcat --style=plain --theme="OneHalfDark" --pager="less -RFX"'
alias bt=bluetoothctl
alias btc='bluetoothctl connect'
alias btd='bluetoothctl disconnect'
alias btl='bluetoothctl devices'
alias cal='ncal -C'
alias egrep='egrep --color=auto'
alias feh='feh --image-bg black'
alias fgrep='fgrep --color=auto'
alias g=git
alias ga='git add .'
alias gb='git branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff | nvim -'
alias gm='git merge'
alias grep='grep --color=auto'
alias gs='git status'
alias h='history'
alias ls='ls --color=auto'
alias l=ls
alias la='ls -A'
alias le='less -X'
alias ll='ls -Alh'
alias md='mkdir -p'
alias nv=/usr/bin/nvim
alias path='echo "$PATH" | tr ":" "\n"'
alias pull='git pull'
alias push='git push'
alias python=python3
alias q=exit
alias rcd='/usr/bin/script -m advanced'
alias rs='rsync -avzr'
alias ta='/usr/bin/tmux attach -t'
alias tl='/usr/bin/tmux ls'
alias which-command=whence
