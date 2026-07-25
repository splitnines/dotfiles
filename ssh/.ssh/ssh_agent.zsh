#!/usr/bin/env zsh
# ====================================
# SSH Agent Bootstrap
# ====================================

SSH_ENV="$HOME/.ssh/agent_env"

start_agent() {
    echo "Starting new SSH agent..."

    eval "$(ssh-agent -s)" >/dev/null

    for key in "$HOME"/.ssh/id_*; do
        if [[ -f "$key" && "$key" != *.pub ]]; then
            ssh-add "$key"
        fi
    done

    {
        printf 'export SSH_AUTH_SOCK=%q\n' "$SSH_AUTH_SOCK"
        printf 'export SSH_AGENT_PID=%q\n' "$SSH_AGENT_PID"
    } >"$SSH_ENV"

    chmod 600 "$SSH_ENV"
}

if [[ -f "$SSH_ENV" ]]; then
    source "$SSH_ENV"

    ssh-add -l >/dev/null 2>&1
    agent_status=$?

    case "$agent_status" in
        0)
            # Agent is running and has at least one key.
            ;;
        1)
            # Agent is running but has no keys.
            for key in "$HOME"/.ssh/id_*; do
                if [[ -f "$key" && "$key" != *.pub ]]; then
                    ssh-add "$key"
                fi
            done
            ;;
        2)
            # Cannot connect to the saved agent.
            start_agent
            ;;
    esac
else
    start_agent
fi
