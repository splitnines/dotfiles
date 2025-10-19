#!/usr/bin/env zsh
# ====================================
# SSH Agent Bootstrap
# ====================================
#
# stow in $HOME/.ssh/

SSH_ENV="$HOME/.ssh/agent_env"

start_agent() {
    echo "Starting new SSH agent..."
    eval "$(ssh-agent -s)" >/dev/null

    # Try to add all private keys in ~/.ssh automatically
    for key in ~/.ssh/id_*; do
        [[ -f "$key" && "$key" != *.pub ]] && ssh-add "$key" 2>/dev/null
    done

    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" >"$SSH_ENV"
    echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >>"$SSH_ENV"
    chmod 600 "$SSH_ENV"
}

# Reuse existing agent if possible; otherwise start a new one
if [[ -f "$SSH_ENV" ]]; then
    source "$SSH_ENV" >/dev/null
    if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
        start_agent
    fi
else
    start_agent
fi
