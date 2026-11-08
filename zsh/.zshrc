# ~/.zshrc — zsh counterpart to ../bash/.bashrc
[[ -o interactive ]] || return

# Terminal and vi command-line editing
if [[ -t 0 ]]; then
    stty -echoctl 2>/dev/null || true
    stty stop undef 2>/dev/null || true
fi
bindkey -v
zle_highlight=('paste:none')
function zle-keymap-select() {
    [[ $KEYMAP == vicmd ]] && print -n '\e[2 q' || print -n '\e[5 q'
}
zle -N zle-keymap-select
function zle-line-init() { zle -K viins; print -n '\e[5 q'; }
zle -N zle-line-init
function zle-line-finish() { print -n '\e[2 q'; }
zle -N zle-line-finish

# Bash shopts: autocd, dotglob, globstar, extglob
setopt AUTO_CD GLOB_DOTS EXTENDED_GLOB
# zsh supports recursive **/ globs natively; extended globbing supplies extglob-like patterns.
# cdspell's closest equivalent is approximate cd completion, not CORRECT (which
# also corrects command names).

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
[[ -d $HOME/.fzf/bin ]] && path=( "$HOME/.fzf/bin" $path )
export PATH

# Optional local environment and node version manager
[[ -f $HOME/.config/shell/myenv ]] && source "$HOME/.config/shell/myenv"
export NVM_DIR="$HOME/.nvm"
[[ -s $NVM_DIR/nvm.sh ]] && source "$NVM_DIR/nvm.sh"

# History (ignoreboth:erasedups, histappend, and save after each command)
HISTFILE="$HOME/.local/state/zsh/zsh_history"
[[ -d ${HISTFILE:h} ]] || mkdir -p -- "${HISTFILE:h}"
HISTSIZE=10000
SAVEHIST=20000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_SPACE HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS HIST_EXPIRE_DUPS_FIRST EXTENDED_HISTORY

# Directory stack (Bash's cd wrapper), plus interactive completion
setopt AUTO_PUSHD PUSHD_SILENT PUSHD_IGNORE_DUPS
zmodload zsh/complist
autoload -Uz compinit
mkdir -p -- "$HOME/.cache/zsh"
compinit -d "$HOME/.cache/zsh/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*'
zstyle ':completion:*:cd:*' completer _complete _approximate
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
    bindkey -M "$map" '^[[A' up-line-or-beginning-search
    bindkey -M "$map" '^[[B' down-line-or-beginning-search
    bindkey -M "$map" '^[[Z' reverse-menu-complete
    bindkey -M "$map" '^X^E' edit-command-line
done
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line

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
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

# Session agents
SSH_ENV="$HOME/.ssh/agent_env"
SSH_BOOTSTRAP="$HOME/.ssh/ssh_agent.sh"
if [[ -x $SSH_BOOTSTRAP ]]; then
    "$SSH_BOOTSTRAP"
    [[ -f $SSH_ENV ]] && source "$SSH_ENV" >/dev/null
fi
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
    # Never replace a venv activated manually.
    [[ -n ${VIRTUAL_ENV:-} && -z $__auto_venv_path ]] && return 0
    if [[ ${VIRTUAL_ENV:-} != $found_venv ]]; then
        source "$found_venv/bin/activate" || return
    fi
    __auto_venv_path=$found_venv
}

# Prompt: same OS, git, dirty-tree, venv and root indicators as Bash.
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
        # Branch names are untrusted prompt text; escape prompt percent sequences.
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
export MANPAGER='nvim +Man!'
export BAT_THEME=OneHalfDark
export EDITOR=nvim VISUAL=nvim
export FZF_CTRL_T_OPTS="--preview 'ls --color=always -lah {}'"
export FZF_DEFAULT_OPTS='
  --height=100%
  --border=sharp
  --margin=1,3
  --padding=1
  --color=fg:#abb2bf,fg+:#ffffff,hl:#e5c07b,hl+:#e5c07b
  --color=info:#56b6c2,prompt:#61afef,pointer:#98c379,marker:#98c379,spinner:#e06c75,header:#61afef
  --color=border:#3e4451,label:#61afef
'
[[ -f $HOME/.fzf/shell/key-bindings.zsh ]] && source "$HOME/.fzf/shell/key-bindings.zsh"
[[ -f $HOME/.fzf/shell/completion.zsh ]] && source "$HOME/.fzf/shell/completion.zsh"

# Interactive helpers
cdh() {
    local dir
    command -v fzf >/dev/null 2>&1 || return 1
    dir=$(dirs -v | fzf --prompt='Jump to dir → ' | awk '{print $2}') || return
    [[ -n $dir ]] || return
    cd "${dir/#\~/$HOME}"
}
fh() {
    local cmd
    command -v fzf >/dev/null 2>&1 || return 1
    cmd=$(fc -l 1 | fzf --tac --no-sort --prompt='History → ' |
        sed 's/^[[:space:]]*[0-9*]*[[:space:]]*//') || return
    [[ -n $cmd ]] && eval "$cmd"
}
fv() {
    local file
    command -v fzf >/dev/null 2>&1 || return 1
    file=$(find . -type f | fzf \
        --preview 'batcat --style=numbers --color=always {} 2>/dev/null || cat {}' \
        --preview-window=up:50%:wrap --prompt='Select file → ' --exit-0) || return
    [[ -n $file ]] && nvim "$file"
}
fcd() {
    local search_path dir prompt
    command -v find >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1 || return 1
    search_path="${1-$HOME}"
    prompt="Search in $search_path → "
    dir=$(find "$search_path" -type d -print 2>/dev/null | fzf --prompt="$prompt") || return
    [[ -d $dir ]] && cd "$dir"
}
fk() {
    command -v fzf >/dev/null 2>&1 || return 1
    ps -ef | sed 1d | fzf -m --prompt='Kill process → ' |
        awk '{print $2}' | xargs -r kill -9
}
y() { command -v xclip >/dev/null 2>&1 && xclip -selection clipboard; }
sk() {
    if pgrep -x screenkey >/dev/null; then
        pkill -x screenkey
    else
        screenkey -g '1920x300+1900+20' -s large >/dev/null 2>&1 &
    fi
}
tl() { command -v tmux >/dev/null 2>&1 && tmux list-sessions | column -t; }
# `path` is zsh's tied PATH array; use an alias rather than a function of that name.
alias path='print -l -- $path'
i3keys() { grep -hE '^[[:space:]]*bindsym' ~/.config/i3/config 2>/dev/null; }

# Aliases from Bash
alias ....='cd ../../..' ...='cd ../..' ..='cd ..'
if command -v bat >/dev/null 2>&1; then
    alias bat='bat --style=plain --theme="OneHalfDark" --pager="less -RFX"'
elif command -v batcat >/dev/null 2>&1; then
    alias bat='batcat --style=plain --theme="OneHalfDark" --pager="less -RFX"'
fi
alias bt='bluetoothctl' btC='bluetoothctl devices Connected'
alias btc='bluetoothctl connect' btd='bluetoothctl disconnect' btl='bluetoothctl devices'
alias chprompt='source ~/.local/bin/chprompt'
alias feh='feh --image-bg black --auto-zoom --scale-down'
alias ff='fastfetch'
alias g='git' ga='git add .' gb='git --no-pager branch' gc='git commit'
alias gcm='git commit -m' gco='git checkout' gd='git diff | nvim -R -'
alias gf='git fetch' gm='git merge' gs='git status'
alias grep='grep --color=auto' h='history' hl='rg --passthru'
alias l='ls --color=auto' la='ls -A' le='less -X' ll='ls -Alh' ls='ls --color=auto'
alias md='mkdir -p' micc='arecord -f cd -vv -D default /dev/null'
alias montage='feh --image-bg black --montage' nv='nvim'
command -v xdg-open >/dev/null 2>&1 && alias open='xdg-open'
alias p='ping' pull='git pull' push='git push' py='python3' q='exit'
alias rcd='script -m advanced' rs='rsync -avzr'
alias slides='feh --image-bg black -D 3 --auto-zoom --scale-down'
alias t='telnet' ta='tmux attach -t' ts='tailscale' vim='nvim' z='zathura'
[[ -f $HOME/.config/shell/local_aliases ]] && source "$HOME/.config/shell/local_aliases"
