#!/bin/bash
set -euo pipefail

# Path configuration loader for Cursor Rule Manager
# Priority:
# 1) $WORK_DIR/global-parameters.env (current standard)
# 2) $HOME/.devops-env (user-specific)
# 3) $WORK_DIR/.aws-cli-config.env (legacy)
# 4) $WORK_DIR/.aws-cli-jobox.env (legacy backward-compatible)
# 5) $HOME/.aws-cli-jobox.env (legacy backward-compatible)
# Fallback: prompt for WORK_DIR (default: $HOME/devops)

resolve_path_config() {
    local default_work_dir
    default_work_dir="${HOME}/devops"

    # Build candidate list with default work dir
    local work_dir_to_check="${WORK_DIR:-$default_work_dir}"
    local candidates=()
    
    # Primary candidates
    candidates+=("${work_dir_to_check}/global-parameters.env")
    candidates+=("${HOME}/.devops-env")
    
    # Legacy candidates
    candidates+=("${work_dir_to_check}/.aws-cli-config.env")
    candidates+=("${work_dir_to_check}/.aws-cli-jobox.env")
    candidates+=("${HOME}/.aws-cli-jobox.env")

    for cfg in "${candidates[@]}"; do
        if [[ -f "$cfg" ]]; then
            # Export variables declared in the env file
            set -a
            # shellcheck disable=SC1090
            . "$cfg"
            set +a
            export PATH_CONFIG_FILE="$cfg"
            break
        fi
    done

    # If WORK_DIR still unset, set to default (don't prompt unless interactive and no config found)
    if [[ -z "${WORK_DIR:-}" ]]; then
        if [[ -z "${PATH_CONFIG_FILE:-}" && -t 0 && -t 1 ]]; then
            read -r -p "Enter the root of your working directory (WORK_DIR) [${default_work_dir}]: " _input || true
            WORK_DIR="${_input:-$default_work_dir}"
        else
            WORK_DIR="$default_work_dir"
        fi
        export WORK_DIR
    fi

    # Derive defaults if not provided by env file
    export LOG_DIR="${LOG_DIR:-${WORK_DIR}/logs}"
    export REPORTS_DIR="${REPORTS_DIR:-${WORK_DIR}/reports}"
    export BACKUP_DIR="${BACKUP_DIR:-${WORK_DIR}/backups}"
}

# Execute on source
resolve_path_config


