set -o vi

case $- in
    *i*) ;;
    *) return ;;
esac

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

shopt -s histappend
shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

case "$TERM" in
    xterm-color|*-256color|screen) color_prompt=yes ;;
esac

NEWLINE_BEFORE_PROMPT=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

__git_prompt_info() {
    local branch

    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
    branch=$(git branch --show-current 2>/dev/null) || return 0
    [ -n "$branch" ] || return 0

    printf ' \001\033[0;31m\002%s\001\033[0m\002' "$branch"

    git update-index -q --refresh >/dev/null 2>&1
    if ! git diff --quiet --ignore-submodules --cached 2>/dev/null || \
       ! git diff --quiet --ignore-submodules 2>/dev/null; then
        printf ' \001\033[38;5;208m\002!\001\033[0m\002'
    fi
}

if [ "$color_prompt" = yes ]; then
    VIRTUAL_ENV_DISABLE_PROMPT=1

    prompt_color='\[\033[;90m\]'
    info_color='\[\033[1;34m\]'
    prompt_symbol='@'
    dollar='$'

    if [ "$EUID" -eq 0 ]; then
        prompt_color='\[\033[;94m\]'
        info_color='\[\033[1;31m\]'
    fi

    PS1=$prompt_color'\n${debian_chroot:+($debian_chroot)──}${VIRTUAL_ENV:+(\[\033[0;1m\]$(basename "$VIRTUAL_ENV")'$prompt_color')}['$info_color'\u'$prompt_symbol'\h'$prompt_color']-['$info_color'\w'$prompt_color']$(__git_prompt_info)\n'$info_color''$dollar'\[\033[0m\] '

    unset prompt_color
    unset info_color
    unset prompt_symbol
    unset dollar
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

unset color_prompt
unset force_color_prompt
unset NEWLINE_BEFORE_PROMPT

case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
esac

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

[ -f ~/.bash_aliases ] && . ~/.bash_aliases
[ -f ~/.django_envs ] && . ~/.django_envs

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

export XAUTHORITY="$HOME/.Xauthority"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;44;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;36m'

export PATH="$HOME/.local/bin:$PATH"

[ -f "$HOME/.myenv" ] && . "$HOME/.myenv"
