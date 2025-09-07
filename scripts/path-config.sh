#!/bin/bash
set -euo pipefail

# Path configuration loader for Cursor Rule Manager
# Priority:
# 1) $HOME/.aws-cli-config.env
# 2) $WORK_DIR/.aws-cli-config.env
# 3) $WORK_DIR/.aws-cli-jobox.env (backward-compatible)
# 4) $HOME/.aws-cli-jobox.env (backward-compatible)
# Fallback: prompt for WORK_DIR (default: $HOME/devops)

resolve_path_config() {
    local default_work_dir
    default_work_dir="${WORK_DIR:-${HOME}/devops}"

    # Build candidate list (skip empty WORK_DIR entries)
    local candidates=()
    candidates+=("${HOME}/.aws-cli-config.env")
    if [[ -n "${WORK_DIR:-}" ]]; then
        candidates+=("${WORK_DIR}/.aws-cli-config.env")
        candidates+=("${WORK_DIR}/.aws-cli-jobox.env")
    fi
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

    # If WORK_DIR still unset, prompt (interactive) or use default
    if [[ -z "${WORK_DIR:-}" ]]; then
        if [[ -t 0 && -t 1 ]]; then
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


