# ~/.zshrc
[[ -o interactive ]] || return

# Terminal and vi command-line editing
if [[ -t 0 ]]; then
    stty -echoctl 2>/dev/null || true
    stty stop undef 2>/dev/null || true
fi
bindkey -v

# disable highlighting of pasted text
zle_highlight=('paste:none')

# blinking cursor in viins, block in vicmd
function zle-keymap-select() {
    [[ $KEYMAP == vicmd ]] && print -n '\e[2 q' || print -n '\e[5 q'
}
zle -N zle-keymap-select

function zle-line-init() { zle -K viins; print -n '\e[5 q'; }
zle -N zle-line-init

function zle-line-finish() { print -n '\e[2 q'; }
zle -N zle-line-finish

setopt AUTO_CD GLOB_DOTS EXTENDED_GLOB DOT_GLOB

# Detect OS once for PATH and prompt
__detect_os() {
    if [[ -r /etc/os-release ]]; then
        ( source /etc/os-release; print -r -- "$ID" )
    fi
}
__OS=$(__detect_os)

# PATH: keep inherited entries (including system-managed paths), without duplicates.
typeset -U path PATH
path=( /sbin /bin /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin $path )
for p in "$HOME/.local/bin" "$HOME/.cargo/bin" /usr/local/go/bin; do
    [[ -d $p ]] && path+=( "$p" )
done

# OS specific settings
if [[ $__OS == arch && -d $HOME/.local/share/npm/bin ]]; then
    path+=( "$HOME/.local/share/npm/bin" )
fi

if [[ $__OS == ubuntu ]]; then
    for p in /snap/bin "$HOME/.local/share/pi-node/current/bin"; do
        [[ -d $p ]] && path=( "$p" $path )
    done
fi

if grep -qi microsoft /proc/version 2>/dev/null; then
    for p in /usr/lib/wsl/lib /mnt/c/WINDOWS/System32 /mnt/c/WINDOWS; do
        [[ -d $p ]] && path+=( "$p" )
    done
fi

export PATH

# Optional local environment and node version manager
[[ -f $HOME/.config/shell/myenv ]] && source "$HOME/.config/shell/myenv"

# History (ignoreboth:erasedups, histappend, and save after each command)
HISTFILE="$HOME/.local/state/zsh/zsh_history"
[[ -d ${HISTFILE:h} ]] || mkdir -p -- "${HISTFILE:h}"
HISTSIZE=10000
SAVEHIST=20000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_SPACE HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS HIST_EXPIRE_DUPS_FIRST EXTENDED_HISTORY
source <(fzf --zsh) # ctrl-r for history search

# Directory stack plus interactive completion
setopt AUTO_PUSHD PUSHD_SILENT PUSHD_IGNORE_DUPS
zmodload zsh/complist
autoload -Uz compinit
mkdir -p -- "$HOME/.cache/zsh"
compinit -d "$HOME/.cache/zsh/zcompdump"

# Enter the selector on the first Tab whenever completion has multiple matches.
zstyle ':completion:*' menu yes select
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
# zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:cd:*' completer _complete _approximate
zstyle ':completion:*' select-prompt '%SScrolling: %p%s'
setopt AUTO_MENU AUTO_LIST COMPLETE_IN_WORD ALWAYS_TO_END AUTO_PARAM_SLASH
if command -v git >/dev/null 2>&1; then
    compdef g=git
fi

# Readline's history prefix search, menu completion, and edit-and-execute
# Apply to both vi keymaps: bindkey -v changes which map is active.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search edit-command-line
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N edit-command-line
for map in viins vicmd; do
    bindkey -M "$map" '^[[A' up-line-or-beginning-search # up arrow
    bindkey -M "$map" '^[[B' down-line-or-beginning-search # down arrow
    bindkey -M "$map" '^[[Z' reverse-menu-complete # shift+tab 
    bindkey -M "$map" '^X^E' edit-command-line
done
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins "^k" history-search-backward
bindkey -M viins "^j" history-search-forward
bindkey -M menuselect '^j' down-line-or-history
bindkey -M menuselect '^k' up-line-or-history

# Directory colors and OneDark shell colors
if command -v dircolors >/dev/null 2>&1; then
    if [[ -f $HOME/.config/shell/dircolors-onedark ]]; then
        eval "$(dircolors -b "$HOME/.config/shell/dircolors-onedark")"
    elif [[ -f $HOME/.dircolors ]]; then
        eval "$(dircolors -b "$HOME/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi
fi
[[ -s $HOME/.config/shell/onedark-colors.sh ]] && source "$HOME/.config/shell/onedark-colors.sh"

# Keep the selected completion highlighted
zstyle ':completion:*:default' list-colors 'ma=48;5;238;38;5;229'

# Session agents
SSH_ENV="$HOME/.ssh/agent_env"
SSH_BOOTSTRAP="$HOME/.ssh/ssh_agent.sh"
if [[ -x $SSH_BOOTSTRAP ]]; then
    "$SSH_BOOTSTRAP"
    [[ -f $SSH_ENV ]] && source "$SSH_ENV" >/dev/null
fi

# Use pinentry-tty if in a terminal and the GUI if not
if command -v gpg-connect-agent >/dev/null 2>&1 && [[ -t 1 ]]; then
    export GPG_TTY="$(tty)"
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
fi

# Python venv auto-activation (nearest .venv, venv, or env)
__auto_venv_path=''
__auto_venv_pwd=''

__find_venv_dir() {
    local dir name

    dir=$PWD
    while [[ $dir != / ]]; do
        for name in .venv venv env; do
            if [[ -f $dir/$name/bin/activate ]]; then
                print -r -- "$dir/$name"
                return 0
            fi
        done
        dir=${dir:h}
    done
    return 1
}

__auto_venv() {
    local found_venv

    [[ $PWD == $__auto_venv_pwd ]] && return 0

    __auto_venv_pwd=$PWD
    found_venv=$(__find_venv_dir 2>/dev/null) || found_venv=''

    if [[ -n $__auto_venv_path && $found_venv != $__auto_venv_path ]]; then
        if (( $+functions[deactivate] )); then
            deactivate >/dev/null 2>&1 || true
        else
            path=( ${path:#$__auto_venv_path/bin} )
            unset VIRTUAL_ENV
        fi
        __auto_venv_path=''
    fi

    [[ -n $found_venv ]] || return 0
    [[ -n ${VIRTUAL_ENV:-} && -z $__auto_venv_path ]] && return 0
    if [[ ${VIRTUAL_ENV:-} != $found_venv ]]; then
        source "$found_venv/bin/activate" || return
    fi
    __auto_venv_path=$found_venv
}

# Prompt
__os_icon() {
    case $__OS in
        arch) print -n '' ;;
        ubuntu) print -n '' ;;
        *) print -n '@' ;;
    esac
}
__OS_ICON=$(__os_icon)

__git_branch_name() {
    git symbolic-ref --quiet --short HEAD 2>/dev/null ||
        git rev-parse --short HEAD 2>/dev/null || return 0
}

__git_is_dirty() {
    [[ -n $(git status --porcelain=v1 --ignore-submodules=all 2>/dev/null) ]]
}

__set_prompt() {
    local prompt_color info_color branch_color venv_color dirty_color
    local dollar branch git_segment venv_segment

    prompt_color='%F{8}'
    info_color='%F{4}'
    branch_color='%F{1}'
    venv_color='%F{2}'
    dirty_color='%F{208}'
    dollar='❯'

    if (( EUID == 0 )); then
        prompt_color='%F{12}'
        info_color='%F{1}'
        branch_color='%F{4}'
        dollar='#'
    fi

    venv_segment=''
    [[ -n ${VIRTUAL_ENV:-} ]] && venv_segment="${venv_color}π ${prompt_color}"

    git_segment=''
    branch=$(__git_branch_name)
    if [[ -n $branch ]]; then
        branch=${branch//\%/%%}
        git_segment=" ${branch_color}${branch}"
        if __git_is_dirty; then
            if [[ $__OS_ICON == '@' ]]; then
                git_segment+=" ${dirty_color} !! "
            else
                git_segment+=" ${dirty_color}${__OS_ICON} "
            fi
        fi
        git_segment+='%f'
    fi
    PS1=$'\n'"${prompt_color}${venv_segment}${info_color}%n${__OS_ICON}%m ${prompt_color}${info_color}%~${prompt_color}${git_segment}"$'\n'"${info_color}${dollar}%f "
}

unsetopt PROMPT_CR PROMPT_SP
autoload -Uz add-zsh-hook
add-zsh-hook precmd __auto_venv
add-zsh-hook precmd __set_prompt

# Pager, editor, fzf
export PAGER=less
export LESS='-R -X -F --use-color'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_md=$'\e[38;2;97;175;239m\e[1m'
export LESS_TERMCAP_mr=$'\e[38;2;198;120;221m'
export LESS_TERMCAP_us=$'\e[38;2;152;195;121m'
export LESS_TERMCAP_so=$'\e[48;2;40;44;52m\e[38;2;229;192;123m'

# Man page viewing 
# export MANPAGER='nvim +Man!'
export GROFF_NO_SGR=1
export MANPAGER=$PAGER

# bat theme
export BAT_THEME=OneHalfDark

# The one, true editor
export EDITOR=nvim VISUAL=nvim

# fzf defaults
export FZF_CTRL_T_OPTS="--preview 'ls --color=always -lah {}'"
export FZF_DEFAULT_OPTS='
  --height=100%
  --border=sharp
  --prompt="❯ "
  --margin=1,3
  --padding=1
  --color=fg:#abb2bf,fg+:#ffffff,hl:#e5c07b,hl+:#e5c07b
  --color=info:#56b6c2,prompt:#61afef,pointer:#98c379,marker:#98c379,spinner:#e06c75,header:#61afef
  --color=border:#3e4451,label:#61afef
'

# Leave one terminal row unused for tab complete
__tab_with_prompt_room() {
    local tty_state
    # ctrl-c as a key rather than a terminal interrupt
    tty_state=$(stty -F /dev/tty -g 2>/dev/null) || {
        zle expand-or-complete
        return
    }
    stty -F /dev/tty -isig
    local LINES=$(( LINES > 3 ? LINES - 1 : LINES ))
    { zle expand-or-complete }  always { stty -F /dev/tty "$tty_state" }
}

zle -N __tab_with_prompt_room
bindkey -M menuselect '^C' send-break
for map in viins vicmd; do
    bindkey -M "$map" '^I' __tab_with_prompt_room
done

# Interactive helpers
# fzf cd history
cdh() {
    local dir
    command -v fzf >/dev/null 2>&1 || return 1
    dir=$(dirs -v | fzf --prompt='Jump to dir → ' | awk '{print $2}') || return
    [[ -n $dir ]] || return
    cd "${dir/#\~/$HOME}"
}

# fzf history picker
fh() {
    local cmd
    command -v fzf >/dev/null 2>&1 || return 1
    cmd=$(fc -l 1 | fzf --tac --no-sort --prompt='History ❯ ' |
        sed 's/^[[:space:]]*[0-9*]*[[:space:]]*//') || return
    [[ -n $cmd ]] && eval "$cmd"
}

# fzf picker with with preview
fv() {
    local file
    command -v fzf >/dev/null 2>&1 || return 1
    file=$(find . -type f | fzf \
        --preview 'batcat --style=numbers --color=always {} 2>/dev/null || cat {}' \
        --preview-window=up:50%:wrap --prompt='Select file ❯ ' --exit-0) || return
    [[ -n $file ]] && nvim "$file"
}

# fzf directory picker
fcd() {
    local search_path dir prompt
    command -v find >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1 || return 1
    search_path="${1-$HOME}"
    prompt="Search in $search_path ❯ "
    dir=$(find "$search_path" -type d -print 2>/dev/null | fzf --prompt="$prompt") || return
    [[ -d $dir ]] && cd "$dir"
}

# fzf process killer
fk() {
    command -v fzf >/dev/null 2>&1 || return 1
    ps -ef | sed 1d | fzf -m --prompt='Kill process ❯ ' |
        awk '{print $2}' | xargs -r kill -9
}

# copy to clipboard
y() { command -v xclip >/dev/null 2>&1 && xclip -selection clipboard; }

# toggle screenkey
sk() {
    if pgrep -x screenkey >/dev/null; then
        pkill -x screenkey
    else
        screenkey -g '1920x300+1900+20' -s large >/dev/null 2>&1 &
    fi
}

# list tmux session
tl() { command -v tmux >/dev/null 2>&1 && tmux list-sessions | column -t; }

# list i3wm keybindings
i3keys() { grep -hE '^[[:space:]]*bindsym' ~/.config/i3/config 2>/dev/null; }

# Aliases
alias ....="cd ../../.."
alias ...="cd ../.."
alias ..="cd .."
alias bat='bat --style=plain --theme="OneHalfDark" --pager="less -RFX"'
alias bt='bluetoothctl'
alias btC='bluetoothctl devices Connected'
alias btc='bluetoothctl connect'
alias btd='bluetoothctl disconnect'
alias btl='bluetoothctl devices'
alias chprompt='source ~/.local/bin/chprompt'
alias feh='feh --image-bg black --auto-zoom --scale-down'
alias ff="fastfetch"
alias g='git'
alias ga='git add .'
alias gb='git --no-pager branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff | nvim -R -'
alias gf='git fetch'
alias gm='git merge'
alias grep='grep --color=auto'
alias gs='git status'
alias h='history 1'
alias hl='rg --passthru'
alias l='ls --color=auto'
alias la='ls -A'
alias le='less -X'
alias ll='ls -Alh'
alias ls='ls --color=auto'
alias md="mkdir -p"
alias micc='arecord -f cd -vv -D default /dev/null'
alias montage='feh --image-bg black --montage'
alias nv='nvim'
command -v xdg-open >/dev/null 2>&1 &&
    alias open='xdg-open'
alias p="ping"
alias pull='git pull'
alias push='git push'
alias py='python3'
alias q='exit'
alias rcd="script -m advanced"
alias rs="rsync -avzr"
alias slides='feh --image-bg black -D 3 --auto-zoom --scale-down'
alias t="telnet"
alias ta="tmux attach -t"
alias ts="tailscale"
alias vim="nvim"
alias z='zathura'

# Load local aliases
[[ -f $HOME/.config/shell/local_aliases ]] && source "$HOME/.config/shell/local_aliases"
